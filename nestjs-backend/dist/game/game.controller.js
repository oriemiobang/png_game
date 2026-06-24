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
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.GameController = void 0;
const common_1 = require("@nestjs/common");
const game_service_1 = require("./game.service");
const passport_1 = require("@nestjs/passport");
let GameController = class GameController {
    constructor(gameService) {
        this.gameService = gameService;
    }
    async getGameDetails(gameId, req) {
        const userId = req.user.userId;
        return this.gameService.getGameDetails(gameId, userId);
    }
    async analyzeGuess(gameId, guessIndexStr, req) {
        const userId = req.user.userId;
        const guessIndex = parseInt(guessIndexStr, 10);
        if (isNaN(guessIndex) || guessIndex < 0) {
            throw new common_1.HttpException('Invalid guess index', common_1.HttpStatus.BAD_REQUEST);
        }
        return this.gameService.analyzeGuess(gameId, userId, guessIndex);
    }
};
exports.GameController = GameController;
__decorate([
    (0, common_1.Get)(':id'),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object]),
    __metadata("design:returntype", Promise)
], GameController.prototype, "getGameDetails", null);
__decorate([
    (0, common_1.Get)(':id/analyze/:guessIndex'),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Param)('guessIndex')),
    __param(2, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String, Object]),
    __metadata("design:returntype", Promise)
], GameController.prototype, "analyzeGuess", null);
exports.GameController = GameController = __decorate([
    (0, common_1.Controller)('game'),
    (0, common_1.UseGuards)((0, passport_1.AuthGuard)('jwt')),
    __metadata("design:paramtypes", [game_service_1.GameService])
], GameController);
//# sourceMappingURL=game.controller.js.map