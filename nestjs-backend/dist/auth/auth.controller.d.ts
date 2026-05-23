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
}
