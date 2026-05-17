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
let GameGateway = class GameGateway {
    constructor(gameService) {
        this.gameService = gameService;
    }
    handleConnection(client) {
        console.log(`Client connected: ${client.id}`);
    }
    handleDisconnect(client) {
        console.log(`Client disconnected: ${client.id}`);
    }
    async handleCreateGame(client, payload) {
        try {
            const game = await this.gameService.createGame(payload.gameId, payload.playerId, payload.settings);
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
        try {
            const game = await this.gameService.joinGame(payload.gameId, payload.playerId);
            client.join(payload.gameId);
            this.server.to(payload.gameId).emit('gameReady', { gameId: payload.gameId });
            this.server.emit('gameJoined', { gameJoined: true, gameId: payload.gameId, playerId: payload.playerId });
            this.server.to(payload.gameId).emit('gameInfo', game);
            const publicRooms = await this.gameService.getPublicRooms();
            this.server.emit('publicRooms', publicRooms);
        }
        catch (e) {
            client.emit('room_error', e.message);
        }
    }
    async handleSubmitSecret(client, payload) {
        try {
            const updatedGame = await this.gameService.submitSecret(payload.gameId, payload.playerId, payload.secretNumber);
            if (updatedGame.status === 'playing') {
                this.server.to(payload.gameId).emit('startGame', { gameId: payload.gameId });
            }
            this.server.to(payload.gameId).emit('gameInfo', updatedGame);
        }
        catch (e) {
            client.emit('room_error', e.message);
        }
    }
    async handleMakeGuess(client, payload) {
        try {
            const { updatedGame, feedback, isDraw, isTimeout } = await this.gameService.makeGuess(payload.gameId, payload.playerId, payload.guess);
            this.server.to(payload.gameId).emit('feedback', {
                playerId: payload.playerId,
                guess: payload.guess,
                feedback
            });
            this.server.to(payload.gameId).emit('updateGuesses', { guesses: updatedGame.guesses });
            if (updatedGame.status === 'finished') {
                if (isTimeout) {
                    this.server.to(payload.gameId).emit('gameEnd', { winnerId: updatedGame.winnerId, message: "Timeout! Game Over." });
                }
                else if (isDraw) {
                    this.server.to(payload.gameId).emit('gameEnd', { winnerId: null, message: "It's a draw!" });
                }
                else {
                    this.server.to(payload.gameId).emit('gameEnd', { winnerId: updatedGame.winnerId, message: "Game Over!" });
                }
            }
            else if (updatedGame.lastChance) {
                const opponent = payload.playerId === updatedGame.player1Id ? updatedGame.player2Id : updatedGame.player1Id;
                this.server.to(payload.gameId).emit('lastChance', { chanceTo: opponent, message: "There is last Chance" });
            }
            else {
                this.server.to(payload.gameId).emit('turnChange', { nextPlayer: updatedGame.turn });
            }
            this.server.to(payload.gameId).emit('gameInfo', updatedGame);
        }
        catch (e) {
            if (e.message === 'Not your turn') {
                client.emit('turnWait', { message: 'Please wait for your turn', player: payload.playerId });
            }
            else {
                client.emit('room_error', e.message);
            }
        }
    }
    handleChat(client, payload) {
        this.server.to(payload.gameId).emit('sendMessage', {
            gameId: payload.gameId,
            currentSender: payload.playerId,
            message: payload.message,
            timestamp: new Date().toISOString()
        });
    }
    async handleTimeout(client, payload) {
        try {
            const { updatedGame, isTimeout } = await this.gameService.makeGuess(payload.gameId, payload.playerId, 'TIMEOUT_CHECK');
            if (isTimeout && updatedGame.status === 'finished') {
                this.server.to(payload.gameId).emit('gameEnd', { winnerId: updatedGame.winnerId, message: "Timeout! Game Over." });
                this.server.to(payload.gameId).emit('gameInfo', updatedGame);
            }
        }
        catch (e) {
        }
    }
};
exports.GameGateway = GameGateway;
__decorate([
    (0, websockets_1.WebSocketServer)(),
    __metadata("design:type", socket_io_1.Server)
], GameGateway.prototype, "server", void 0);
__decorate([
    (0, websockets_1.SubscribeMessage)('createGame'),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [socket_io_1.Socket, Object]),
    __metadata("design:returntype", Promise)
], GameGateway.prototype, "handleCreateGame", null);
__decorate([
    (0, websockets_1.SubscribeMessage)('joinGame'),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [socket_io_1.Socket, Object]),
    __metadata("design:returntype", Promise)
], GameGateway.prototype, "handleJoinGame", null);
__decorate([
    (0, websockets_1.SubscribeMessage)('submitSecret'),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [socket_io_1.Socket, Object]),
    __metadata("design:returntype", Promise)
], GameGateway.prototype, "handleSubmitSecret", null);
__decorate([
    (0, websockets_1.SubscribeMessage)('makeGuess'),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [socket_io_1.Socket, Object]),
    __metadata("design:returntype", Promise)
], GameGateway.prototype, "handleMakeGuess", null);
__decorate([
    (0, websockets_1.SubscribeMessage)('chat'),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [socket_io_1.Socket, Object]),
    __metadata("design:returntype", void 0)
], GameGateway.prototype, "handleChat", null);
__decorate([
    (0, websockets_1.SubscribeMessage)('timeout'),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [socket_io_1.Socket, Object]),
    __metadata("design:returntype", Promise)
], GameGateway.prototype, "handleTimeout", null);
exports.GameGateway = GameGateway = __decorate([
    (0, websockets_1.WebSocketGateway)({ cors: { origin: '*' } }),
    __metadata("design:paramtypes", [game_service_1.GameService])
], GameGateway);
//# sourceMappingURL=game.gateway.js.map