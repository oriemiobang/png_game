import {
  WebSocketGateway,
  WebSocketServer,
  SubscribeMessage,
  OnGatewayConnection,
  OnGatewayDisconnect,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';
import { GameService } from './game.service';

@WebSocketGateway({ cors: { origin: '*' } })
export class GameGateway implements OnGatewayConnection, OnGatewayDisconnect {
  @WebSocketServer() server: Server;

  constructor(private readonly gameService: GameService) {}

  handleConnection(client: Socket) {
    console.log(`Client connected: ${client.id}`);
  }

  handleDisconnect(client: Socket) {
    console.log(`Client disconnected: ${client.id}`);
  }

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
      
      this.server.to(payload.gameId).emit('gameReady', { gameId: payload.gameId });
      this.server.emit('gameJoined', { gameJoined: true, gameId: payload.gameId, playerId: payload.playerId });
      this.server.to(payload.gameId).emit('gameInfo', game);
      
      // Update public rooms as this one might be full now
      const publicRooms = await this.gameService.getPublicRooms();
      this.server.emit('publicRooms', publicRooms);
    } catch (e) {
      client.emit('room_error', e.message);
    }
  }

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
        feedback 
      });
      
      this.server.to(payload.gameId).emit('updateGuesses', { guesses: updatedGame.guesses });

      if (updatedGame.status === 'finished') {
        if (isTimeout) {
          this.server.to(payload.gameId).emit('gameEnd', { winnerId: updatedGame.winnerId, message: "Timeout! Game Over." });
        } else if (isDraw) {
          this.server.to(payload.gameId).emit('gameEnd', { winnerId: null, message: "It's a draw!" });
        } else {
          this.server.to(payload.gameId).emit('gameEnd', { winnerId: updatedGame.winnerId, message: "Game Over!" });
        }
      } else if (updatedGame.lastChance) {
        const opponent = payload.playerId === updatedGame.player1Id ? updatedGame.player2Id : updatedGame.player1Id;
        this.server.to(payload.gameId).emit('lastChance', { chanceTo: opponent, message: "There is last Chance" });
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
    // Chat messages are broadcasted but not saved to the DB
    this.server.to(payload.gameId).emit('sendMessage', {
      gameId: payload.gameId,
      currentSender: payload.playerId,
      message: payload.message,
      timestamp: new Date().toISOString()
    });
  }

  @SubscribeMessage('timeout')
  async handleTimeout(
    client: Socket,
    payload: { gameId: string; playerId: string },
  ) {
    try {
      // Just make a dummy guess that will force the timeout logic to trigger
      // Because makeGuess already calculates elapsed time and fails the user if they're out of time.
      // But wait, if they really timed out, makeGuess will correctly finish the game and return isTimeout.
      const { updatedGame, isTimeout } = await this.gameService.makeGuess(
        payload.gameId,
        payload.playerId,
        'TIMEOUT_CHECK'
      );
      if (isTimeout && updatedGame.status === 'finished') {
         this.server.to(payload.gameId).emit('gameEnd', { winnerId: updatedGame.winnerId, message: "Timeout! Game Over." });
         this.server.to(payload.gameId).emit('gameInfo', updatedGame);
      }
    } catch (e) {
      // Ignore if it throws (e.g. invalid guess format or not their turn)
      // Actually if they are not their turn, it throws 'Not your turn', which is fine
    }
  }
}
