import {
  WebSocketGateway,
  WebSocketServer,
  SubscribeMessage,
  OnGatewayConnection,
  OnGatewayDisconnect,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';
import { GameService } from './game.service';
import { MatchmakingService } from './matchmaking.service';

// Utility: generate a random game ID
function generateGameId(): string {
  const hexChars = '0123456789abcdef';
  const suffix = Array.from(
    { length: 15 },
    () => hexChars[Math.floor(Math.random() * 16)],
  ).join('');
  return `PNG${suffix}`;
}

@WebSocketGateway({ cors: { origin: '*' } })
export class GameGateway implements OnGatewayConnection, OnGatewayDisconnect {
  @WebSocketServer() server: Server;

  constructor(
    private readonly gameService: GameService,
    private readonly matchmakingService: MatchmakingService,
  ) {}

  handleConnection(client: Socket) {
    console.log(`Client connected: ${client.id}`);
  }

  handleDisconnect(client: Socket) {
    console.log(`Client disconnected: ${client.id}`);
    // If this socket was in the matchmaking queue, clean it up silently.
    this.matchmakingService.removeBySocketId(client.id);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // MATCHMAKING — new auto-pairing flow
  // ─────────────────────────────────────────────────────────────────────────

  @SubscribeMessage('joinQueue')
  async handleJoinQueue(
    client: Socket,
    payload: { playerId: string; maxRounds: number; timeLimit: number },
  ) {
    const { playerId, maxRounds, timeLimit } = payload;

    try {
      // 1. Try to find a compatible waiting player
      const matched = this.matchmakingService.findMatch(
        playerId,
        maxRounds,
        timeLimit,
      );

      if (matched) {
        // ── Match found ──
        const gameId = generateGameId();

        // Assign: the waiting player (matched) = player1, newcomer = player2
        const game = await this.gameService.createGameForMatch(
          gameId,
          matched.playerId, // player1
          playerId,         // player2
          { maxRounds, timeLimit },
        );

        const matchPayload = {
          gameId,
          player1Id: matched.playerId,
          player2Id: playerId,
          maxRounds,
          timeLimit,
        };

        // Join both sockets to the game room
        client.join(gameId);
        const matchedSocket = this.server.sockets.sockets.get(matched.socketId);
        if (matchedSocket) {
          matchedSocket.join(gameId);
        }

        // Notify both players simultaneously
        this.server.to(gameId).emit('matchFound', matchPayload);
        this.server.to(gameId).emit('gameInfo', game);

        // Remove the paired game from the public rooms list (it won't be listed
        // anyway since isPrivate=false but status will be 'waiting' briefly).
        const publicRooms = await this.gameService.getPublicRooms();
        this.server.emit('publicRooms', publicRooms);

      } else {
        // ── No match — add to queue ──
        this.matchmakingService.addToQueue(
          playerId,
          client.id,
          maxRounds,
          timeLimit,
          () => {
            // TTL expired — notify just this socket
            client.emit('matchmakingTimeout', {});
          },
        );

        client.emit('searchingForMatch', { maxRounds, timeLimit });
      }
    } catch (e) {
      client.emit('room_error', e.message);
    }
  }

  @SubscribeMessage('cancelMatchmaking')
  handleCancelMatchmaking(
    client: Socket,
    payload: { playerId: string },
  ) {
    const removed = this.matchmakingService.removeFromQueue(payload.playerId);
    client.emit('matchmakingCancelled', { removed });
  }

  // ─────────────────────────────────────────────────────────────────────────
  // PRIVATE ROOM — kept unchanged for the invite / QR flow
  // ─────────────────────────────────────────────────────────────────────────

  @SubscribeMessage('createGame')
  async handleCreateGame(
    client: Socket,
    payload: { playerId: string; gameId: string; settings?: any },
  ) {
    try {
      const game = await this.gameService.createGame(
        payload.gameId,
        payload.playerId,
        payload.settings,
      );
      client.join(payload.gameId);

      this.server.to(payload.gameId).emit('gameCreated', { gameId: payload.gameId });
      this.server.to(payload.gameId).emit('gameInfo', game);

      // Broadcast updated public rooms
      const publicRooms = await this.gameService.getPublicRooms();
      this.server.emit('publicRooms', publicRooms);

    } catch (e) {
      client.emit('room_error', e.message);
    }
  }

  @SubscribeMessage('joinGame')
  async handleJoinGame(
    client: Socket,
    payload: { gameId: string; playerId: string },
  ) {
    try {
      const game = await this.gameService.joinGame(payload.gameId, payload.playerId);
      client.join(payload.gameId);

      // Notify the host that an opponent joined (with their name for the UI)
      this.server.to(payload.gameId).emit('playerJoined', {
        playerId: payload.playerId,
        playerName: (game as any).player2?.name ?? 'Opponent',
      });
      this.server.emit('gameJoined', { gameJoined: true, gameId: payload.gameId, playerId: payload.playerId });
      this.server.to(payload.gameId).emit('gameInfo', game);

      // Update public rooms as this one might be full now
      const publicRooms = await this.gameService.getPublicRooms();
      this.server.emit('publicRooms', publicRooms);
    } catch (e) {
      client.emit('room_error', e.message);
    }
  }

  @SubscribeMessage('cancelGame')
  async handleCancelGame(
    client: Socket,
    payload: { gameId: string; playerId: string },
  ) {
    try {
      await this.gameService.cancelGame(payload.gameId, payload.playerId);
      client.leave(payload.gameId);
      client.emit('gameCancelled', { gameId: payload.gameId });

      // Refresh public rooms
      const publicRooms = await this.gameService.getPublicRooms();
      this.server.emit('publicRooms', publicRooms);
    } catch (e) {
      client.emit('room_error', e.message);
    }
  }


  // ─────────────────────────────────────────────────────────────────────────
  // GAME EVENTS — unchanged
  // ─────────────────────────────────────────────────────────────────────────

  @SubscribeMessage('submitSecret')
  async handleSubmitSecret(
    client: Socket,
    payload: { gameId: string; playerId: string; secretNumber: string },
  ) {
    try {
      const updatedGame = await this.gameService.submitSecret(
        payload.gameId,
        payload.playerId,
        payload.secretNumber,
      );

      if (updatedGame.status === 'playing') {
        this.server.to(payload.gameId).emit('startGame', { gameId: payload.gameId });
      }
      this.server.to(payload.gameId).emit('gameInfo', updatedGame);
    } catch (e) {
      client.emit('room_error', e.message);
    }
  }

  @SubscribeMessage('newGame')
  async handleNewGame(
    client: Socket,
    payload: { gameId: string; playerId: string; approved?: boolean },
  ) {
    try {
      const resetSeries = payload.approved === true;
      const updatedGame = await this.gameService.resetMatch(payload.gameId, resetSeries);

      this.server.to(payload.gameId).emit('requestNewGame', {
        gameId: payload.gameId,
        playerId: payload.playerId,
        resetSeries,
        currentRound: updatedGame.currentRound,
        maxRounds: updatedGame.maxRounds,
      });
      this.server.to(payload.gameId).emit('gameInfo', updatedGame);
    } catch (e) {
      client.emit('room_error', e.message);
    }
  }

  @SubscribeMessage('makeGuess')
  async handleMakeGuess(
    client: Socket,
    payload: { gameId: string; playerId: string; guess: string },
  ) {
    try {
      const { updatedGame, feedback, isDraw, isTimeout } = await this.gameService.makeGuess(
        payload.gameId,
        payload.playerId,
        payload.guess,
      );

      this.server.to(payload.gameId).emit('feedback', {
        playerId: payload.playerId,
        guess: payload.guess,
        feedback,
      });

      this.server.to(payload.gameId).emit('updateGuesses', { guesses: updatedGame.guesses });

      if (updatedGame.status === 'finished') {
        if (isTimeout) {
          this.server.to(payload.gameId).emit('gameEnd', {
            winnerId: updatedGame.winnerId,
            message: 'Timeout! Game Over.',
            gameId: payload.gameId,
            player1Wins: updatedGame.player1Wins,
            player2Wins: updatedGame.player2Wins,
            maxRounds: updatedGame.maxRounds,
            currentRound: updatedGame.currentRound,
            roundHistory: updatedGame.roundHistory ?? [],
          });
        } else if (isDraw) {
          this.server.to(payload.gameId).emit('gameEnd', {
            winnerId: null,
            message: "It's a draw!",
            gameId: payload.gameId,
            player1Wins: updatedGame.player1Wins,
            player2Wins: updatedGame.player2Wins,
            maxRounds: updatedGame.maxRounds,
            currentRound: updatedGame.currentRound,
            roundHistory: updatedGame.roundHistory ?? [],
          });
        } else {
          this.server.to(payload.gameId).emit('gameEnd', {
            winnerId: updatedGame.winnerId,
            message: 'Game Over!',
            gameId: payload.gameId,
            player1Wins: updatedGame.player1Wins,
            player2Wins: updatedGame.player2Wins,
            maxRounds: updatedGame.maxRounds,
            currentRound: updatedGame.currentRound,
            roundHistory: updatedGame.roundHistory ?? [],
          });
        }
      } else if (updatedGame.lastChance) {
        const opponent = payload.playerId === updatedGame.player1Id
          ? updatedGame.player2Id
          : updatedGame.player1Id;
        this.server.to(payload.gameId).emit('lastChance', { chanceTo: opponent, message: 'There is last Chance' });
      } else {
        this.server.to(payload.gameId).emit('turnChange', { nextPlayer: updatedGame.turn });
      }

      this.server.to(payload.gameId).emit('gameInfo', updatedGame);

    } catch (e) {
      if (e.message === 'Not your turn') {
        client.emit('turnWait', { message: 'Please wait for your turn', player: payload.playerId });
      } else {
        client.emit('room_error', e.message);
      }
    }
  }

  @SubscribeMessage('chat')
  handleChat(
    client: Socket,
    payload: { gameId: string; playerId: string; message: string },
  ) {
    this.server.to(payload.gameId).emit('sendMessage', {
      gameId: payload.gameId,
      currentSender: payload.playerId,
      message: payload.message,
      timestamp: new Date().toISOString(),
    });
  }

  @SubscribeMessage('timeout')
  async handleTimeout(
    client: Socket,
    payload: { gameId: string; playerId: string },
  ) {
    try {
      const { updatedGame, isTimeout } = await this.gameService.makeGuess(
        payload.gameId,
        payload.playerId,
        'TIMEOUT_CHECK',
      );
      if (isTimeout && updatedGame.status === 'finished') {
        this.server.to(payload.gameId).emit('gameEnd', {
          winnerId: updatedGame.winnerId,
          message: 'Timeout! Game Over.',
        });
        this.server.to(payload.gameId).emit('gameInfo', updatedGame);
      }
    } catch (e) {
      // Ignore — e.g. "Not your turn" when the timeout fires on the wrong player
    }
  }
}
