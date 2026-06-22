import { Module } from '@nestjs/common';
import { GameGateway } from './game.gateway';
import { GameService } from './game.service';
import { MatchmakingService } from './matchmaking.service';
import { RatingModule } from '../rating/rating.module';
import { AuthModule } from '../auth/auth.module';

@Module({
  imports: [RatingModule, AuthModule],
  providers: [GameGateway, GameService, MatchmakingService],
})
export class GameModule {}
