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
exports.LeaveGameDto = exports.NewGameDto = exports.RejoinGameDto = exports.TimeoutDto = exports.ChatDto = exports.MakeGuessDto = exports.SubmitSecretDto = exports.CancelGameDto = exports.JoinGameDto = exports.CreateGameDto = exports.JoinQueueDto = void 0;
const class_validator_1 = require("class-validator");
class JoinQueueDto {
}
exports.JoinQueueDto = JoinQueueDto;
__decorate([
    (0, class_validator_1.IsNumber)(),
    (0, class_validator_1.Min)(1),
    (0, class_validator_1.Max)(10),
    __metadata("design:type", Number)
], JoinQueueDto.prototype, "maxRounds", void 0);
__decorate([
    (0, class_validator_1.IsNumber)(),
    (0, class_validator_1.Min)(0),
    __metadata("design:type", Number)
], JoinQueueDto.prototype, "timeLimit", void 0);
class CreateGameDto {
}
exports.CreateGameDto = CreateGameDto;
__decorate([
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsNotEmpty)(),
    __metadata("design:type", String)
], CreateGameDto.prototype, "gameId", void 0);
__decorate([
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", Object)
], CreateGameDto.prototype, "settings", void 0);
class JoinGameDto {
}
exports.JoinGameDto = JoinGameDto;
__decorate([
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsNotEmpty)(),
    __metadata("design:type", String)
], JoinGameDto.prototype, "gameId", void 0);
class CancelGameDto {
}
exports.CancelGameDto = CancelGameDto;
__decorate([
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsNotEmpty)(),
    __metadata("design:type", String)
], CancelGameDto.prototype, "gameId", void 0);
class SubmitSecretDto {
}
exports.SubmitSecretDto = SubmitSecretDto;
__decorate([
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsNotEmpty)(),
    __metadata("design:type", String)
], SubmitSecretDto.prototype, "gameId", void 0);
__decorate([
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.Length)(4, 4),
    __metadata("design:type", String)
], SubmitSecretDto.prototype, "secretNumber", void 0);
class MakeGuessDto {
}
exports.MakeGuessDto = MakeGuessDto;
__decorate([
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsNotEmpty)(),
    __metadata("design:type", String)
], MakeGuessDto.prototype, "gameId", void 0);
__decorate([
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.Length)(4, 4, { message: 'guess must be exactly 4 characters' }),
    __metadata("design:type", String)
], MakeGuessDto.prototype, "guess", void 0);
class ChatDto {
}
exports.ChatDto = ChatDto;
__decorate([
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsNotEmpty)(),
    __metadata("design:type", String)
], ChatDto.prototype, "gameId", void 0);
__decorate([
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsNotEmpty)(),
    __metadata("design:type", String)
], ChatDto.prototype, "message", void 0);
class TimeoutDto {
}
exports.TimeoutDto = TimeoutDto;
__decorate([
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsNotEmpty)(),
    __metadata("design:type", String)
], TimeoutDto.prototype, "gameId", void 0);
class RejoinGameDto {
}
exports.RejoinGameDto = RejoinGameDto;
__decorate([
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsNotEmpty)(),
    __metadata("design:type", String)
], RejoinGameDto.prototype, "gameId", void 0);
class NewGameDto {
}
exports.NewGameDto = NewGameDto;
__decorate([
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsNotEmpty)(),
    __metadata("design:type", String)
], NewGameDto.prototype, "gameId", void 0);
__decorate([
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsBoolean)(),
    __metadata("design:type", Boolean)
], NewGameDto.prototype, "approved", void 0);
class LeaveGameDto {
}
exports.LeaveGameDto = LeaveGameDto;
__decorate([
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsNotEmpty)(),
    __metadata("design:type", String)
], LeaveGameDto.prototype, "gameId", void 0);
//# sourceMappingURL=game.dto.js.map