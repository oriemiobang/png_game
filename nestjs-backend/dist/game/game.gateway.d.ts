import { OnGatewayConnection, OnGatewayDisconnect } from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';
import { GameService } from './game.service';
export declare class GameGateway implements OnGatewayConnection, OnGatewayDisconnect {
    private readonly gameService;
    server: Server;
    constructor(gameService: GameService);
    handleConnection(client: Socket): void;
    handleDisconnect(client: Socket): void;
    handleCreateGame(client: Socket, payload: {
        playerId: string;
        gameId: string;
        settings?: any;
    }): Promise<void>;
    handleJoinGame(client: Socket, payload: {
        gameId: string;
        playerId: string;
    }): Promise<void>;
    handleSubmitSecret(client: Socket, payload: {
        gameId: string;
        playerId: string;
        secretNumber: string;
    }): Promise<void>;
    handleMakeGuess(client: Socket, payload: {
        gameId: string;
        playerId: string;
        guess: string;
    }): Promise<void>;
    handleChat(client: Socket, payload: {
        gameId: string;
        playerId: string;
        message: string;
    }): void;
    handleTimeout(client: Socket, payload: {
        gameId: string;
        playerId: string;
    }): Promise<void>;
}
