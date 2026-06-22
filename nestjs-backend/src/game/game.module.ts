import { Module } from '@nestjs/common';
import { GameGateway } from './game.gateway';
import { GameService } from './game.service';
import { MatchmakingService } from './matchmaking.service';

@Module({
  providers: [GameGateway, GameService, MatchmakingService],
})
export class GameModule {}
