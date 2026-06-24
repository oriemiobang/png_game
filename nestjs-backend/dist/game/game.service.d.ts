import { PrismaService } from '../prisma/prisma.service';
import { RatingService } from '../rating/rating.service';
import { AiService } from '../ai/ai.service';
export declare class GameService {
    private prisma;
    private ratingService;
    private aiService;
    constructor(prisma: PrismaService, ratingService: RatingService, aiService: AiService);
    private attachMatchState;
    private recordRoundResult;
    private recordUserOutcome;
    resetMatch(gameId: string, resetSeries?: boolean): Promise<{
        matchOver: boolean;
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
        guesses: {
            number: number;
            id: string;
            createdAt: Date;
            guess: string;
            gameId: string;
            playerId: string;
            position: number;
            round: number;
        }[];
        roundResults: {
            id: string;
            winnerId: string | null;
            guesses: number;
            gameId: string;
            round: number;
            timeMs: number;
            startedAt: Date | null;
            endedAt: Date | null;
        }[];
        id: string;
        createdAt: Date;
        updatedAt: Date;
        player1Id: string;
        player2Id: string | null;
        player1Secret: string | null;
        player2Secret: string | null;
        status: string;
        winnerId: string | null;
        resultRecorded: boolean;
        maxRounds: any;
        timeLimit: number;
        isPrivate: boolean;
        turn: string | null;
        lastChance: boolean;
        player1TimeLeft: number | null;
        player2TimeLeft: number | null;
        turnStartedAt: Date | null;
        currentRound: any;
        player1RoundWins: number;
        player2RoundWins: number;
        player1Wins: any;
        player2Wins: any;
        roundHistory: any;
    } | {
        matchOver: boolean;
        seriesWinnerId: string;
        player1RoundWins: number;
        player2RoundWins: number;
        roundResults: any[];
        id: string;
        createdAt: Date;
        updatedAt: Date;
        player1Id: string;
        player2Id: string | null;
        player1Secret: string | null;
        player2Secret: string | null;
        status: string;
        winnerId: string | null;
        resultRecorded: boolean;
        maxRounds: any;
        timeLimit: number;
        isPrivate: boolean;
        turn: string | null;
        lastChance: boolean;
        player1TimeLeft: number | null;
        player2TimeLeft: number | null;
        turnStartedAt: Date | null;
        currentRound: any;
        player1Wins: any;
        player2Wins: any;
        roundHistory: any;
    }>;
    getGameState(gameId: string): Promise<{
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
        guesses: {
            number: number;
            id: string;
            createdAt: Date;
            guess: string;
            gameId: string;
            playerId: string;
            position: number;
            round: number;
        }[];
        roundResults: {
            id: string;
            winnerId: string | null;
            guesses: number;
            gameId: string;
            round: number;
            timeMs: number;
            startedAt: Date | null;
            endedAt: Date | null;
        }[];
    } & {
        id: string;
        createdAt: Date;
        updatedAt: Date;
        player1Id: string;
        player2Id: string | null;
        player1Secret: string | null;
        player2Secret: string | null;
        status: string;
        winnerId: string | null;
        resultRecorded: boolean;
        maxRounds: number;
        timeLimit: number;
        isPrivate: boolean;
        turn: string | null;
        lastChance: boolean;
        player1TimeLeft: number | null;
        player2TimeLeft: number | null;
        turnStartedAt: Date | null;
        currentRound: number;
        player1RoundWins: number;
        player2RoundWins: number;
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
        roundResults: {
            id: string;
            winnerId: string | null;
            guesses: number;
            gameId: string;
            round: number;
            timeMs: number;
            startedAt: Date | null;
            endedAt: Date | null;
        }[];
    } & {
        id: string;
        createdAt: Date;
        updatedAt: Date;
        player1Id: string;
        player2Id: string | null;
        player1Secret: string | null;
        player2Secret: string | null;
        status: string;
        winnerId: string | null;
        resultRecorded: boolean;
        maxRounds: number;
        timeLimit: number;
        isPrivate: boolean;
        turn: string | null;
        lastChance: boolean;
        player1TimeLeft: number | null;
        player2TimeLeft: number | null;
        turnStartedAt: Date | null;
        currentRound: number;
        player1RoundWins: number;
        player2RoundWins: number;
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
        roundResults: {
            id: string;
            winnerId: string | null;
            guesses: number;
            gameId: string;
            round: number;
            timeMs: number;
            startedAt: Date | null;
            endedAt: Date | null;
        }[];
    } & {
        id: string;
        createdAt: Date;
        updatedAt: Date;
        player1Id: string;
        player2Id: string | null;
        player1Secret: string | null;
        player2Secret: string | null;
        status: string;
        winnerId: string | null;
        resultRecorded: boolean;
        maxRounds: number;
        timeLimit: number;
        isPrivate: boolean;
        turn: string | null;
        lastChance: boolean;
        player1TimeLeft: number | null;
        player2TimeLeft: number | null;
        turnStartedAt: Date | null;
        currentRound: number;
        player1RoundWins: number;
        player2RoundWins: number;
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
        id: string;
        createdAt: Date;
        updatedAt: Date;
        player1Id: string;
        player2Id: string | null;
        player1Secret: string | null;
        player2Secret: string | null;
        status: string;
        winnerId: string | null;
        resultRecorded: boolean;
        maxRounds: number;
        timeLimit: number;
        isPrivate: boolean;
        turn: string | null;
        lastChance: boolean;
        player1TimeLeft: number | null;
        player2TimeLeft: number | null;
        turnStartedAt: Date | null;
        currentRound: number;
        player1RoundWins: number;
        player2RoundWins: number;
    } & {
        currentRound: any;
        player1Wins: any;
        player2Wins: any;
        maxRounds: any;
        roundHistory: any;
    })[]>;
    cancelGame(gameId: string, playerId: string): Promise<void>;
    joinGame(gameId: string, playerId: string): Promise<{
        player1: {
            id: string;
            name: string;
        };
        player2: {
            id: string;
            name: string;
        };
        roundResults: {
            id: string;
            winnerId: string | null;
            guesses: number;
            gameId: string;
            round: number;
            timeMs: number;
            startedAt: Date | null;
            endedAt: Date | null;
        }[];
    } & {
        id: string;
        createdAt: Date;
        updatedAt: Date;
        player1Id: string;
        player2Id: string | null;
        player1Secret: string | null;
        player2Secret: string | null;
        status: string;
        winnerId: string | null;
        resultRecorded: boolean;
        maxRounds: number;
        timeLimit: number;
        isPrivate: boolean;
        turn: string | null;
        lastChance: boolean;
        player1TimeLeft: number | null;
        player2TimeLeft: number | null;
        turnStartedAt: Date | null;
        currentRound: number;
        player1RoundWins: number;
        player2RoundWins: number;
    } & {
        currentRound: any;
        player1Wins: any;
        player2Wins: any;
        maxRounds: any;
        roundHistory: any;
    }>;
    submitSecret(gameId: string, playerId: string, secret: string): Promise<{
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
        roundResults: {
            id: string;
            winnerId: string | null;
            guesses: number;
            gameId: string;
            round: number;
            timeMs: number;
            startedAt: Date | null;
            endedAt: Date | null;
        }[];
    } & {
        id: string;
        createdAt: Date;
        updatedAt: Date;
        player1Id: string;
        player2Id: string | null;
        player1Secret: string | null;
        player2Secret: string | null;
        status: string;
        winnerId: string | null;
        resultRecorded: boolean;
        maxRounds: number;
        timeLimit: number;
        isPrivate: boolean;
        turn: string | null;
        lastChance: boolean;
        player1TimeLeft: number | null;
        player2TimeLeft: number | null;
        turnStartedAt: Date | null;
        currentRound: number;
        player1RoundWins: number;
        player2RoundWins: number;
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
            guesses: {
                number: number;
                id: string;
                createdAt: Date;
                guess: string;
                gameId: string;
                playerId: string;
                position: number;
                round: number;
            }[];
            roundResults: {
                id: string;
                winnerId: string | null;
                guesses: number;
                gameId: string;
                round: number;
                timeMs: number;
                startedAt: Date | null;
                endedAt: Date | null;
            }[];
        } & {
            id: string;
            createdAt: Date;
            updatedAt: Date;
            player1Id: string;
            player2Id: string | null;
            player1Secret: string | null;
            player2Secret: string | null;
            status: string;
            winnerId: string | null;
            resultRecorded: boolean;
            maxRounds: number;
            timeLimit: number;
            isPrivate: boolean;
            turn: string | null;
            lastChance: boolean;
            player1TimeLeft: number | null;
            player2TimeLeft: number | null;
            turnStartedAt: Date | null;
            currentRound: number;
            player1RoundWins: number;
            player2RoundWins: number;
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
            guesses: {
                number: number;
                id: string;
                createdAt: Date;
                guess: string;
                gameId: string;
                playerId: string;
                position: number;
                round: number;
            }[];
            roundResults: {
                id: string;
                winnerId: string | null;
                guesses: number;
                gameId: string;
                round: number;
                timeMs: number;
                startedAt: Date | null;
                endedAt: Date | null;
            }[];
        } & {
            id: string;
            createdAt: Date;
            updatedAt: Date;
            player1Id: string;
            player2Id: string | null;
            player1Secret: string | null;
            player2Secret: string | null;
            status: string;
            winnerId: string | null;
            resultRecorded: boolean;
            maxRounds: number;
            timeLimit: number;
            isPrivate: boolean;
            turn: string | null;
            lastChance: boolean;
            player1TimeLeft: number | null;
            player2TimeLeft: number | null;
            turnStartedAt: Date | null;
            currentRound: number;
            player1RoundWins: number;
            player2RoundWins: number;
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
            guesses: {
                number: number;
                id: string;
                createdAt: Date;
                guess: string;
                gameId: string;
                playerId: string;
                position: number;
                round: number;
            }[];
            roundResults: {
                id: string;
                winnerId: string | null;
                guesses: number;
                gameId: string;
                round: number;
                timeMs: number;
                startedAt: Date | null;
                endedAt: Date | null;
            }[];
        } & {
            id: string;
            createdAt: Date;
            updatedAt: Date;
            player1Id: string;
            player2Id: string | null;
            player1Secret: string | null;
            player2Secret: string | null;
            status: string;
            winnerId: string | null;
            resultRecorded: boolean;
            maxRounds: number;
            timeLimit: number;
            isPrivate: boolean;
            turn: string | null;
            lastChance: boolean;
            player1TimeLeft: number | null;
            player2TimeLeft: number | null;
            turnStartedAt: Date | null;
            currentRound: number;
            player1RoundWins: number;
            player2RoundWins: number;
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
    getGameDetails(gameId: string, userId: string): Promise<{
        id: string;
        status: string;
        player1: {
            id: string;
            name: string;
            rating: number;
        };
        player2: {
            id: string;
            name: string;
            rating: number;
        };
        myGuesses: {
            number: number;
            id: string;
            createdAt: Date;
            guess: string;
            gameId: string;
            playerId: string;
            position: number;
            round: number;
        }[];
        opponentGuesses: {
            number: number;
            id: string;
            createdAt: Date;
            guess: string;
            gameId: string;
            playerId: string;
            position: number;
            round: number;
        }[];
        opponentSecret: string;
        mySecret: string;
    }>;
    analyzeGuess(gameId: string, userId: string, guessIndex: number): Promise<{
        analysis: string;
    }>;
}
