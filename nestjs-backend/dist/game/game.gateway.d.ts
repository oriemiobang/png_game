import { OnGatewayConnection, OnGatewayDisconnect } from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';
import { GameService } from './game.service';
import { MatchmakingService } from './matchmaking.service';
import { JwtService } from '@nestjs/jwt';
import { JoinQueueDto, CreateGameDto, JoinGameDto, CancelGameDto, SubmitSecretDto, MakeGuessDto, ChatDto, TimeoutDto, RejoinGameDto, NewGameDto, LeaveGameDto } from './dto/game.dto';
export declare class GameGateway implements OnGatewayConnection, OnGatewayDisconnect {
    private readonly gameService;
    private readonly matchmakingService;
    private readonly jwtService;
    server: Server;
    private activeTimers;
    private disconnectTimers;
    constructor(gameService: GameService, matchmakingService: MatchmakingService, jwtService: JwtService);
    handleRejoinGame(client: Socket, payload: RejoinGameDto): Promise<void>;
    handleLeaveGame(client: Socket, payload: LeaveGameDto): Promise<void>;
    handleConnection(client: Socket): Promise<void>;
    handleDisconnect(client: Socket): Promise<void>;
    handleJoinQueue(client: Socket, payload: JoinQueueDto): Promise<void>;
    handleCancelMatchmaking(client: Socket, payload: {
        playerId?: string;
    }): void;
    handleCreateGame(client: Socket, payload: CreateGameDto): Promise<void>;
    handleJoinGame(client: Socket, payload: JoinGameDto): Promise<void>;
    handleCancelGame(client: Socket, payload: CancelGameDto): Promise<void>;
    handleSubmitSecret(client: Socket, payload: SubmitSecretDto): Promise<void>;
    handleNewGame(client: Socket, payload: NewGameDto): Promise<void>;
    handleMakeGuess(client: Socket, payload: MakeGuessDto): Promise<void>;
    handleChat(client: Socket, payload: ChatDto): void;
    handleTimeout(client: Socket, payload: TimeoutDto): Promise<void>;
    private clearGameTimer;
    private scheduleGameTimer;
    private executeServerTimeout;
}
