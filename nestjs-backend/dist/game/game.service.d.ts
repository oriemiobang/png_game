import { PrismaService } from '../prisma/prisma.service';
export declare class GameService {
    private prisma;
    constructor(prisma: PrismaService);
    ensureUser(userId: string): Promise<{
        id: string;
        email: string | null;
        googleId: string | null;
        password: string | null;
        name: string | null;
        createdAt: Date;
        updatedAt: Date;
    }>;
    createGame(gameId: string, playerId: string, settings?: {
        maxRounds?: number;
        timeLimit?: number;
        isPrivate?: boolean;
    }): Promise<{
        player1: {
            id: string;
            email: string | null;
            googleId: string | null;
            password: string | null;
            name: string | null;
            createdAt: Date;
            updatedAt: Date;
        };
        player2: {
            id: string;
            email: string | null;
            googleId: string | null;
            password: string | null;
            name: string | null;
            createdAt: Date;
            updatedAt: Date;
        };
    } & {
        id: string;
        createdAt: Date;
        updatedAt: Date;
        player1Secret: string | null;
        player2Secret: string | null;
        status: string;
        maxRounds: number;
        timeLimit: number;
        isPrivate: boolean;
        turn: string | null;
        lastChance: boolean;
        player1TimeLeft: number | null;
        player2TimeLeft: number | null;
        lastMoveAt: Date | null;
        player1Id: string;
        player2Id: string | null;
        winnerId: string | null;
    }>;
    getPublicRooms(): Promise<({
        player1: {
            id: string;
            email: string | null;
            googleId: string | null;
            password: string | null;
            name: string | null;
            createdAt: Date;
            updatedAt: Date;
        };
    } & {
        id: string;
        createdAt: Date;
        updatedAt: Date;
        player1Secret: string | null;
        player2Secret: string | null;
        status: string;
        maxRounds: number;
        timeLimit: number;
        isPrivate: boolean;
        turn: string | null;
        lastChance: boolean;
        player1TimeLeft: number | null;
        player2TimeLeft: number | null;
        lastMoveAt: Date | null;
        player1Id: string;
        player2Id: string | null;
        winnerId: string | null;
    })[]>;
    joinGame(gameId: string, playerId: string): Promise<{
        player1: {
            id: string;
            email: string | null;
            googleId: string | null;
            password: string | null;
            name: string | null;
            createdAt: Date;
            updatedAt: Date;
        };
        player2: {
            id: string;
            email: string | null;
            googleId: string | null;
            password: string | null;
            name: string | null;
            createdAt: Date;
            updatedAt: Date;
        };
    } & {
        id: string;
        createdAt: Date;
        updatedAt: Date;
        player1Secret: string | null;
        player2Secret: string | null;
        status: string;
        maxRounds: number;
        timeLimit: number;
        isPrivate: boolean;
        turn: string | null;
        lastChance: boolean;
        player1TimeLeft: number | null;
        player2TimeLeft: number | null;
        lastMoveAt: Date | null;
        player1Id: string;
        player2Id: string | null;
        winnerId: string | null;
    }>;
    submitSecret(gameId: string, playerId: string, secret: string): Promise<{
        id: string;
        createdAt: Date;
        updatedAt: Date;
        player1Secret: string | null;
        player2Secret: string | null;
        status: string;
        maxRounds: number;
        timeLimit: number;
        isPrivate: boolean;
        turn: string | null;
        lastChance: boolean;
        player1TimeLeft: number | null;
        player2TimeLeft: number | null;
        lastMoveAt: Date | null;
        player1Id: string;
        player2Id: string | null;
        winnerId: string | null;
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
            createdAt: Date;
            updatedAt: Date;
            player1Secret: string | null;
            player2Secret: string | null;
            status: string;
            maxRounds: number;
            timeLimit: number;
            isPrivate: boolean;
            turn: string | null;
            lastChance: boolean;
            player1TimeLeft: number | null;
            player2TimeLeft: number | null;
            lastMoveAt: Date | null;
            player1Id: string;
            player2Id: string | null;
            winnerId: string | null;
        };
        feedback: {
            position: number;
            number: number;
        };
        isDraw: boolean;
        isTimeout: boolean;
    }>;
}
