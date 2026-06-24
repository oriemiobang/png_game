"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.GameModule = void 0;
const common_1 = require("@nestjs/common");
const game_gateway_1 = require("./game.gateway");
const game_service_1 = require("./game.service");
const matchmaking_service_1 = require("./matchmaking.service");
const rating_module_1 = require("../rating/rating.module");
const auth_module_1 = require("../auth/auth.module");
const ai_module_1 = require("../ai/ai.module");
const game_controller_1 = require("./game.controller");
let GameModule = class GameModule {
};
exports.GameModule = GameModule;
exports.GameModule = GameModule = __decorate([
    (0, common_1.Module)({
        imports: [rating_module_1.RatingModule, auth_module_1.AuthModule, ai_module_1.AiModule],
        controllers: [game_controller_1.GameController],
        providers: [game_gateway_1.GameGateway, game_service_1.GameService, matchmaking_service_1.MatchmakingService],
    })
], GameModule);
//# sourceMappingURL=game.module.js.map