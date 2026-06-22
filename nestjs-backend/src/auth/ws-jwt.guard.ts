import { CanActivate, ExecutionContext, Injectable } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { WsException } from '@nestjs/websockets';
import { Socket } from 'socket.io';

@Injectable()
export class WsJwtGuard implements CanActivate {
  constructor(private jwtService: JwtService) {}

  canActivate(context: ExecutionContext): boolean {
    const client: Socket = context.switchToWs().getClient();
    
    try {
      const token = this.extractTokenFromSocket(client);
      if (!token) {
        throw new WsException('Unauthorized access: Missing token');
      }

      const payload = this.jwtService.verify(token, {
        secret: process.env.JWT_SECRET || 'fallback-secret-for-dev',
      });
      
      client.data.userId = payload.sub;
      return true;
    } catch (err) {
      throw new WsException('Unauthorized access: Invalid token');
    }
  }

  private extractTokenFromSocket(client: Socket): string | null {
    const auth = client.handshake.auth;
    if (auth && auth.token) {
      return auth.token;
    }
    const headers = client.handshake.headers;
    if (headers && headers.authorization) {
      const parts = headers.authorization.split(' ');
      if (parts.length === 2 && parts[0] === 'Bearer') {
        return parts[1];
      }
    }
    return null;
  }
}
