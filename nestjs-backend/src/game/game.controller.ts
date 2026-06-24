import { Controller, Get, Param, UseGuards, Req, HttpException, HttpStatus } from '@nestjs/common';
import { GameService } from './game.service';
import { AuthGuard } from '@nestjs/passport';

@Controller('game')
@UseGuards(AuthGuard('jwt'))
export class GameController {
  constructor(private readonly gameService: GameService) {}

  @Get(':id')
  async getGameDetails(@Param('id') gameId: string, @Req() req: any) {
    const userId = req.user.userId;
    return this.gameService.getGameDetails(gameId, userId);
  }

  @Get(':id/analyze/:guessIndex')
  async analyzeGuess(
    @Param('id') gameId: string,
    @Param('guessIndex') guessIndexStr: string,
    @Req() req: any
  ) {
    const userId = req.user.userId;
    const guessIndex = parseInt(guessIndexStr, 10);

    if (isNaN(guessIndex) || guessIndex < 0) {
      throw new HttpException('Invalid guess index', HttpStatus.BAD_REQUEST);
    }

    return this.gameService.analyzeGuess(gameId, userId, guessIndex);
  }
}
