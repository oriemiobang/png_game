import { Injectable, ExecutionContext } from '@nestjs/common';
import { ThrottlerGuard } from '@nestjs/throttler';
import { ThrottlerRequest } from '@nestjs/throttler/dist/throttler.guard.interface';
import { WsException } from '@nestjs/websockets';

@Injectable()
export class WsThrottlerGuard extends ThrottlerGuard {
  protected async handleRequest(requestProps: ThrottlerRequest): Promise<boolean> {
    const { context, limit, ttl, throttler, blockDuration, generateKey } = requestProps;
    const client = context.switchToWs().getClient();
    
    const ip = client.conn?.remoteAddress || client.id;
    const userId = client.data?.userId || 'anonymous';
    const tracker = `${ip}-${userId}`;
    
    const key = generateKey(context, tracker, throttler.name);
    
    const { totalHits } = await this.storageService.increment(key, ttl, limit, blockDuration, throttler.name);

    if (totalHits > limit) {
      throw new WsException('Rate limit exceeded. Please wait a moment before trying again.');
    }

    return true;
  }
}
