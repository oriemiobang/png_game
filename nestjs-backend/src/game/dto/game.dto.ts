import { IsString, IsNotEmpty, IsNumber, Min, Max, IsOptional, Length, IsBoolean } from 'class-validator';

export class JoinQueueDto {
  @IsNumber()
  @Min(1)
  @Max(10)
  maxRounds: number;

  @IsNumber()
  @Min(0)
  timeLimit: number;
}

export class CreateGameDto {
  @IsString()
  @IsNotEmpty()
  gameId: string;

  @IsOptional()
  settings?: any;
}

export class JoinGameDto {
  @IsString()
  @IsNotEmpty()
  gameId: string;
}

export class CancelGameDto {
  @IsString()
  @IsNotEmpty()
  gameId: string;
}

export class SubmitSecretDto {
  @IsString()
  @IsNotEmpty()
  gameId: string;

  @IsString()
  @Length(4, 4)
  secretNumber: string;
}

export class MakeGuessDto {
  @IsString()
  @IsNotEmpty()
  gameId: string;

  @IsString()
  @Length(4, 4, { message: 'guess must be exactly 4 characters' })
  guess: string;
}

export class ChatDto {
  @IsString()
  @IsNotEmpty()
  gameId: string;

  @IsString()
  @IsNotEmpty()
  message: string;
}

export class TimeoutDto {
  @IsString()
  @IsNotEmpty()
  gameId: string;
}

export class RejoinGameDto {
  @IsString()
  @IsNotEmpty()
  gameId: string;
}

export class NewGameDto {
  @IsString()
  @IsNotEmpty()
  gameId: string;

  @IsOptional()
  @IsBoolean()
  approved?: boolean;
}

export class LeaveGameDto {
  @IsString()
  @IsNotEmpty()
  gameId: string;
}
