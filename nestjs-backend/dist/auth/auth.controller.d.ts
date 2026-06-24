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
        matchHistory: {
            id: string;
            opponentName: string;
            opponentRating: number;
            outcome: string;
            date: Date;
        }[];
        id: string;
        email: string | null;
        password: string | null;
        name: string | null;
        googleId: string | null;
        createdAt: Date;
        updatedAt: Date;
        gamesPlayed: number;
        wins: number;
        losses: number;
        draws: number;
        rating: number;
        ratingPeak: number;
        lastPlayedAt: Date | null;
        fcmToken: string | null;
    }>;
    getLeaderboard(): Promise<{
        winRate: number;
        tier: string;
        id: string;
        name: string;
        gamesPlayed: number;
        wins: number;
        rating: number;
    }[]>;
    updateFcmToken(req: any, fcmToken: string): Promise<{
        id: string;
        email: string | null;
        password: string | null;
        name: string | null;
        googleId: string | null;
        createdAt: Date;
        updatedAt: Date;
        gamesPlayed: number;
        wins: number;
        losses: number;
        draws: number;
        rating: number;
        ratingPeak: number;
        lastPlayedAt: Date | null;
        fcmToken: string | null;
    }>;
}
