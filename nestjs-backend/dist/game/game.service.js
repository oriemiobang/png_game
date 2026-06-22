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
const rating_service_1 = require("../rating/rating.service");
let GameService = class GameService {
    constructor(prisma, ratingService) {
        this.prisma = prisma;
        this.ratingService = ratingService;
    }
    attachMatchState(game) {
        return {
            ...game,
            currentRound: game.currentRound ?? 1,
            player1Wins: game.player1RoundWins ?? 0,
            player2Wins: game.player2RoundWins ?? 0,
            maxRounds: game.maxRounds ?? 3,
            roundHistory: (game.roundResults ?? []).map((r) => ({
                round: r.round,
                winnerId: r.winnerId,
                guesses: r.guesses,
                timeMs: r.timeMs,
                startedAt: r.startedAt?.toISOString() ?? null,
                endedAt: r.endedAt?.toISOString() ?? null,
            })),
        };
    }
    async recordRoundResult(gameId, winnerId, game, roundGuesses = []) {
        const startedAt = roundGuesses[0]?.createdAt ? new Date(roundGuesses[0].createdAt) : null;
        const endedAt = roundGuesses.length > 0 ? new Date(roundGuesses[roundGuesses.length - 1].createdAt) : null;
        const timeMs = startedAt && endedAt ? Math.max(0, endedAt.getTime() - startedAt.getTime()) : 0;
        await this.prisma.roundResult.create({
            data: {
                gameId,
                round: game.currentRound,
                winnerId,
                guesses: roundGuesses.length,
                timeMs,
                startedAt,
                endedAt,
            },
        });
        if (winnerId) {
            if (winnerId === game.player1Id) {
                await this.prisma.game.update({
                    where: { id: gameId },
                    data: { player1RoundWins: { increment: 1 } },
                });
            }
            else if (winnerId === game.player2Id) {
                await this.prisma.game.update({
                    where: { id: gameId },
                    data: { player2RoundWins: { increment: 1 } },
                });
            }
        }
    }
    async recordUserOutcome(game, winnerId, isDraw) {
        if (game.resultRecorded) {
            return { ratingChangeA: 0, ratingChangeB: 0 };
        }
        const player1Id = game.player1Id;
        const player2Id = game.player2Id;
        const now = new Date();
        let ratingChangeA = 0;
        let ratingChangeB = 0;
        if (player1Id && player2Id) {
            const p1 = await this.prisma.user.findUnique({ where: { id: player1Id } });
            const p2 = await this.prisma.user.findUnique({ where: { id: player2Id } });
            if (p1 && p2) {
                let outcome = 0.5;
                if (winnerId === player1Id)
                    outcome = 1;
                else if (winnerId === player2Id)
                    outcome = 0;
                const res = this.ratingService.calculateNewRatings(p1.rating, p2.rating, p1.gamesPlayed, p2.gamesPlayed, outcome);
                ratingChangeA = res.ratingChangeA;
                ratingChangeB = res.ratingChangeB;
                await this.prisma.$transaction([
                    this.prisma.user.update({
                        where: { id: player1Id },
                        data: {
                            gamesPlayed: { increment: 1 },
                            wins: winnerId === player1Id ? { increment: 1 } : undefined,
                            losses: winnerId && winnerId !== player1Id && !isDraw ? { increment: 1 } : undefined,
                            draws: isDraw ? { increment: 1 } : undefined,
                            lastPlayedAt: now,
                            rating: res.newRatingA,
                            ratingPeak: res.newRatingA > p1.ratingPeak ? res.newRatingA : undefined,
                        },
                    }),
                    this.prisma.user.update({
                        where: { id: player2Id },
                        data: {
                            gamesPlayed: { increment: 1 },
                            wins: winnerId === player2Id ? { increment: 1 } : undefined,
                            losses: winnerId && winnerId !== player2Id && !isDraw ? { increment: 1 } : undefined,
                            draws: isDraw ? { increment: 1 } : undefined,
                            lastPlayedAt: now,
                            rating: res.newRatingB,
                            ratingPeak: res.newRatingB > p2.ratingPeak ? res.newRatingB : undefined,
                        },
                    }),
                ]);
            }
        }
        else {
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
        }
        await this.prisma.game.update({
            where: { id: game.id },
            data: { resultRecorded: true },
        });
        return { ratingChangeA, ratingChangeB };
    }
    async resetMatch(gameId, resetSeries = false) {
        const game = await this.prisma.game.findUnique({ where: { id: gameId } });
        if (!game) {
            throw new Error('Game not found');
        }
        if (resetSeries) {
            await this.prisma.roundResult.deleteMany({ where: { gameId } });
        }
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
                turnStartedAt: null,
                ...(resetSeries
                    ? { currentRound: 1, player1RoundWins: 0, player2RoundWins: 0 }
                    : { currentRound: Math.min(game.currentRound + 1, game.maxRounds) }),
            },
            include: {
                player1: { select: { id: true, name: true, rating: true, ratingPeak: true } },
                player2: { select: { id: true, name: true, rating: true, ratingPeak: true } },
                guesses: true,
                roundResults: true,
            },
        });
        return this.attachMatchState(updatedGame);
    }
    async getGameState(gameId) {
        const game = await this.prisma.game.findUnique({
            where: { id: gameId },
            include: {
                player1: { select: { id: true, name: true, rating: true, ratingPeak: true } },
                player2: { select: { id: true, name: true, rating: true, ratingPeak: true } },
                guesses: true,
                roundResults: { orderBy: { round: 'asc' } },
            },
        });
        if (!game)
            return null;
        if (game.status === 'playing' && game.turnStartedAt && game.timeLimit > 0) {
            const now = new Date();
            const timeSpentMs = now.getTime() - game.turnStartedAt.getTime();
            if (game.turn === game.player1Id) {
                game.player1TimeLeft = Math.max(0, (game.player1TimeLeft ?? 0) - timeSpentMs);
            }
            else if (game.turn === game.player2Id) {
                game.player2TimeLeft = Math.max(0, (game.player2TimeLeft ?? 0) - timeSpentMs);
            }
            game.turnStartedAt = now;
        }
        return this.attachMatchState(game);
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
                player1: { select: { id: true, name: true, rating: true, ratingPeak: true } },
                player2: { select: { id: true, name: true, rating: true, ratingPeak: true } },
                roundResults: { orderBy: { round: 'asc' } },
            },
        });
        return this.attachMatchState(game);
    }
    async createGameForMatch(gameId, player1Id, player2Id, settings) {
        await this.ensureUser(player1Id);
        await this.ensureUser(player2Id);
        const game = await this.prisma.game.create({
            data: {
                id: gameId,
                player1Id,
                player2Id,
                maxRounds: settings.maxRounds,
                timeLimit: settings.timeLimit,
                isPrivate: false,
                resultRecorded: false,
                turn: player2Id,
            },
            include: {
                player1: { select: { id: true, name: true, rating: true, ratingPeak: true } },
                player2: { select: { id: true, name: true, rating: true, ratingPeak: true } },
                roundResults: { orderBy: { round: 'asc' } },
            },
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
                player1: { select: { id: true, name: true, rating: true, ratingPeak: true } },
            },
        });
        return rooms.map((room) => this.attachMatchState(room));
    }
    async cancelGame(gameId, playerId) {
        const game = await this.prisma.game.findUnique({ where: { id: gameId } });
        if (!game)
            throw new Error('Room not found');
        if (game.player1Id !== playerId)
            throw new Error('Only the host can cancel the room');
        if (game.status !== 'waiting')
            throw new Error('Cannot cancel a game that has already started');
        await this.prisma.guess.deleteMany({ where: { gameId } });
        await this.prisma.game.delete({ where: { id: gameId } });
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
                player1: { select: { id: true, name: true } },
                player2: { select: { id: true, name: true } },
                roundResults: { orderBy: { round: 'asc' } },
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
            include: {
                player1: { select: { id: true, name: true, rating: true, ratingPeak: true } },
                player2: { select: { id: true, name: true, rating: true, ratingPeak: true } },
                roundResults: { orderBy: { round: 'asc' } },
            },
        });
        if (updatedGame.player1Secret && updatedGame.player2Secret) {
            const startedGame = await this.prisma.game.update({
                where: { id: gameId },
                data: {
                    status: 'playing',
                    turn: game.player2Id,
                    player1TimeLeft: game.timeLimit * 1000,
                    player2TimeLeft: game.timeLimit * 1000,
                    turnStartedAt: new Date()
                },
                include: {
                    player1: { select: { id: true, name: true, rating: true, ratingPeak: true } },
                    player2: { select: { id: true, name: true, rating: true, ratingPeak: true } },
                    roundResults: { orderBy: { round: 'asc' } },
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
        const isPlayer1 = game.player1Id === playerId;
        const opponentId = isPlayer1 ? game.player2Id : game.player1Id;
        const secret = isPlayer1 ? game.player2Secret : game.player1Secret;
        if (!secret)
            throw new Error('Opponent has not set secret yet');
        const now = new Date();
        let newP1Time = game.player1TimeLeft ?? (game.timeLimit * 1000);
        let newP2Time = game.player2TimeLeft ?? (game.timeLimit * 1000);
        if (game.timeLimit > 0 && game.turnStartedAt) {
            const timeSpentMs = now.getTime() - new Date(game.turnStartedAt).getTime();
            if (isPlayer1) {
                newP1Time = Math.max(0, newP1Time - timeSpentMs);
            }
            else {
                newP2Time = Math.max(0, newP2Time - timeSpentMs);
            }
            if (isPlayer1 && newP1Time <= 0) {
                await this.recordRoundResult(gameId, opponentId, game);
                const updatedGame = await this.prisma.game.update({
                    where: { id: gameId },
                    data: { status: 'finished', winnerId: opponentId, turn: null, player1TimeLeft: 0 },
                    include: {
                        guesses: true,
                        player1: { select: { id: true, name: true, rating: true, ratingPeak: true } },
                        player2: { select: { id: true, name: true, rating: true, ratingPeak: true } },
                        roundResults: { orderBy: { round: 'asc' } },
                    },
                });
                const ratingChanges = await this.recordUserOutcome(updatedGame, opponentId, false);
                return { updatedGame: this.attachMatchState(updatedGame), feedback: { position: 0, number: 0 }, isDraw: false, isTimeout: true, ratingChanges };
            }
            else if (!isPlayer1 && newP2Time <= 0) {
                await this.recordRoundResult(gameId, opponentId, game);
                const updatedGame = await this.prisma.game.update({
                    where: { id: gameId },
                    data: { status: 'finished', winnerId: opponentId, turn: null, player2TimeLeft: 0 },
                    include: {
                        guesses: true,
                        player1: { select: { id: true, name: true, rating: true, ratingPeak: true } },
                        player2: { select: { id: true, name: true, rating: true, ratingPeak: true } },
                        roundResults: { orderBy: { round: 'asc' } },
                    },
                });
                const ratingChanges = await this.recordUserOutcome(updatedGame, opponentId, false);
                return { updatedGame: this.attachMatchState(updatedGame), feedback: { position: 0, number: 0 }, isDraw: false, isTimeout: true, ratingChanges };
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
                round: game.currentRound,
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
        let ratingChanges = { ratingChangeA: 0, ratingChangeB: 0 };
        if (newStatus === 'finished') {
            const roundGuesses = allGuesses.filter((guess) => guess.round === game.currentRound);
            await this.recordRoundResult(gameId, winnerId, game, roundGuesses);
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
                turnStartedAt: now,
            },
            include: {
                guesses: true,
                player1: { select: { id: true, name: true, rating: true, ratingPeak: true } },
                player2: { select: { id: true, name: true, rating: true, ratingPeak: true } },
                roundResults: { orderBy: { round: 'asc' } },
            },
        });
        if (newStatus === 'finished' && game.currentRound >= game.maxRounds) {
            ratingChanges = await this.recordUserOutcome(updatedGame, winnerId, isDraw);
        }
        return { updatedGame: this.attachMatchState(updatedGame), feedback, isDraw, isTimeout: false, ratingChanges };
    }
    async forfeitGame(gameId, forfeiterId) {
        const game = await this.prisma.game.findUnique({
            where: { id: gameId },
            include: {
                player1: true,
                player2: true,
                roundResults: true,
            },
        });
        if (!game || game.status === 'finished')
            return null;
        const winnerId = forfeiterId === game.player1Id ? game.player2Id : game.player1Id;
        const ratingChanges = await this.recordUserOutcome(game, winnerId, false);
        const updatedGame = await this.prisma.game.update({
            where: { id: gameId },
            data: {
                status: 'finished',
                winnerId,
                resultRecorded: true,
            },
            include: {
                guesses: true,
                player1: { select: { id: true, name: true, rating: true, ratingPeak: true } },
                player2: { select: { id: true, name: true, rating: true, ratingPeak: true } },
                roundResults: { orderBy: { round: 'asc' } },
            },
        });
        return { updatedGame: this.attachMatchState(updatedGame), ratingChanges };
    }
    async getActiveGamesForUser(userId) {
        const games = await this.prisma.game.findMany({
            where: {
                status: 'playing',
                OR: [{ player1Id: userId }, { player2Id: userId }],
            },
            select: { id: true },
        });
        return games.map(g => g.id);
    }
};
exports.GameService = GameService;
exports.GameService = GameService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService,
        rating_service_1.RatingService])
], GameService);
//# sourceMappingURL=game.service.js.map