import { Injectable, HttpException, HttpStatus } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import { OAuth2Client } from 'google-auth-library';

@Injectable()
export class AuthService {
  private googleClient: OAuth2Client;

  constructor(
    private prisma: PrismaService,
    private jwtService: JwtService,
  ) {
    // The google client ID can be set via env, but will accept any verified audience for now
    this.googleClient = new OAuth2Client();
  }

  async signUp(email: string, pass: string, name: string) {
    const existing = await this.prisma.user.findUnique({ where: { email } });
    if (existing) {
      throw new HttpException('User with this email already exists', HttpStatus.BAD_REQUEST);
    }

    const salt = await bcrypt.genSalt(10);
    const password = await bcrypt.hash(pass, salt);

    const user = await this.prisma.user.create({
      data: { email, password, name },
    });

    return this.generateToken(user.id, user.email, user.name);
  }

  async signIn(email: string, pass: string) {
    const user = await this.prisma.user.findUnique({ where: { email } });
    if (!user) {
      throw new HttpException('Invalid credentials', HttpStatus.UNAUTHORIZED);
    }
    if (!user.password) {
      throw new HttpException('Please login with Google', HttpStatus.UNAUTHORIZED);
    }

    const isMatch = await bcrypt.compare(pass, user.password);
    if (!isMatch) {
      throw new HttpException('Invalid credentials', HttpStatus.UNAUTHORIZED);
    }

    return this.generateToken(user.id, user.email, user.name);
  }

  async verifyGoogleToken(idToken: string) {
    try {
      const ticket = await this.googleClient.verifyIdToken({
        idToken,
        // audience: process.env.GOOGLE_CLIENT_ID, // Add your client ID to .env to verify properly in production
      });
      const payload = ticket.getPayload();
      
      if (!payload || !payload.email) {
        throw new HttpException('Invalid Google Token', HttpStatus.UNAUTHORIZED);
      }

      let user = await this.prisma.user.findUnique({
        where: { googleId: payload.sub },
      });

      if (!user) {
        // Try falling back to email in case they signed up via email first
        user = await this.prisma.user.findUnique({ where: { email: payload.email } });
        
        if (user) {
          // Link google account
          user = await this.prisma.user.update({
            where: { id: user.id },
            data: { googleId: payload.sub },
          });
        } else {
          // Create new user
          user = await this.prisma.user.create({
            data: {
              email: payload.email,
              name: payload.name || 'Google User',
              googleId: payload.sub,
            },
          });
        }
      }

      return this.generateToken(user.id, user.email, user.name);
    } catch (e) {
      throw new HttpException('Google authentication failed: ' + e.message, HttpStatus.UNAUTHORIZED);
    }
  }

  async getMyStats(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        name: true,
        email: true,
        gamesPlayed: true,
        wins: true,
        losses: true,
        draws: true,
        lastPlayedAt: true,
      },
    } as any);

    if (!user) {
      throw new HttpException('User not found', HttpStatus.UNAUTHORIZED);
    }

    const winRate = user.gamesPlayed > 0 ? Math.round((user.wins / user.gamesPlayed) * 1000) / 10 : 0;

    return {
      ...user,
      winRate,
    };
  }

  private generateToken(userId: string, email: string, name: string) {
    const payload = { sub: userId, email, name };
    return {
      access_token: this.jwtService.sign(payload),
      user: { id: userId, email, name },
    };
  }
}
