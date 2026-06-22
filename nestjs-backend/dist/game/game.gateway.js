"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.GameGateway = void 0;
const websockets_1 = require("@nestjs/websockets");
const socket_io_1 = require("socket.io");
const game_service_1 = require("./game.service");
const matchmaking_service_1 = require("./matchmaking.service");
const common_1 = require("@nestjs/common");
const jwt_1 = require("@nestjs/jwt");
const ws_jwt_guard_1 = require("../auth/ws-jwt.guard");
const ws_throttler_guard_1 = require("./ws-throttler.guard");
const ws_exception_filter_1 = require("./ws-exception.filter");
const game_dto_1 = require("./dto/game.dto");
function generateGameId() {
    const hexChars = '0123456789abcdef';
    const suffix = Array.from({ length: 15 }, () => hexChars[Math.floor(Math.random() * 16)]).join('');
    return `PNG${suffix}`;
}
let GameGateway = class GameGateway {
    constructor(gameService, matchmakingService, jwtService) {
        this.gameService = gameService;
        this.matchmakingService = matchmakingService;
        this.jwtService = jwtService;
        this.activeTimers = new Map();
        this.disconnectTimers = new Map();
    }
    async handleRejoinGame(client, payload) {
        try {
            const playerId = client.data.userId;
            client.join(payload.gameId);
            const game = await this.gameService.getGameState(payload.gameId);
            if (game) {
                client.emit('gameInfo', game);
            }
            const timerKey = `${playerId}_${payload.gameId}`;
            if (this.disconnectTimers.has(timerKey)) {
                clearTimeout(this.disconnectTimers.get(timerKey));
                this.disconnectTimers.delete(timerKey);
                this.server.to(payload.gameId).emit('opponentReconnected', { gameId: payload.gameId, playerId });
            }
        }
        catch (e) {
            console.error('rejoin error', e);
        }
    }
    async handleLeaveGame(client, payload) {
        const playerId = client.data.userId;
        try {
            const result = await this.gameService.forfeitGame(payload.gameId, playerId);
            if (result) {
                this.server.to(payload.gameId).emit('gameEnd', result);
                client.leave(payload.gameId);
            }
        }
        catch (e) {
            console.error('Error leaving game', e);
            client.emit('room_error', 'Failed to leave game');
        }
    }
    async handleConnection(client) {
        try {
            const token = client.handshake.auth?.token;
            if (!token) {
                client.disconnect();
                return;
            }
            const payload = this.jwtService.verify(token);
            client.data.userId = payload.sub;
            const userId = client.data.userId;
        }
        catch (error) {
            client.disconnect();
        }
    }
    async handleDisconnect(client) {
        console.log(`Client disconnected: ${client.id}`);
        const userId = client.data?.userId;
        if (!userId)
            return;
        this.matchmakingService.removeBySocketId(client.id);
        this.matchmakingService.removeFromQueue(userId);
        try {
            const activeGameIds = await this.gameService.getActiveGamesForUser(userId);
            for (const gameId of activeGameIds) {
                this.server.to(gameId).emit('opponentDisconnected', { gameId, playerId: userId });
                const timerKey = `${userId}_${gameId}`;
                const timer = setTimeout(async () => {
                    try {
                        const currentGameState = await this.gameService.getGameState(gameId);
                        if (currentGameState && currentGameState.status === 'playing') {
                            const result = await this.gameService.forfeitGame(gameId, userId);
                            if (result) {
                                this.server.to(gameId).emit('gameEnd', result);
                            }
                        }
                    }
                    catch (e) { }
                    this.disconnectTimers.delete(timerKey);
                }, 60000);
                this.disconnectTimers.set(timerKey, timer);
            }
        }
        catch (e) {
            console.error('Error handling disconnect for', userId, e);
        }
    }
    async handleJoinQueue(client, payload) {
        const { maxRounds, timeLimit } = payload;
        const playerId = client.data.userId;
        try {
            const matched = this.matchmakingService.findMatch(playerId, maxRounds, timeLimit);
            if (matched) {
                const gameId = generateGameId();
                const game = await this.gameService.createGameForMatch(gameId, matched.playerId, playerId, { maxRounds, timeLimit });
                const matchPayload = {
                    gameId,
                    player1Id: matched.playerId,
                    player2Id: playerId,
                    maxRounds,
                    timeLimit,
                };
                client.join(gameId);
                const matchedSocket = this.server.sockets.sockets.get(matched.socketId);
                if (matchedSocket) {
                    matchedSocket.join(gameId);
                }
                this.server.to(gameId).emit('matchFound', matchPayload);
                this.server.to(gameId).emit('gameInfo', game);
                const publicRooms = await this.gameService.getPublicRooms();
                this.server.emit('publicRooms', publicRooms);
            }
            else {
                this.matchmakingService.addToQueue(playerId, client.id, maxRounds, timeLimit, () => {
                    client.emit('matchmakingTimeout', {});
                });
                client.emit('searchingForMatch', { maxRounds, timeLimit });
            }
        }
        catch (e) {
            client.emit('room_error', e.message);
        }
    }
    handleCancelMatchmaking(client, payload) {
        const playerId = client.data.userId;
        const removed = this.matchmakingService.removeFromQueue(playerId);
        client.emit('matchmakingCancelled', { removed });
    }
    async handleCreateGame(client, payload) {
        const playerId = client.data.userId;
        try {
            const game = await this.gameService.createGame(payload.gameId, playerId, payload.settings);
            client.join(payload.gameId);
            this.server.to(payload.gameId).emit('gameCreated', { gameId: payload.gameId });
            this.server.to(payload.gameId).emit('gameInfo', game);
            const publicRooms = await this.gameService.getPublicRooms();
            this.server.emit('publicRooms', publicRooms);
        }
        catch (e) {
            client.emit('room_error', e.message);
        }
    }
    async handleJoinGame(client, payload) {
        const playerId = client.data.userId;
        try {
            const game = await this.gameService.joinGame(payload.gameId, playerId);
            client.join(payload.gameId);
            this.server.to(payload.gameId).emit('playerJoined', {
                playerId,
                playerName: game.player2?.name ?? 'Opponent',
            });
            this.server.emit('gameJoined', { gameJoined: true, gameId: payload.gameId, playerId });
            this.server.to(payload.gameId).emit('gameInfo', game);
            const publicRooms = await this.gameService.getPublicRooms();
            this.server.emit('publicRooms', publicRooms);
        }
        catch (e) {
            client.emit('room_error', e.message);
        }
    }
    async handleCancelGame(client, payload) {
        const playerId = client.data.userId;
        try {
            await this.gameService.cancelGame(payload.gameId, playerId);
            client.leave(payload.gameId);
            client.emit('gameCancelled', { gameId: payload.gameId });
            const publicRooms = await this.gameService.getPublicRooms();
            this.server.emit('publicRooms', publicRooms);
        }
        catch (e) {
            client.emit('room_error', e.message);
        }
    }
    async handleSubmitSecret(client, payload) {
        const playerId = client.data.userId;
        try {
            const updatedGame = await this.gameService.submitSecret(payload.gameId, playerId, payload.secretNumber);
            if (updatedGame.status === 'playing') {
                this.server.to(payload.gameId).emit('startGame', { gameId: payload.gameId });
                this.scheduleGameTimer(updatedGame);
            }
            this.server.to(payload.gameId).emit('gameInfo', updatedGame);
        }
        catch (e) {
            client.emit('room_error', e.message);
        }
    }
    async handleNewGame(client, payload) {
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
        }
        catch (e) {
            client.emit('room_error', e.message);
        }
    }
    async handleMakeGuess(client, payload) {
        const playerId = client.data.userId;
        try {
            const { updatedGame, feedback, isDraw, isTimeout, ratingChanges } = await this.gameService.makeGuess(payload.gameId, playerId, payload.guess);
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
                }
                else if (isDraw) {
                    this.server.to(payload.gameId).emit('gameEnd', {
                        ...baseGameEndPayload,
                        winnerId: null,
                        message: "It's a draw!",
                    });
                }
                else {
                    this.server.to(payload.gameId).emit('gameEnd', {
                        ...baseGameEndPayload,
                        winnerId: updatedGame.winnerId,
                        message: 'Game Over!',
                    });
                }
            }
            else if (updatedGame.lastChance) {
                const opponent = playerId === updatedGame.player1Id
                    ? updatedGame.player2Id
                    : updatedGame.player1Id;
                this.server.to(payload.gameId).emit('lastChance', { chanceTo: opponent, message: 'There is last Chance' });
            }
            else {
                this.server.to(payload.gameId).emit('turnChange', { nextPlayer: updatedGame.turn });
            }
            if (updatedGame.status === 'playing') {
                this.scheduleGameTimer(updatedGame);
            }
            else {
                this.clearGameTimer(payload.gameId);
            }
            this.server.to(payload.gameId).emit('gameInfo', updatedGame);
        }
        catch (e) {
            if (e.message === 'Not your turn') {
                client.emit('turnWait', { message: 'Please wait for your turn', player: playerId });
            }
            else {
                client.emit('room_error', e.message);
            }
        }
    }
    handleChat(client, payload) {
        const playerId = client.data.userId;
        this.server.to(payload.gameId).emit('sendMessage', {
            gameId: payload.gameId,
            currentSender: playerId,
            message: payload.message,
            timestamp: new Date().toISOString(),
        });
    }
    async handleTimeout(client, payload) {
        const playerId = client.data.userId;
        try {
            const { updatedGame, isTimeout, ratingChanges } = await this.gameService.makeGuess(payload.gameId, playerId, 'TIMEOUT_CHECK');
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
        }
        catch (e) {
        }
    }
    clearGameTimer(gameId) {
        if (this.activeTimers.has(gameId)) {
            clearTimeout(this.activeTimers.get(gameId));
            this.activeTimers.delete(gameId);
        }
    }
    scheduleGameTimer(game) {
        this.clearGameTimer(game.id);
        if (game.timeLimit <= 0)
            return;
        const timeLeftMs = game.turn === game.player1Id ? game.player1TimeLeft : game.player2TimeLeft;
        const delay = Math.max(0, timeLeftMs) + 500;
        const timer = setTimeout(() => {
            this.executeServerTimeout(game.id, game.turn);
        }, delay);
        this.activeTimers.set(game.id, timer);
    }
    async executeServerTimeout(gameId, playerId) {
        this.clearGameTimer(gameId);
        try {
            const { updatedGame, isTimeout, ratingChanges } = await this.gameService.makeGuess(gameId, playerId, 'TIMEOUT_CHECK');
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
        }
        catch (e) {
            console.error('Server timeout execution failed:', e.message);
        }
    }
};
exports.GameGateway = GameGateway;
__decorate([
    (0, websockets_1.WebSocketServer)(),
    __metadata("design:type", socket_io_1.Server)
], GameGateway.prototype, "server", void 0);
__decorate([
    (0, websockets_1.SubscribeMessage)('rejoinGame'),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [socket_io_1.Socket, game_dto_1.RejoinGameDto]),
    __metadata("design:returntype", Promise)
], GameGateway.prototype, "handleRejoinGame", null);
__decorate([
    (0, websockets_1.SubscribeMessage)('leaveGame'),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [socket_io_1.Socket,
        game_dto_1.LeaveGameDto]),
    __metadata("design:returntype", Promise)
], GameGateway.prototype, "handleLeaveGame", null);
__decorate([
    (0, websockets_1.SubscribeMessage)('joinQueue'),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [socket_io_1.Socket,
        game_dto_1.JoinQueueDto]),
    __metadata("design:returntype", Promise)
], GameGateway.prototype, "handleJoinQueue", null);
__decorate([
    (0, websockets_1.SubscribeMessage)('cancelMatchmaking'),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [socket_io_1.Socket, Object]),
    __metadata("design:returntype", void 0)
], GameGateway.prototype, "handleCancelMatchmaking", null);
__decorate([
    (0, websockets_1.SubscribeMessage)('createGame'),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [socket_io_1.Socket,
        game_dto_1.CreateGameDto]),
    __metadata("design:returntype", Promise)
], GameGateway.prototype, "handleCreateGame", null);
__decorate([
    (0, websockets_1.SubscribeMessage)('joinGame'),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [socket_io_1.Socket,
        game_dto_1.JoinGameDto]),
    __metadata("design:returntype", Promise)
], GameGateway.prototype, "handleJoinGame", null);
__decorate([
    (0, websockets_1.SubscribeMessage)('cancelGame'),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [socket_io_1.Socket,
        game_dto_1.CancelGameDto]),
    __metadata("design:returntype", Promise)
], GameGateway.prototype, "handleCancelGame", null);
__decorate([
    (0, websockets_1.SubscribeMessage)('submitSecret'),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [socket_io_1.Socket,
        game_dto_1.SubmitSecretDto]),
    __metadata("design:returntype", Promise)
], GameGateway.prototype, "handleSubmitSecret", null);
__decorate([
    (0, websockets_1.SubscribeMessage)('newGame'),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [socket_io_1.Socket,
        game_dto_1.NewGameDto]),
    __metadata("design:returntype", Promise)
], GameGateway.prototype, "handleNewGame", null);
__decorate([
    (0, websockets_1.SubscribeMessage)('makeGuess'),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [socket_io_1.Socket,
        game_dto_1.MakeGuessDto]),
    __metadata("design:returntype", Promise)
], GameGateway.prototype, "handleMakeGuess", null);
__decorate([
    (0, websockets_1.SubscribeMessage)('chat'),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [socket_io_1.Socket,
        game_dto_1.ChatDto]),
    __metadata("design:returntype", void 0)
], GameGateway.prototype, "handleChat", null);
__decorate([
    (0, websockets_1.SubscribeMessage)('timeout'),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [socket_io_1.Socket,
        game_dto_1.TimeoutDto]),
    __metadata("design:returntype", Promise)
], GameGateway.prototype, "handleTimeout", null);
exports.GameGateway = GameGateway = __decorate([
    (0, common_1.UseFilters)(new ws_exception_filter_1.WsAllExceptionsFilter()),
    (0, common_1.UsePipes)(new common_1.ValidationPipe({ transform: true, whitelist: true })),
    (0, common_1.UseGuards)(ws_throttler_guard_1.WsThrottlerGuard, ws_jwt_guard_1.WsJwtGuard),
    (0, websockets_1.WebSocketGateway)({ cors: { origin: '*' } }),
    __metadata("design:paramtypes", [game_service_1.GameService,
        matchmaking_service_1.MatchmakingService,
        jwt_1.JwtService])
], GameGateway);
//# sourceMappingURL=game.gateway.js.map