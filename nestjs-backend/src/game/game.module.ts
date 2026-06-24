import { Module } from '@nestjs/common';
import { GameGateway } from './game.gateway';
import { GameService } from './game.service';
import { MatchmakingService } from './matchmaking.service';
import { RatingModule } from '../rating/rating.module';
import { AuthModule } from '../auth/auth.module';
import { AiModule } from '../ai/ai.module';
import { GameController } from './game.controller';

@Module({
  imports: [RatingModule, AuthModule, AiModule],
  controllers: [GameController],
  providers: [GameGateway, GameService, MatchmakingService],
})
export class GameModule {}
