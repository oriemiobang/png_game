import { PrismaService } from '../prisma/prisma.service';
export declare class GameService {
    private prisma;
    private readonly matchStates;
    constructor(prisma: PrismaService);
    private getMatchState;
    private attachMatchState;
    private recordRoundResult;
    private recordUserOutcome;
    resetMatch(gameId: string, resetSeries?: boolean): Promise<{
        guesses: {
            number: number;
            guess: string;
            id: string;
            createdAt: Date;
            gameId: string;
            playerId: string;
            position: number;
            round: number;
        }[];
        player1: {
            id: string;
        };
        player2: {
            id: string;
        };
    } & {
        id: string;
        maxRounds: number;
        createdAt: Date;
        updatedAt: Date;
        player1Id: string;
        player2Id: string | null;
        player1Secret: string | null;
        player2Secret: string | null;
        status: string;
        winnerId: string | null;
        resultRecorded: boolean;
        timeLimit: number;
        isPrivate: boolean;
        turn: string | null;
        lastChance: boolean;
        player1TimeLeft: number | null;
        player2TimeLeft: number | null;
        lastMoveAt: Date | null;
    } & {
        currentRound: number;
        player1Wins: number;
        player2Wins: number;
        maxRounds: number;
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
        };
        player2: {
            id: string;
        };
    } & {
        id: string;
        maxRounds: number;
        createdAt: Date;
        updatedAt: Date;
        player1Id: string;
        player2Id: string | null;
        player1Secret: string | null;
        player2Secret: string | null;
        status: string;
        winnerId: string | null;
        resultRecorded: boolean;
        timeLimit: number;
        isPrivate: boolean;
        turn: string | null;
        lastChance: boolean;
        player1TimeLeft: number | null;
        player2TimeLeft: number | null;
        lastMoveAt: Date | null;
    } & {
        currentRound: number;
        player1Wins: number;
        player2Wins: number;
        maxRounds: number;
    }>;
    getPublicRooms(): Promise<({
        player1: {
            id: string;
        };
    } & {
        id: string;
        maxRounds: number;
        createdAt: Date;
        updatedAt: Date;
        player1Id: string;
        player2Id: string | null;
        player1Secret: string | null;
        player2Secret: string | null;
        status: string;
        winnerId: string | null;
        resultRecorded: boolean;
        timeLimit: number;
        isPrivate: boolean;
        turn: string | null;
        lastChance: boolean;
        player1TimeLeft: number | null;
        player2TimeLeft: number | null;
        lastMoveAt: Date | null;
    } & {
        currentRound: number;
        player1Wins: number;
        player2Wins: number;
        maxRounds: number;
    })[]>;
    joinGame(gameId: string, playerId: string): Promise<{
        player1: {
            id: string;
        };
        player2: {
            id: string;
        };
    } & {
        id: string;
        maxRounds: number;
        createdAt: Date;
        updatedAt: Date;
        player1Id: string;
        player2Id: string | null;
        player1Secret: string | null;
        player2Secret: string | null;
        status: string;
        winnerId: string | null;
        resultRecorded: boolean;
        timeLimit: number;
        isPrivate: boolean;
        turn: string | null;
        lastChance: boolean;
        player1TimeLeft: number | null;
        player2TimeLeft: number | null;
        lastMoveAt: Date | null;
    } & {
        currentRound: number;
        player1Wins: number;
        player2Wins: number;
        maxRounds: number;
    }>;
    submitSecret(gameId: string, playerId: string, secret: string): Promise<{
        id: string;
        maxRounds: number;
        createdAt: Date;
        updatedAt: Date;
        player1Id: string;
        player2Id: string | null;
        player1Secret: string | null;
        player2Secret: string | null;
        status: string;
        winnerId: string | null;
        resultRecorded: boolean;
        timeLimit: number;
        isPrivate: boolean;
        turn: string | null;
        lastChance: boolean;
        player1TimeLeft: number | null;
        player2TimeLeft: number | null;
        lastMoveAt: Date | null;
    } & {
        currentRound: number;
        player1Wins: number;
        player2Wins: number;
        maxRounds: number;
    }>;
    generateFeedback(guess: string, secret: string): {
        position: number;
        number: number;
    };
    makeGuess(gameId: string, playerId: string, guessStr: string): Promise<{
        updatedGame: {
            guesses: {
                number: number;
                guess: string;
                id: string;
                createdAt: Date;
                gameId: string;
                playerId: string;
                position: number;
                round: number;
            }[];
        } & {
            id: string;
            maxRounds: number;
            createdAt: Date;
            updatedAt: Date;
            player1Id: string;
            player2Id: string | null;
            player1Secret: string | null;
            player2Secret: string | null;
            status: string;
            winnerId: string | null;
            resultRecorded: boolean;
            timeLimit: number;
            isPrivate: boolean;
            turn: string | null;
            lastChance: boolean;
            player1TimeLeft: number | null;
            player2TimeLeft: number | null;
            lastMoveAt: Date | null;
        } & {
            currentRound: number;
            player1Wins: number;
            player2Wins: number;
            maxRounds: number;
        };
        feedback: {
            position: number;
            number: number;
        };
        isDraw: boolean;
        isTimeout: boolean;
    }>;
}
