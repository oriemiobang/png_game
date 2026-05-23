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
exports.GameService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../prisma/prisma.service");
let GameService = class GameService {
    constructor(prisma) {
        this.prisma = prisma;
        this.matchStates = new Map();
    }
    getMatchState(gameId, maxRounds) {
        const existing = this.matchStates.get(gameId);
        if (existing) {
            if (existing.maxRounds !== maxRounds) {
                existing.maxRounds = maxRounds;
            }
            return existing;
        }
        const created = {
            currentRound: 1,
            player1Wins: 0,
            player2Wins: 0,
            maxRounds,
            roundHistory: [],
        };
        this.matchStates.set(gameId, created);
        return created;
    }
    attachMatchState(game) {
        const state = this.getMatchState(game.id, game.maxRounds ?? 3);
        return {
            ...game,
            currentRound: state.currentRound,
            player1Wins: state.player1Wins,
            player2Wins: state.player2Wins,
            maxRounds: state.maxRounds,
            roundHistory: state.roundHistory,
        };
    }
    recordRoundResult(gameId, winnerId, game, roundGuesses = []) {
        if (!winnerId) {
            const state = this.getMatchState(gameId, game.maxRounds ?? 3);
            const startedAt = roundGuesses[0]?.createdAt ? new Date(roundGuesses[0].createdAt) : null;
            const endedAt = roundGuesses.length > 0 ? new Date(roundGuesses[roundGuesses.length - 1].createdAt) : null;
            state.roundHistory.push({
                round: state.currentRound,
                winnerId: null,
                guesses: roundGuesses.length,
                timeMs: startedAt && endedAt ? Math.max(0, endedAt.getTime() - startedAt.getTime()) : 0,
                startedAt: startedAt?.toISOString() ?? null,
                endedAt: endedAt?.toISOString() ?? null,
            });
            return;
        }
        const state = this.getMatchState(gameId, game.maxRounds ?? 3);
        if (winnerId === game.player1Id) {
            state.player1Wins += 1;
        }
        else if (winnerId === game.player2Id) {
            state.player2Wins += 1;
        }
        const startedAt = roundGuesses[0]?.createdAt ? new Date(roundGuesses[0].createdAt) : null;
        const endedAt = roundGuesses.length > 0 ? new Date(roundGuesses[roundGuesses.length - 1].createdAt) : null;
        state.roundHistory.push({
            round: state.currentRound,
            winnerId,
            guesses: roundGuesses.length,
            timeMs: startedAt && endedAt ? Math.max(0, endedAt.getTime() - startedAt.getTime()) : 0,
            startedAt: startedAt?.toISOString() ?? null,
            endedAt: endedAt?.toISOString() ?? null,
        });
    }
    async recordUserOutcome(game, winnerId, isDraw) {
        if (game.resultRecorded) {
            return;
        }
        const player1Id = game.player1Id;
        const player2Id = game.player2Id;
        const now = new Date();
        if (player1Id) {
            await this.prisma.user.update({
                where: { id: player1Id },
                data: {
                    gamesPlayed: { increment: 1 },
                    wins: winnerId === player1Id ? { increment: 1 } : undefined,
                    losses: winnerId && winnerId !== player1Id && !isDraw ? { increment: 1 } : undefined,
                    draws: isDraw ? { increment: 1 } : undefined,
                    lastPlayedAt: now,
                },
            });
        }
        if (player2Id) {
            await this.prisma.user.update({
                where: { id: player2Id },
                data: {
                    gamesPlayed: { increment: 1 },
                    wins: winnerId === player2Id ? { increment: 1 } : undefined,
                    losses: winnerId && winnerId !== player2Id && !isDraw ? { increment: 1 } : undefined,
                    draws: isDraw ? { increment: 1 } : undefined,
                    lastPlayedAt: now,
                },
            });
        }
        await this.prisma.game.update({
            where: { id: game.id },
            data: { resultRecorded: true },
        });
    }
    async resetMatch(gameId, resetSeries = false) {
        const game = await this.prisma.game.findUnique({ where: { id: gameId } });
        if (!game) {
            throw new Error('Game not found');
        }
        const state = this.getMatchState(gameId, game.maxRounds);
        const nextState = resetSeries
            ? {
                currentRound: 1,
                player1Wins: 0,
                player2Wins: 0,
                maxRounds: game.maxRounds,
                roundHistory: [],
            }
            : {
                currentRound: Math.min(state.currentRound + 1, game.maxRounds),
                player1Wins: state.player1Wins,
                player2Wins: state.player2Wins,
                maxRounds: game.maxRounds,
                roundHistory: state.roundHistory,
            };
        this.matchStates.set(gameId, nextState);
        await this.prisma.guess.deleteMany({ where: { gameId } });
        const updatedGame = await this.prisma.game.update({
            where: { id: gameId },
            data: {
                status: 'waiting',
                winnerId: null,
                resultRecorded: false,
                turn: null,
                lastChance: false,
                player1Secret: null,
                player2Secret: null,
                player1TimeLeft: null,
                player2TimeLeft: null,
                lastMoveAt: null,
            },
            include: {
                player1: { select: { id: true } },
                player2: { select: { id: true } },
                guesses: true,
            },
        });
        return this.attachMatchState(updatedGame);
    }
    async ensureUser(userId) {
        let user = await this.prisma.user.findUnique({
            where: { id: userId },
            select: { id: true },
        });
        if (!user) {
            user = await this.prisma.user.create({
                data: { id: userId },
                select: { id: true },
            });
        }
        return user;
    }
    async createGame(gameId, playerId, settings) {
        await this.ensureUser(playerId);
        const game = await this.prisma.game.create({
            data: {
                id: gameId,
                player1Id: playerId,
                maxRounds: settings?.maxRounds ?? 3,
                timeLimit: settings?.timeLimit ?? 60,
                isPrivate: settings?.isPrivate ?? false,
                resultRecorded: false,
            },
            include: {
                player1: { select: { id: true } },
                player2: { select: { id: true } },
            },
        });
        this.matchStates.set(gameId, {
            currentRound: 1,
            player1Wins: 0,
            player2Wins: 0,
            maxRounds: game.maxRounds,
            roundHistory: [],
        });
        return this.attachMatchState(game);
    }
    async getPublicRooms() {
        const rooms = await this.prisma.game.findMany({
            where: {
                isPrivate: false,
                status: 'waiting',
            },
            include: {
                player1: { select: { id: true } },
            },
        });
        return rooms.map((room) => this.attachMatchState(room));
    }
    async joinGame(gameId, playerId) {
        await this.ensureUser(playerId);
        const game = await this.prisma.game.findUnique({ where: { id: gameId } });
        if (!game)
            throw new Error('Room does not exist!');
        if (game.player2Id)
            throw new Error('Room is already full!');
        const updatedGame = await this.prisma.game.update({
            where: { id: gameId },
            data: {
                player2Id: playerId,
                turn: playerId,
            },
            include: {
                player1: { select: { id: true } },
                player2: { select: { id: true } },
            },
        });
        return this.attachMatchState(updatedGame);
    }
    async submitSecret(gameId, playerId, secret) {
        const game = await this.prisma.game.findUnique({ where: { id: gameId } });
        if (!game)
            throw new Error('Game not found');
        const updateData = {};
        if (game.player1Id === playerId) {
            updateData.player1Secret = secret;
        }
        else if (game.player2Id === playerId) {
            updateData.player2Secret = secret;
        }
        const updatedGame = await this.prisma.game.update({
            where: { id: gameId },
            data: updateData,
        });
        if (updatedGame.player1Secret && updatedGame.player2Secret) {
            const startedGame = await this.prisma.game.update({
                where: { id: gameId },
                data: {
                    status: 'playing',
                    turn: game.player2Id,
                    player1TimeLeft: game.timeLimit * 60 * 1000,
                    player2TimeLeft: game.timeLimit * 60 * 1000,
                    lastMoveAt: new Date()
                },
            });
            return this.attachMatchState(startedGame);
        }
        return this.attachMatchState(updatedGame);
    }
    generateFeedback(guess, secret) {
        let position = 0;
        let number = 0;
        guess.split('').forEach((digit, index) => {
            if (secret[index] === digit) {
                position++;
            }
            if (secret.includes(digit)) {
                number++;
            }
        });
        return { position, number };
    }
    async makeGuess(gameId, playerId, guessStr) {
        const game = await this.prisma.game.findUnique({
            where: { id: gameId },
            include: { guesses: true },
        });
        if (!game)
            throw new Error('Game not found');
        if (game.turn !== playerId)
            throw new Error('Not your turn');
        const state = this.getMatchState(gameId, game.maxRounds);
        const isPlayer1 = game.player1Id === playerId;
        const opponentId = isPlayer1 ? game.player2Id : game.player1Id;
        const secret = isPlayer1 ? game.player2Secret : game.player1Secret;
        if (!secret)
            throw new Error('Opponent has not set secret yet');
        const now = new Date();
        const timeSpentMs = now.getTime() - (game.lastMoveAt?.getTime() ?? now.getTime());
        let newP1Time = game.player1TimeLeft;
        let newP2Time = game.player2TimeLeft;
        if (game.timeLimit > 0) {
            if (isPlayer1) {
                newP1Time = Math.max(0, (newP1Time ?? 0) - timeSpentMs);
            }
            else {
                newP2Time = Math.max(0, (newP2Time ?? 0) - timeSpentMs);
            }
            if (isPlayer1 && newP1Time <= 0) {
                const updatedGame = await this.prisma.game.update({
                    where: { id: gameId },
                    data: { status: 'finished', winnerId: opponentId, turn: null, player1TimeLeft: 0 },
                    include: { guesses: true },
                });
                this.recordRoundResult(gameId, opponentId, game);
                await this.recordUserOutcome(updatedGame, opponentId, false);
                return { updatedGame: this.attachMatchState(updatedGame), feedback: { position: 0, number: 0 }, isDraw: false, isTimeout: true };
            }
            else if (!isPlayer1 && newP2Time <= 0) {
                const updatedGame = await this.prisma.game.update({
                    where: { id: gameId },
                    data: { status: 'finished', winnerId: opponentId, turn: null, player2TimeLeft: 0 },
                    include: { guesses: true },
                });
                this.recordRoundResult(gameId, opponentId, game);
                await this.recordUserOutcome(updatedGame, opponentId, false);
                return { updatedGame: this.attachMatchState(updatedGame), feedback: { position: 0, number: 0 }, isDraw: false, isTimeout: true };
            }
        }
        const feedback = this.generateFeedback(guessStr, secret);
        await this.prisma.guess.create({
            data: {
                gameId,
                playerId,
                guess: guessStr,
                position: feedback.position,
                number: feedback.number,
                round: state.currentRound,
            },
        });
        const allGuesses = await this.prisma.guess.findMany({ where: { gameId } });
        const p1Guesses = allGuesses.filter((g) => g.playerId === game.player1Id);
        const p2Guesses = allGuesses.filter((g) => g.playerId === game.player2Id);
        let nextTurn = opponentId;
        let newStatus = game.status;
        let winnerId = null;
        let isDraw = false;
        let lastChance = game.lastChance;
        if (feedback.position === 4) {
            if (game.lastChance) {
                newStatus = 'finished';
                nextTurn = null;
                isDraw = true;
            }
            else if (p1Guesses.length !== p2Guesses.length) {
                lastChance = true;
            }
            else {
                newStatus = 'finished';
                nextTurn = null;
                winnerId = playerId;
            }
        }
        else {
            if (game.lastChance) {
                newStatus = 'finished';
                nextTurn = null;
                winnerId = opponentId;
            }
            else if (p1Guesses.length >= game.maxRounds && p2Guesses.length >= game.maxRounds) {
                newStatus = 'finished';
                nextTurn = null;
                isDraw = true;
            }
        }
        const updatedGame = await this.prisma.game.update({
            where: { id: gameId },
            data: {
                turn: nextTurn,
                status: newStatus,
                winnerId: winnerId,
                lastChance: lastChance,
                player1TimeLeft: newP1Time,
                player2TimeLeft: newP2Time,
                lastMoveAt: now,
            },
            include: { guesses: true },
        });
        if (newStatus === 'finished') {
            const roundGuesses = allGuesses.filter((guess) => guess.round === state.currentRound);
            this.recordRoundResult(gameId, winnerId, game, roundGuesses);
            if (state.currentRound >= game.maxRounds) {
                await this.recordUserOutcome(updatedGame, winnerId, isDraw);
            }
        }
        return { updatedGame: this.attachMatchState(updatedGame), feedback, isDraw, isTimeout: false };
    }
};
exports.GameService = GameService;
exports.GameService = GameService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], GameService);
//# sourceMappingURL=game.service.js.map