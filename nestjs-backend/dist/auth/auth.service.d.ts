import { PrismaService } from '../prisma/prisma.service';
import { JwtService } from '@nestjs/jwt';
export declare class AuthService {
    private prisma;
    private jwtService;
    private googleClient;
    constructor(prisma: PrismaService, jwtService: JwtService);
    signUp(email: string, pass: string, name: string): Promise<{
        access_token: any;
        user: {
            id: string;
            email: string;
            name: string;
        };
    }>;
    signIn(email: string, pass: string): Promise<{
        access_token: any;
        user: {
            id: string;
            email: string;
            name: string;
        };
    }>;
    verifyGoogleToken(idToken: string): Promise<{
        access_token: any;
        user: {
            id: string;
            email: string;
            name: string;
        };
    }>;
    private generateToken;
}
