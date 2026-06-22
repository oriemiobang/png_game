import { Catch, ArgumentsHost, BadRequestException } from '@nestjs/common';
import { BaseWsExceptionFilter, WsException } from '@nestjs/websockets';
import { Socket } from 'socket.io';

@Catch(WsException, BadRequestException)
export class WsAllExceptionsFilter extends BaseWsExceptionFilter {
  catch(exception: unknown, host: ArgumentsHost) {
    const client = host.switchToWs().getClient<Socket>();
    
    let errorMessage = 'An error occurred';

    if (exception instanceof BadRequestException) {
      const response = exception.getResponse();
      if (typeof response === 'object' && response !== null && 'message' in response) {
        const msg = (response as any).message;
        errorMessage = Array.isArray(msg) ? msg.join(', ') : msg;
      } else {
        errorMessage = exception.message;
      }
    } else if (exception instanceof WsException) {
      errorMessage = exception.message;
    } else if (exception instanceof Error) {
      errorMessage = exception.message;
    }

    client.emit('room_error', errorMessage);
  }
}
