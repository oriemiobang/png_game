import { Module } from '@nestjs/common';
import { GameModule } from './game/game.module';
import { PrismaModule } from './prisma/prisma.module';
import { AuthModule } from './auth/auth.module';

@Module({
  imports: [GameModule, PrismaModule, AuthModule],
  controllers: [],
  providers: [],
})
export class AppModule {}
