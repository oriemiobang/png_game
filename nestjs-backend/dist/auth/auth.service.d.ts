import { PrismaService } from '../prisma/prisma.service';
import { JwtService } from '@nestjs/jwt';
export declare class AuthService {
    private prisma;
    private jwtService;
    private googleClient;
    constructor(prisma: PrismaService, jwtService: JwtService);
    signUp(email: string, pass: string, name: string): Promise<{
        access_token: string;
        user: {
            id: string;
            email: string;
            name: string;
        };
    }>;
    signIn(email: string, pass: string): Promise<{
        access_token: string;
        user: {
            id: string;
            email: string;
            name: string;
        };
    }>;
    verifyGoogleToken(idToken: string): Promise<{
        access_token: string;
        user: {
            id: string;
            email: string;
            name: string;
        };
    }>;
    getMyStats(userId: string): Promise<{
        winRate: number;
        id: string;
        email: string | null;
        googleId: string | null;
        password: string | null;
        name: string | null;
        createdAt: Date;
        updatedAt: Date;
        gamesPlayed: number;
        wins: number;
        losses: number;
        draws: number;
        lastPlayedAt: Date | null;
    }>;
    private generateToken;
}
