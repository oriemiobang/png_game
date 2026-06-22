import { AuthService } from './auth.service';
export declare class AuthController {
    private authService;
    constructor(authService: AuthService);
    signUp(body: any): Promise<{
        access_token: string;
        user: {
            id: string;
            email: string;
            name: string;
        };
    }>;
    signIn(body: any): Promise<{
        access_token: string;
        user: {
            id: string;
            email: string;
            name: string;
        };
    }>;
    googleSignIn(body: any): Promise<{
        access_token: string;
        user: {
            id: string;
            email: string;
            name: string;
        };
    }>;
    myStats(req: any): Promise<{
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
}
