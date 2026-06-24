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
exports.AuthService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../prisma/prisma.service");
const jwt_1 = require("@nestjs/jwt");
const bcrypt = require("bcrypt");
const google_auth_library_1 = require("google-auth-library");
let AuthService = class AuthService {
    constructor(prisma, jwtService) {
        this.prisma = prisma;
        this.jwtService = jwtService;
        this.googleClient = new google_auth_library_1.OAuth2Client();
    }
    async signUp(email, pass, name) {
        const existing = await this.prisma.user.findUnique({ where: { email } });
        if (existing) {
            throw new common_1.HttpException('User with this email already exists', common_1.HttpStatus.BAD_REQUEST);
        }
        const salt = await bcrypt.genSalt(10);
        const password = await bcrypt.hash(pass, salt);
        const user = await this.prisma.user.create({
            data: { email, password, name },
        });
        return this.generateToken(user.id, user.email, user.name);
    }
    async signIn(email, pass) {
        const user = await this.prisma.user.findUnique({ where: { email } });
        if (!user) {
            throw new common_1.HttpException('Invalid credentials', common_1.HttpStatus.UNAUTHORIZED);
        }
        if (!user.password) {
            throw new common_1.HttpException('Please login with Google', common_1.HttpStatus.UNAUTHORIZED);
        }
        const isMatch = await bcrypt.compare(pass, user.password);
        if (!isMatch) {
            throw new common_1.HttpException('Invalid credentials', common_1.HttpStatus.UNAUTHORIZED);
        }
        return this.generateToken(user.id, user.email, user.name);
    }
    async verifyGoogleToken(idToken) {
        try {
            const audience = process.env.GOOGLE_CLIENT_ID?.split(',').map(id => id.trim());
            const ticket = await this.googleClient.verifyIdToken({
                idToken,
                audience,
            });
            const payload = ticket.getPayload();
            if (!payload || !payload.email) {
                throw new common_1.HttpException('Invalid Google Token', common_1.HttpStatus.UNAUTHORIZED);
            }
            let user = await this.prisma.user.findUnique({
                where: { googleId: payload.sub },
            });
            if (!user) {
                user = await this.prisma.user.findUnique({ where: { email: payload.email } });
                if (user) {
                    user = await this.prisma.user.update({
                        where: { id: user.id },
                        data: { googleId: payload.sub },
                    });
                }
                else {
                    user = await this.prisma.user.create({
                        data: {
                            email: payload.email,
                            name: payload.name || 'Google User',
                            googleId: payload.sub,
                        },
                    });
                }
            }
            return this.generateToken(user.id, user.email, user.name);
        }
        catch (e) {
            throw new common_1.HttpException('Google authentication failed: ' + e.message, common_1.HttpStatus.UNAUTHORIZED);
        }
    }
    async getMyStats(userId) {
        const user = await this.prisma.user.findUnique({
            where: { id: userId },
            select: {
                id: true,
                name: true,
                email: true,
                gamesPlayed: true,
                wins: true,
                losses: true,
                draws: true,
                rating: true,
                ratingPeak: true,
                lastPlayedAt: true,
            },
        });
        if (!user) {
            throw new common_1.HttpException('User not found', common_1.HttpStatus.UNAUTHORIZED);
        }
        const winRate = user.gamesPlayed > 0 ? Math.round((user.wins / user.gamesPlayed) * 1000) / 10 : 0;
        let tier = 'Beginner';
        if (user.rating >= 2200)
            tier = 'Master';
        else if (user.rating >= 1800)
            tier = 'Expert';
        else if (user.rating >= 1400)
            tier = 'Advanced';
        else if (user.rating >= 1000)
            tier = 'Intermediate';
        const recentGames = await this.prisma.game.findMany({
            where: {
                OR: [{ player1Id: userId }, { player2Id: userId }],
                status: 'finished',
            },
            orderBy: { updatedAt: 'desc' },
            take: 10,
            include: {
                player1: { select: { id: true, name: true, rating: true } },
                player2: { select: { id: true, name: true, rating: true } },
            },
        });
        const matchHistory = recentGames.map(game => {
            const isPlayer1 = game.player1Id === userId;
            const opponent = isPlayer1 ? game.player2 : game.player1;
            let outcome = 'draw';
            if (game.winnerId === userId)
                outcome = 'win';
            else if (game.winnerId && game.winnerId !== userId)
                outcome = 'loss';
            return {
                id: game.id,
                opponentName: opponent ? opponent.name : 'Unknown',
                opponentRating: opponent ? opponent.rating : 0,
                outcome,
                date: game.updatedAt,
            };
        });
        return {
            ...user,
            winRate,
            tier,
            matchHistory,
        };
    }
    generateToken(userId, email, name) {
        const payload = { sub: userId, email, name };
        return {
            access_token: this.jwtService.sign(payload),
            user: { id: userId, email, name },
        };
    }
    async getLeaderboard() {
        const users = await this.prisma.user.findMany({
            orderBy: { rating: 'desc' },
            take: 50,
            select: {
                id: true,
                name: true,
                rating: true,
                wins: true,
                gamesPlayed: true,
            },
        });
        return users.map((u) => {
            const winRate = u.gamesPlayed > 0 ? Math.round((u.wins / u.gamesPlayed) * 1000) / 10 : 0;
            let tier = 'Beginner';
            if (u.rating >= 2200)
                tier = 'Master';
            else if (u.rating >= 1800)
                tier = 'Expert';
            else if (u.rating >= 1400)
                tier = 'Advanced';
            else if (u.rating >= 1000)
                tier = 'Intermediate';
            return {
                ...u,
                winRate,
                tier,
            };
        });
    }
    async updateFcmToken(userId, fcmToken) {
        return this.prisma.user.update({
            where: { id: userId },
            data: { fcmToken },
        });
    }
};
exports.AuthService = AuthService;
exports.AuthService = AuthService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService,
        jwt_1.JwtService])
], AuthService);
//# sourceMappingURL=auth.service.js.map