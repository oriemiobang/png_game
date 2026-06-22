import { PrismaService } from '../prisma/prisma.service';
import { RatingService } from '../rating/rating.service';
export declare class GameService {
    private prisma;
    private ratingService;
    constructor(prisma: PrismaService, ratingService: RatingService);
    private attachMatchState;
    private recordRoundResult;
    private recordUserOutcome;
    resetMatch(gameId: string, resetSeries?: boolean): Promise<{
        matchOver: boolean;
        roundResults: {
            id: string;
            round: number;
            guesses: number;
            timeMs: number;
            startedAt: Date | null;
            endedAt: Date | null;
            gameId: string;
            winnerId: string | null;
        }[];
        guesses: {
            number: number;
            guess: string;
            id: string;
            round: number;
            gameId: string;
            createdAt: Date;
            playerId: string;
            position: number;
        }[];
        player1: {
            id: string;
            name: string;
            rating: number;
            ratingPeak: number;
        };
        player2: {
            id: string;
            name: string;
            rating: number;
            ratingPeak: number;
        };
        currentRound: any;
        player1RoundWins: number;
        player2RoundWins: number;
        maxRounds: any;
        id: string;
        winnerId: string | null;
        createdAt: Date;
        updatedAt: Date;
        player1Id: string;
        player2Id: string | null;
        player1Secret: string | null;
        player2Secret: string | null;
        status: string;
        resultRecorded: boolean;
        timeLimit: number;
        isPrivate: boolean;
        turn: string | null;
        lastChance: boolean;
        player1TimeLeft: number | null;
        player2TimeLeft: number | null;
        turnStartedAt: Date | null;
        player1Wins: any;
        player2Wins: any;
        roundHistory: any;
    } | {
        matchOver: boolean;
        seriesWinnerId: string;
        player1RoundWins: number;
        player2RoundWins: number;
        roundResults: any[];
        currentRound: any;
        maxRounds: any;
        id: string;
        winnerId: string | null;
        createdAt: Date;
        updatedAt: Date;
        player1Id: string;
        player2Id: string | null;
        player1Secret: string | null;
        player2Secret: string | null;
        status: string;
        resultRecorded: boolean;
        timeLimit: number;
        isPrivate: boolean;
        turn: string | null;
        lastChance: boolean;
        player1TimeLeft: number | null;
        player2TimeLeft: number | null;
        turnStartedAt: Date | null;
        player1Wins: any;
        player2Wins: any;
        roundHistory: any;
    }>;
    getGameState(gameId: string): Promise<{
        roundResults: {
            id: string;
            round: number;
            guesses: number;
            timeMs: number;
            startedAt: Date | null;
            endedAt: Date | null;
            gameId: string;
            winnerId: string | null;
        }[];
        guesses: {
            number: number;
            guess: string;
            id: string;
            round: number;
            gameId: string;
            createdAt: Date;
            playerId: string;
            position: number;
        }[];
        player1: {
            id: string;
            name: string;
            rating: number;
            ratingPeak: number;
        };
        player2: {
            id: string;
            name: string;
            rating: number;
            ratingPeak: number;
        };
    } & {
        currentRound: number;
        player1RoundWins: number;
        player2RoundWins: number;
        maxRounds: number;
        id: string;
        winnerId: string | null;
        createdAt: Date;
        updatedAt: Date;
        player1Id: string;
        player2Id: string | null;
        player1Secret: string | null;
        player2Secret: string | null;
        status: string;
        resultRecorded: boolean;
        timeLimit: number;
        isPrivate: boolean;
        turn: string | null;
        lastChance: boolean;
        player1TimeLeft: number | null;
        player2TimeLeft: number | null;
        turnStartedAt: Date | null;
    } & {
        currentRound: any;
        player1Wins: any;
        player2Wins: any;
        maxRounds: any;
        roundHistory: any;
    }>;
    ensureUser(userId: string): Promise<{
        id: string;
    }>;
    createGame(gameId: string, playerId: string, settings?: {
        maxRounds?: number;
        timeLimit?: number;
        isPrivate?: boolean;
    }): Promise<{
        roundResults: {
            id: string;
            round: number;
            guesses: number;
            timeMs: number;
            startedAt: Date | null;
            endedAt: Date | null;
            gameId: string;
            winnerId: string | null;
        }[];
        player1: {
            id: string;
            name: string;
            rating: number;
            ratingPeak: number;
        };
        player2: {
            id: string;
            name: string;
            rating: number;
            ratingPeak: number;
        };
    } & {
        currentRound: number;
        player1RoundWins: number;
        player2RoundWins: number;
        maxRounds: number;
        id: string;
        winnerId: string | null;
        createdAt: Date;
        updatedAt: Date;
        player1Id: string;
        player2Id: string | null;
        player1Secret: string | null;
        player2Secret: string | null;
        status: string;
        resultRecorded: boolean;
        timeLimit: number;
        isPrivate: boolean;
        turn: string | null;
        lastChance: boolean;
        player1TimeLeft: number | null;
        player2TimeLeft: number | null;
        turnStartedAt: Date | null;
    } & {
        currentRound: any;
        player1Wins: any;
        player2Wins: any;
        maxRounds: any;
        roundHistory: any;
    }>;
    createGameForMatch(gameId: string, player1Id: string, player2Id: string, settings: {
        maxRounds: number;
        timeLimit: number;
    }): Promise<{
        roundResults: {
            id: string;
            round: number;
            guesses: number;
            timeMs: number;
            startedAt: Date | null;
            endedAt: Date | null;
            gameId: string;
            winnerId: string | null;
        }[];
        player1: {
            id: string;
            name: string;
            rating: number;
            ratingPeak: number;
        };
        player2: {
            id: string;
            name: string;
            rating: number;
            ratingPeak: number;
        };
    } & {
        currentRound: number;
        player1RoundWins: number;
        player2RoundWins: number;
        maxRounds: number;
        id: string;
        winnerId: string | null;
        createdAt: Date;
        updatedAt: Date;
        player1Id: string;
        player2Id: string | null;
        player1Secret: string | null;
        player2Secret: string | null;
        status: string;
        resultRecorded: boolean;
        timeLimit: number;
        isPrivate: boolean;
        turn: string | null;
        lastChance: boolean;
        player1TimeLeft: number | null;
        player2TimeLeft: number | null;
        turnStartedAt: Date | null;
    } & {
        currentRound: any;
        player1Wins: any;
        player2Wins: any;
        maxRounds: any;
        roundHistory: any;
    }>;
    getPublicRooms(): Promise<({
        player1: {
            id: string;
            name: string;
            rating: number;
            ratingPeak: number;
        };
    } & {
        currentRound: number;
        player1RoundWins: number;
        player2RoundWins: number;
        maxRounds: number;
        id: string;
        winnerId: string | null;
        createdAt: Date;
        updatedAt: Date;
        player1Id: string;
        player2Id: string | null;
        player1Secret: string | null;
        player2Secret: string | null;
        status: string;
        resultRecorded: boolean;
        timeLimit: number;
        isPrivate: boolean;
        turn: string | null;
        lastChance: boolean;
        player1TimeLeft: number | null;
        player2TimeLeft: number | null;
        turnStartedAt: Date | null;
    } & {
        currentRound: any;
        player1Wins: any;
        player2Wins: any;
        maxRounds: any;
        roundHistory: any;
    })[]>;
    cancelGame(gameId: string, playerId: string): Promise<void>;
    joinGame(gameId: string, playerId: string): Promise<{
        roundResults: {
            id: string;
            round: number;
            guesses: number;
            timeMs: number;
            startedAt: Date | null;
            endedAt: Date | null;
            gameId: string;
            winnerId: string | null;
        }[];
        player1: {
            id: string;
            name: string;
        };
        player2: {
            id: string;
            name: string;
        };
    } & {
        currentRound: number;
        player1RoundWins: number;
        player2RoundWins: number;
        maxRounds: number;
        id: string;
        winnerId: string | null;
        createdAt: Date;
        updatedAt: Date;
        player1Id: string;
        player2Id: string | null;
        player1Secret: string | null;
        player2Secret: string | null;
        status: string;
        resultRecorded: boolean;
        timeLimit: number;
        isPrivate: boolean;
        turn: string | null;
        lastChance: boolean;
        player1TimeLeft: number | null;
        player2TimeLeft: number | null;
        turnStartedAt: Date | null;
    } & {
        currentRound: any;
        player1Wins: any;
        player2Wins: any;
        maxRounds: any;
        roundHistory: any;
    }>;
    submitSecret(gameId: string, playerId: string, secret: string): Promise<{
        roundResults: {
            id: string;
            round: number;
            guesses: number;
            timeMs: number;
            startedAt: Date | null;
            endedAt: Date | null;
            gameId: string;
            winnerId: string | null;
        }[];
        player1: {
            id: string;
            name: string;
            rating: number;
            ratingPeak: number;
        };
        player2: {
            id: string;
            name: string;
            rating: number;
            ratingPeak: number;
        };
    } & {
        currentRound: number;
        player1RoundWins: number;
        player2RoundWins: number;
        maxRounds: number;
        id: string;
        winnerId: string | null;
        createdAt: Date;
        updatedAt: Date;
        player1Id: string;
        player2Id: string | null;
        player1Secret: string | null;
        player2Secret: string | null;
        status: string;
        resultRecorded: boolean;
        timeLimit: number;
        isPrivate: boolean;
        turn: string | null;
        lastChance: boolean;
        player1TimeLeft: number | null;
        player2TimeLeft: number | null;
        turnStartedAt: Date | null;
    } & {
        currentRound: any;
        player1Wins: any;
        player2Wins: any;
        maxRounds: any;
        roundHistory: any;
    }>;
    generateFeedback(guess: string, secret: string): {
        position: number;
        number: number;
    };
    makeGuess(gameId: string, playerId: string, guessStr: string): Promise<{
        updatedGame: {
            roundResults: {
                id: string;
                round: number;
                guesses: number;
                timeMs: number;
                startedAt: Date | null;
                endedAt: Date | null;
                gameId: string;
                winnerId: string | null;
            }[];
            guesses: {
                number: number;
                guess: string;
                id: string;
                round: number;
                gameId: string;
                createdAt: Date;
                playerId: string;
                position: number;
            }[];
            player1: {
                id: string;
                name: string;
                rating: number;
                ratingPeak: number;
            };
            player2: {
                id: string;
                name: string;
                rating: number;
                ratingPeak: number;
            };
        } & {
            currentRound: number;
            player1RoundWins: number;
            player2RoundWins: number;
            maxRounds: number;
            id: string;
            winnerId: string | null;
            createdAt: Date;
            updatedAt: Date;
            player1Id: string;
            player2Id: string | null;
            player1Secret: string | null;
            player2Secret: string | null;
            status: string;
            resultRecorded: boolean;
            timeLimit: number;
            isPrivate: boolean;
            turn: string | null;
            lastChance: boolean;
            player1TimeLeft: number | null;
            player2TimeLeft: number | null;
            turnStartedAt: Date | null;
        } & {
            currentRound: any;
            player1Wins: any;
            player2Wins: any;
            maxRounds: any;
            roundHistory: any;
        };
        feedback: {
            position: number;
            number: number;
        };
        isDraw: boolean;
        isTimeout: boolean;
        ratingChanges: {
            ratingChangeA: number;
            ratingChangeB: number;
        };
        matchOver: boolean;
    }>;
    handleTimeout(gameId: string, timeoutPlayerId: string): Promise<{
        updatedGame: {
            roundResults: {
                id: string;
                round: number;
                guesses: number;
                timeMs: number;
                startedAt: Date | null;
                endedAt: Date | null;
                gameId: string;
                winnerId: string | null;
            }[];
            guesses: {
                number: number;
                guess: string;
                id: string;
                round: number;
                gameId: string;
                createdAt: Date;
                playerId: string;
                position: number;
            }[];
            player1: {
                id: string;
                name: string;
                rating: number;
                ratingPeak: number;
            };
            player2: {
                id: string;
                name: string;
                rating: number;
                ratingPeak: number;
            };
        } & {
            currentRound: number;
            player1RoundWins: number;
            player2RoundWins: number;
            maxRounds: number;
            id: string;
            winnerId: string | null;
            createdAt: Date;
            updatedAt: Date;
            player1Id: string;
            player2Id: string | null;
            player1Secret: string | null;
            player2Secret: string | null;
            status: string;
            resultRecorded: boolean;
            timeLimit: number;
            isPrivate: boolean;
            turn: string | null;
            lastChance: boolean;
            player1TimeLeft: number | null;
            player2TimeLeft: number | null;
            turnStartedAt: Date | null;
        } & {
            currentRound: any;
            player1Wins: any;
            player2Wins: any;
            maxRounds: any;
            roundHistory: any;
        };
        feedback: {
            position: number;
            number: number;
        };
        isDraw: boolean;
        isTimeout: boolean;
        ratingChanges: {
            ratingChangeA: number;
            ratingChangeB: number;
        };
        matchOver: boolean;
    }>;
    forfeitGame(gameId: string, forfeiterId: string): Promise<{
        updatedGame: {
            roundResults: {
                id: string;
                round: number;
                guesses: number;
                timeMs: number;
                startedAt: Date | null;
                endedAt: Date | null;
                gameId: string;
                winnerId: string | null;
            }[];
            guesses: {
                number: number;
                guess: string;
                id: string;
                round: number;
                gameId: string;
                createdAt: Date;
                playerId: string;
                position: number;
            }[];
            player1: {
                id: string;
                name: string;
                rating: number;
                ratingPeak: number;
            };
            player2: {
                id: string;
                name: string;
                rating: number;
                ratingPeak: number;
            };
        } & {
            currentRound: number;
            player1RoundWins: number;
            player2RoundWins: number;
            maxRounds: number;
            id: string;
            winnerId: string | null;
            createdAt: Date;
            updatedAt: Date;
            player1Id: string;
            player2Id: string | null;
            player1Secret: string | null;
            player2Secret: string | null;
            status: string;
            resultRecorded: boolean;
            timeLimit: number;
            isPrivate: boolean;
            turn: string | null;
            lastChance: boolean;
            player1TimeLeft: number | null;
            player2TimeLeft: number | null;
            turnStartedAt: Date | null;
        } & {
            currentRound: any;
            player1Wins: any;
            player2Wins: any;
            maxRounds: any;
            roundHistory: any;
        };
        ratingChanges: {
            ratingChangeA: number;
            ratingChangeB: number;
        };
    }>;
    getActiveGamesForUser(userId: string): Promise<string[]>;
}
