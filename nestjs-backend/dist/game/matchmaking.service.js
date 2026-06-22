"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.MatchmakingService = void 0;
const common_1 = require("@nestjs/common");
const TIME_LIMIT_TOLERANCE = 0;
const QUEUE_TTL_MS = 5 * 60 * 1000;
let MatchmakingService = class MatchmakingService {
    constructor() {
        this.queue = new Map();
    }
    findMatch(playerId, maxRounds, timeLimit) {
        for (const [queuedPlayerId, entry] of this.queue.entries()) {
            if (queuedPlayerId === playerId)
                continue;
            const roundsMatch = entry.maxRounds === maxRounds;
            const timeMatch = Math.abs(entry.timeLimit - timeLimit) <= TIME_LIMIT_TOLERANCE;
            if (roundsMatch && timeMatch) {
                clearTimeout(entry.ttlTimer);
                this.queue.delete(queuedPlayerId);
                return entry;
            }
        }
        return null;
    }
    addToQueue(playerId, socketId, maxRounds, timeLimit, onTimeout) {
        this.removeFromQueue(playerId);
        const ttlTimer = setTimeout(() => {
            this.queue.delete(playerId);
            onTimeout();
        }, QUEUE_TTL_MS);
        this.queue.set(playerId, {
            playerId,
            socketId,
            maxRounds,
            timeLimit,
            joinedAt: new Date(),
            ttlTimer,
        });
    }
    removeFromQueue(playerId) {
        const entry = this.queue.get(playerId);
        if (!entry)
            return false;
        clearTimeout(entry.ttlTimer);
        this.queue.delete(playerId);
        return true;
    }
    removeBySocketId(socketId) {
        for (const [playerId, entry] of this.queue.entries()) {
            if (entry.socketId === socketId) {
                clearTimeout(entry.ttlTimer);
                this.queue.delete(playerId);
                return playerId;
            }
        }
        return null;
    }
    get queueSize() {
        return this.queue.size;
    }
};
exports.MatchmakingService = MatchmakingService;
exports.MatchmakingService = MatchmakingService = __decorate([
    (0, common_1.Injectable)()
], MatchmakingService);
//# sourceMappingURL=matchmaking.service.js.map