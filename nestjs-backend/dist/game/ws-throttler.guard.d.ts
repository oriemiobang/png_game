import { ThrottlerGuard } from '@nestjs/throttler';
import { ThrottlerRequest } from '@nestjs/throttler/dist/throttler.guard.interface';
export declare class WsThrottlerGuard extends ThrottlerGuard {
    protected handleRequest(requestProps: ThrottlerRequest): Promise<boolean>;
}
