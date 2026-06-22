import { Module } from '@nestjs/common';
import { GameModule } from './game/game.module';
import { PrismaModule } from './prisma/prisma.module';
import { AuthModule } from './auth/auth.module';
import { RatingModule } from './rating/rating.module';

@Module({
  imports: [GameModule, PrismaModule, AuthModule, RatingModule],
  controllers: [],
  providers: [],
})
export class AppModule {}
