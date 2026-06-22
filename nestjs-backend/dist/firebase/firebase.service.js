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
var FirebaseService_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.FirebaseService = void 0;
const common_1 = require("@nestjs/common");
const app_1 = require("firebase-admin/app");
const messaging_1 = require("firebase-admin/messaging");
let FirebaseService = FirebaseService_1 = class FirebaseService {
    constructor() {
        this.logger = new common_1.Logger(FirebaseService_1.name);
        this.initialized = false;
        try {
            if (!(0, app_1.getApps)().length) {
                (0, app_1.initializeApp)();
                this.initialized = true;
                this.logger.log('Firebase Admin SDK initialized successfully.');
            }
            else {
                this.initialized = true;
            }
        }
        catch (error) {
            this.logger.warn('Failed to initialize Firebase Admin SDK. Push notifications will be disabled.', error.message);
        }
    }
    async sendPushNotification(token, title, body, data) {
        if (!this.initialized || !token)
            return;
        try {
            const message = {
                token,
                notification: {
                    title,
                    body,
                },
                data,
            };
            const response = await (0, messaging_1.getMessaging)().send(message);
            this.logger.debug(`Successfully sent FCM message: ${response}`);
        }
        catch (error) {
            this.logger.error('Error sending FCM message:', error.message);
        }
    }
};
exports.FirebaseService = FirebaseService;
exports.FirebaseService = FirebaseService = FirebaseService_1 = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [])
], FirebaseService);
//# sourceMappingURL=firebase.service.js.map