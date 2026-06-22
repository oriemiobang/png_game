"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.WsThrottlerGuard = void 0;
const common_1 = require("@nestjs/common");
const throttler_1 = require("@nestjs/throttler");
const websockets_1 = require("@nestjs/websockets");
let WsThrottlerGuard = class WsThrottlerGuard extends throttler_1.ThrottlerGuard {
    async handleRequest(requestProps) {
        const { context, limit, ttl, throttler, blockDuration, generateKey } = requestProps;
        const client = context.switchToWs().getClient();
        const ip = client.conn?.remoteAddress || client.id;
        const userId = client.data?.userId || 'anonymous';
        const tracker = `${ip}-${userId}`;
        const key = generateKey(context, tracker, throttler.name);
        const { totalHits } = await this.storageService.increment(key, ttl, limit, blockDuration, throttler.name);
        if (totalHits > limit) {
            throw new websockets_1.WsException('Rate limit exceeded. Please wait a moment before trying again.');
        }
        return true;
    }
};
exports.WsThrottlerGuard = WsThrottlerGuard;
exports.WsThrottlerGuard = WsThrottlerGuard = __decorate([
    (0, common_1.Injectable)()
], WsThrottlerGuard);
//# sourceMappingURL=ws-throttler.guard.js.map