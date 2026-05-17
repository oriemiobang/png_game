import { AuthService } from './auth.service';
export declare class AuthController {
    private authService;
    constructor(authService: AuthService);
    signUp(body: any): Promise<{
        access_token: any;
        user: {
            id: string;
            email: string;
            name: string;
        };
    }>;
    signIn(body: any): Promise<{
        access_token: any;
        user: {
            id: string;
            email: string;
            name: string;
        };
    }>;
    googleSignIn(body: any): Promise<{
        access_token: any;
        user: {
            id: string;
            email: string;
            name: string;
        };
    }>;
}
