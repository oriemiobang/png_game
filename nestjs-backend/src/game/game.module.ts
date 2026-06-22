import { Module } from '@nestjs/common';
import { GameGateway } from './game.gateway';
import { GameService } from './game.service';
import { MatchmakingService } from './matchmaking.service';
import { RatingModule } from '../rating/rating.module';

@Module({
  imports: [RatingModule],
  providers: [GameGateway, GameService, MatchmakingService],
})
export class GameModule {}
