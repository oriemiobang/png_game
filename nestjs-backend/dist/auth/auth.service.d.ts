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
        tier: string;
        id: string;
        name: string | null;
        createdAt: Date;
        updatedAt: Date;
        email: string | null;
        googleId: string | null;
        password: string | null;
        gamesPlayed: number;
        wins: number;
        losses: number;
        draws: number;
        rating: number;
        ratingPeak: number;
        lastPlayedAt: Date | null;
    }>;
    private generateToken;
}
