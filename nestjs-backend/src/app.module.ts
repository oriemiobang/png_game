import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { ThrottlerModule } from '@nestjs/throttler';
import * as Joi from 'joi';
import { GameModule } from './game/game.module';
import { PrismaModule } from './prisma/prisma.module';
import { AuthModule } from './auth/auth.module';
import { RatingModule } from './rating/rating.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      validationSchema: Joi.object({
        DATABASE_URL: Joi.string().required(),
        JWT_SECRET: Joi.string().required(),
        GOOGLE_CLIENT_ID: Joi.string().required(),
      }),
    }),
    ThrottlerModule.forRoot([{
      ttl: 60000,
      limit: 20, // 20 requests per 60 seconds
    }]),
    GameModule, 
    PrismaModule, 
    AuthModule, 
    RatingModule
  ],
  controllers: [],
  providers: [],
})
export class AppModule {}
