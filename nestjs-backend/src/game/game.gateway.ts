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
import { UseGuards, UsePipes, ValidationPipe, UseFilters } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { WsJwtGuard } from '../auth/ws-jwt.guard';
import { WsThrottlerGuard } from './ws-throttler.guard';
import { WsAllExceptionsFilter } from './ws-exception.filter';
import {
  JoinQueueDto,
  CreateGameDto,
  JoinGameDto,
  CancelGameDto,
  SubmitSecretDto,
  MakeGuessDto,
  ChatDto,
  TimeoutDto,
  RejoinGameDto,
  NewGameDto,
  LeaveGameDto,
} from './dto/game.dto';

// Utility: generate a random game ID
function generateGameId(): string {
  const hexChars = '0123456789abcdef';
  const suffix = Array.from(
    { length: 15 },
    () => hexChars[Math.floor(Math.random() * 16)],
  ).join('');
  return `PNG${suffix}`;
}

@UseFilters(new WsAllExceptionsFilter())
@UsePipes(new ValidationPipe({ transform: true, whitelist: true }))
@UseGuards(WsThrottlerGuard, WsJwtGuard)
@WebSocketGateway({ cors: { origin: '*' } })
export class GameGateway implements OnGatewayConnection, OnGatewayDisconnect {
  @WebSocketServer() server: Server;
  
  private activeTimers = new Map<string, NodeJS.Timeout>();
  private disconnectTimers = new Map<string, NodeJS.Timeout>();

  constructor(
    private readonly gameService: GameService,
    private readonly matchmakingService: MatchmakingService,
    private readonly jwtService: JwtService,
  ) {}

  /**
   * Enriches each guess in the game state with a `colorFeedback` array.
   * Each element is 'P' (correct position), 'N' (correct digit, wrong position), or 'X' (not in secret).
   * This avoids any DB schema changes – it's computed on-the-fly before sending to clients.
   */
  private attachColorFeedback(game: any): any {
    if (!game || !game.guesses) return game;

    const enrichedGuesses = game.guesses.map((g: any) => {
      const secret = g.playerId === game.player1Id ? game.player2Secret : game.player1Secret;
      if (!secret || secret.length !== 4) return g;

      const colorFeedback = g.guess.split('').map((digit: string, i: number) => {
        if (secret[i] === digit) return 'P';
        if (secret.includes(digit)) return 'N';
        return 'X';
      });

      return { ...g, colorFeedback };
    });

    return { ...game, guesses: enrichedGuesses };
  }

  @SubscribeMessage('rejoinGame')
  async handleRejoinGame(client: Socket, payload: RejoinGameDto) {
    try {
      const playerId = client.data.userId;
      client.join(payload.gameId);
      const game = await this.gameService.getGameState(payload.gameId);
      if (game) {
        client.emit('gameInfo', this.attachColorFeedback(game));
      }
      
      const timerKey = `${playerId}_${payload.gameId}`;
      if (this.disconnectTimers.has(timerKey)) {
        clearTimeout(this.disconnectTimers.get(timerKey));
        this.disconnectTimers.delete(timerKey);
        this.server.to(payload.gameId).emit('opponentReconnected', { gameId: payload.gameId, playerId });
      }
    } catch (e) {
      console.error('rejoin error', e);
    }
  }

  @SubscribeMessage('leaveGame')
  async handleLeaveGame(
    client: Socket,
    payload: LeaveGameDto,
  ) {
    const playerId = client.data.userId;
    try {
      const result = await this.gameService.forfeitGame(payload.gameId, playerId);
      if (result) {
        const { updatedGame, ratingChanges } = result;
        this.server.to(payload.gameId).emit('gameEnd', {
          gameId: payload.gameId,
          player1Wins: updatedGame.player1Wins,
          player2Wins: updatedGame.player2Wins,
          maxRounds: updatedGame.maxRounds,
          currentRound: updatedGame.currentRound,
          roundHistory: updatedGame.roundHistory ?? [],
          ratingChanges,
          winnerId: updatedGame.winnerId,
          message: 'Opponent Forfeited! You win.',
        });
        // Clean up room
        client.leave(payload.gameId);
      }
    } catch (e) {
      console.error('Error leaving game', e);
      client.emit('room_error', 'Failed to leave game');
    }
  }

  async handleConnection(client: Socket) {
    try {
      const token = client.handshake.auth?.token;
      if (!token) {
        client.disconnect();
        return;
      }
      
      const payload = this.jwtService.verify(token);
      client.data.userId = payload.sub;

      const userId = client.data.userId;
      // We don't know which game they are rejoining until they emit rejoinGame, 
      // but we will clear timers in rejoinGame.

    } catch (error) {
      client.disconnect();
    }
  }

  async handleDisconnect(client: Socket) {
    console.log(`Client disconnected: ${client.id}`);
    const userId = client.data?.userId;
    if (!userId) return;
    
    this.matchmakingService.removeBySocketId(client.id);
    this.matchmakingService.removeFromQueue(userId);

    // Find active games
    try {
      const activeGameIds = await this.gameService.getActiveGamesForUser(userId);
      for (const gameId of activeGameIds) {
        this.server.to(gameId).emit('opponentDisconnected', { gameId, playerId: userId });

        const timerKey = `${userId}_${gameId}`;
        const timer = setTimeout(async () => {
          // Time is up. If game is still active, forfeit
          try {
            const currentGameState = await this.gameService.getGameState(gameId);
            if (currentGameState && currentGameState.status === 'playing') {
              const result = await this.gameService.forfeitGame(gameId, userId);
              if (result) {
                const { updatedGame, ratingChanges } = result;
                this.server.to(gameId).emit('gameEnd', {
                  gameId,
                  player1Wins: updatedGame.player1Wins,
                  player2Wins: updatedGame.player2Wins,
                  maxRounds: updatedGame.maxRounds,
                  currentRound: updatedGame.currentRound,
                  roundHistory: updatedGame.roundHistory ?? [],
                  ratingChanges,
                  winnerId: updatedGame.winnerId,
                  message: 'Opponent disconnected. You win.',
                });
              }
            }
          } catch (e) {}
          this.disconnectTimers.delete(timerKey);
        }, 60000); // 60 seconds grace period

        this.disconnectTimers.set(timerKey, timer);
      }
    } catch (e) {
      console.error('Error handling disconnect for', userId, e);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // MATCHMAKING — new auto-pairing flow
  // ─────────────────────────────────────────────────────────────────────────

  @SubscribeMessage('joinQueue')
  async handleJoinQueue(
    client: Socket,
    payload: JoinQueueDto,
  ) {
    const { maxRounds, timeLimit } = payload;
    const playerId = client.data.userId;

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
    payload: { playerId?: string },
  ) {
    const playerId = client.data.userId;
    const removed = this.matchmakingService.removeFromQueue(playerId);
    client.emit('matchmakingCancelled', { removed });
  }

  // ─────────────────────────────────────────────────────────────────────────
  // PRIVATE ROOM — kept unchanged for the invite / QR flow
  // ─────────────────────────────────────────────────────────────────────────

  @SubscribeMessage('createGame')
  async handleCreateGame(
    client: Socket,
    payload: CreateGameDto,
  ) {
    const playerId = client.data.userId;
    try {
      const game = await this.gameService.createGame(
        payload.gameId,
        playerId,
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
    payload: JoinGameDto,
  ) {
    const playerId = client.data.userId;
    try {
      const game = await this.gameService.joinGame(payload.gameId, playerId);
      client.join(payload.gameId);

      // Notify the host that an opponent joined (with their name for the UI)
      this.server.to(payload.gameId).emit('playerJoined', {
        playerId,
        playerName: (game as any).player2?.name ?? 'Opponent',
      });
      this.server.emit('gameJoined', { gameJoined: true, gameId: payload.gameId, playerId });
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
    payload: CancelGameDto,
  ) {
    const playerId = client.data.userId;
    try {
      await this.gameService.cancelGame(payload.gameId, playerId);
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
    payload: SubmitSecretDto,
  ) {
    const playerId = client.data.userId;
    try {
      const updatedGame = await this.gameService.submitSecret(
        payload.gameId,
        playerId,
        payload.secretNumber,
      );

      if (updatedGame.status === 'playing') {
        this.server.to(payload.gameId).emit('startGame', { gameId: payload.gameId });
        this.scheduleGameTimer(updatedGame);
      }
      this.server.to(payload.gameId).emit('gameInfo', updatedGame);
    } catch (e) {
      client.emit('room_error', e.message);
    }
  }

  @SubscribeMessage('newGame')
  async handleNewGame(
    client: Socket,
    payload: NewGameDto,
  ) {
    const playerId = client.data.userId;
    try {
      const resetSeries = payload.approved === true;
      const updatedGame = await this.gameService.resetMatch(payload.gameId, resetSeries);

      this.server.to(payload.gameId).emit('requestNewGame', {
        gameId: payload.gameId,
        playerId,
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
    payload: MakeGuessDto,
  ) {
    const playerId = client.data.userId;
    try {
      const { updatedGame, feedback, isDraw, isTimeout, ratingChanges } = await this.gameService.makeGuess(
        payload.gameId,
        playerId,
        payload.guess,
      );

      this.server.to(payload.gameId).emit('feedback', {
        playerId,
        guess: payload.guess,
        feedback,
      });

      this.server.to(payload.gameId).emit('updateGuesses', { guesses: updatedGame.guesses });

      if (updatedGame.status === 'finished') {
        const baseGameEndPayload = {
          gameId: payload.gameId,
          player1Wins: updatedGame.player1Wins,
          player2Wins: updatedGame.player2Wins,
          maxRounds: updatedGame.maxRounds,
          currentRound: updatedGame.currentRound,
          roundHistory: updatedGame.roundHistory ?? [],
          ratingChanges,
        };

        if (isTimeout) {
          this.server.to(payload.gameId).emit('gameEnd', {
            ...baseGameEndPayload,
            winnerId: updatedGame.winnerId,
            message: 'Timeout! Game Over.',
          });
        } else if (isDraw) {
          this.server.to(payload.gameId).emit('gameEnd', {
            ...baseGameEndPayload,
            winnerId: null,
            message: "It's a draw!",
          });
        } else {
          this.server.to(payload.gameId).emit('gameEnd', {
            ...baseGameEndPayload,
            winnerId: updatedGame.winnerId,
            message: 'Game Over!',
          });
        }
      } else if (updatedGame.lastChance) {
        const opponent = playerId === updatedGame.player1Id
          ? updatedGame.player2Id
          : updatedGame.player1Id;
        this.server.to(payload.gameId).emit('lastChance', { chanceTo: opponent, message: 'There is last Chance' });
      } else {
        this.server.to(payload.gameId).emit('turnChange', { nextPlayer: updatedGame.turn });
      }

      if (updatedGame.status === 'playing') {
        this.scheduleGameTimer(updatedGame);
      } else {
        this.clearGameTimer(payload.gameId);
      }

      this.server.to(payload.gameId).emit('gameInfo', this.attachColorFeedback(updatedGame));

    } catch (e) {
      if (e.message === 'Not your turn') {
        client.emit('turnWait', { message: 'Please wait for your turn', player: playerId });
      } else {
        client.emit('room_error', e.message);
      }
    }
  }

  @SubscribeMessage('chat')
  handleChat(
    client: Socket,
    payload: ChatDto,
  ) {
    const playerId = client.data.userId;
    this.server.to(payload.gameId).emit('sendMessage', {
      gameId: payload.gameId,
      currentSender: playerId,
      message: payload.message,
      timestamp: new Date().toISOString(),
    });
  }

  @SubscribeMessage('timeout')
  async handleTimeout(
    client: Socket,
    payload: TimeoutDto,
  ) {
    const playerId = client.data.userId;
    try {
      const { updatedGame, isTimeout, ratingChanges } = await this.gameService.makeGuess(
        payload.gameId,
        playerId,
        'TIMEOUT_CHECK',
      );
      if (isTimeout && updatedGame.status === 'finished') {
        this.server.to(payload.gameId).emit('gameEnd', {
          gameId: payload.gameId,
          player1Wins: updatedGame.player1Wins,
          player2Wins: updatedGame.player2Wins,
          maxRounds: updatedGame.maxRounds,
          currentRound: updatedGame.currentRound,
          roundHistory: updatedGame.roundHistory ?? [],
          ratingChanges,
          winnerId: updatedGame.winnerId,
          message: 'Timeout! Game Over.',
        });
        this.server.to(payload.gameId).emit('gameInfo', updatedGame);
      }
    } catch (e) {
      // Ignore — e.g. "Not your turn" when the timeout fires on the wrong player
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SERVER-SIDE TIMEOUTS
  // ─────────────────────────────────────────────────────────────────────────
  private clearGameTimer(gameId: string) {
    if (this.activeTimers.has(gameId)) {
      clearTimeout(this.activeTimers.get(gameId));
      this.activeTimers.delete(gameId);
    }
  }

  private scheduleGameTimer(game: any) {
    this.clearGameTimer(game.id);

    if (game.timeLimit <= 0) return; // No timer for this game

    const timeLeftMs = game.turn === game.player1Id ? game.player1TimeLeft : game.player2TimeLeft;
    
    // Add a slight buffer (e.g. 500ms) to allow client's last-second network request to arrive
    const delay = Math.max(0, timeLeftMs) + 500; 

    const timer = setTimeout(() => {
      this.executeServerTimeout(game.id, game.turn);
    }, delay);

    this.activeTimers.set(game.id, timer);
  }

  private async executeServerTimeout(gameId: string, playerId: string) {
    this.clearGameTimer(gameId);
    try {
      const { updatedGame, isTimeout, ratingChanges } = await this.gameService.makeGuess(
        gameId,
        playerId,
        'TIMEOUT_CHECK',
      );
      if (isTimeout && updatedGame.status === 'finished') {
        this.server.to(gameId).emit('gameEnd', {
          gameId,
          player1Wins: updatedGame.player1Wins,
          player2Wins: updatedGame.player2Wins,
          maxRounds: updatedGame.maxRounds,
          currentRound: updatedGame.currentRound,
          roundHistory: updatedGame.roundHistory ?? [],
          ratingChanges,
          winnerId: updatedGame.winnerId,
          message: 'Timeout! Game Over.',
        });
        this.server.to(gameId).emit('gameInfo', updatedGame);
      }
    } catch (e) {
      console.error('Server timeout execution failed:', e.message);
    }
  }
}
