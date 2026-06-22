"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.WsAllExceptionsFilter = void 0;
const common_1 = require("@nestjs/common");
const websockets_1 = require("@nestjs/websockets");
let WsAllExceptionsFilter = class WsAllExceptionsFilter extends websockets_1.BaseWsExceptionFilter {
    catch(exception, host) {
        const client = host.switchToWs().getClient();
        let errorMessage = 'An error occurred';
        if (exception instanceof common_1.BadRequestException) {
            const response = exception.getResponse();
            if (typeof response === 'object' && response !== null && 'message' in response) {
                const msg = response.message;
                errorMessage = Array.isArray(msg) ? msg.join(', ') : msg;
            }
            else {
                errorMessage = exception.message;
            }
        }
        else if (exception instanceof websockets_1.WsException) {
            errorMessage = exception.message;
        }
        else if (exception instanceof Error) {
            errorMessage = exception.message;
        }
        client.emit('room_error', errorMessage);
    }
};
exports.WsAllExceptionsFilter = WsAllExceptionsFilter;
exports.WsAllExceptionsFilter = WsAllExceptionsFilter = __decorate([
    (0, common_1.Catch)(websockets_1.WsException, common_1.BadRequestException)
], WsAllExceptionsFilter);
//# sourceMappingURL=ws-exception.filter.js.map