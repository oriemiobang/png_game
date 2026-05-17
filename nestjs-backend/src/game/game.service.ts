import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class GameService {
  constructor(private prisma: PrismaService) {}

  // Helper to ensure user exists before creating game/guess
  async ensureUser(userId: string) {
    let user = await this.prisma.user.findUnique({ where: { id: userId } });
    if (!user) {
      user = await this.prisma.user.create({ data: { id: userId } });
    }
    return user;
  }

  async createGame(
    gameId: string,
    playerId: string,
    settings?: { maxRounds?: number; timeLimit?: number; isPrivate?: boolean },
  ) {
    await this.ensureUser(playerId);
    return this.prisma.game.create({
      data: {
        id: gameId,
        player1Id: playerId,
        maxRounds: settings?.maxRounds ?? 3,
        timeLimit: settings?.timeLimit ?? 60,
        isPrivate: settings?.isPrivate ?? false,
      },
      include: {
        player1: true,
        player2: true,
      },
    });
  }

  async getPublicRooms() {
    return this.prisma.game.findMany({
      where: {
        isPrivate: false,
        status: 'waiting',
      },
      include: {
        player1: true,
      },
    });
  }

  async joinGame(gameId: string, playerId: string) {
    await this.ensureUser(playerId);
    const game = await this.prisma.game.findUnique({ where: { id: gameId } });

    if (!game) throw new Error('Room does not exist!');
    if (game.player2Id) throw new Error('Room is already full!');

    return this.prisma.game.update({
      where: { id: gameId },
      data: {
        player2Id: playerId,
        turn: playerId, // Usually the joined player starts or we can randomize
      },
      include: {
        player1: true,
        player2: true,
      },
    });
  }

  async submitSecret(gameId: string, playerId: string, secret: string) {
    const game = await this.prisma.game.findUnique({ where: { id: gameId } });
    if (!game) throw new Error('Game not found');

    const updateData: any = {};
    if (game.player1Id === playerId) {
      updateData.player1Secret = secret;
    } else if (game.player2Id === playerId) {
      updateData.player2Secret = secret;
    }

    const updatedGame = await this.prisma.game.update({
      where: { id: gameId },
      data: updateData,
    });

    if (updatedGame.player1Secret && updatedGame.player2Secret) {
      await this.prisma.game.update({
        where: { id: gameId },
        data: { 
          status: 'playing', 
          turn: game.player2Id,
          player1TimeLeft: game.timeLimit * 60 * 1000,
          player2TimeLeft: game.timeLimit * 60 * 1000,
          lastMoveAt: new Date()
        },
      });
    }

    return updatedGame;
  }

  generateFeedback(guess: string, secret: string) {
    let position = 0;
    let number = 0;

    guess.split('').forEach((digit, index) => {
      if (secret[index] === digit) {
        position++;
      }
      if (secret.includes(digit)) {
        number++;
      }
    });

    return { position, number };
  }

  async makeGuess(gameId: string, playerId: string, guessStr: string) {
    const game = await this.prisma.game.findUnique({
      where: { id: gameId },
      include: { guesses: true },
    });
    if (!game) throw new Error('Game not found');
    if (game.turn !== playerId) throw new Error('Not your turn');

    const isPlayer1 = game.player1Id === playerId;
    const opponentId = isPlayer1 ? game.player2Id : game.player1Id;
    const secret = isPlayer1 ? game.player2Secret : game.player1Secret;

    if (!secret) throw new Error('Opponent has not set secret yet');

    // Calculate time spent
    const now = new Date();
    const timeSpentMs = now.getTime() - (game.lastMoveAt?.getTime() ?? now.getTime());
    let newP1Time = game.player1TimeLeft;
    let newP2Time = game.player2TimeLeft;

    if (game.timeLimit > 0) {
      if (isPlayer1) {
        newP1Time = Math.max(0, (newP1Time ?? 0) - timeSpentMs);
      } else {
        newP2Time = Math.max(0, (newP2Time ?? 0) - timeSpentMs);
      }

      // Check for timeout BEFORE processing guess
      if (isPlayer1 && newP1Time <= 0) {
        const updatedGame = await this.prisma.game.update({
          where: { id: gameId },
          data: { status: 'finished', winnerId: opponentId, turn: null, player1TimeLeft: 0 },
          include: { guesses: true },
        });
        return { updatedGame, feedback: { position: 0, number: 0 }, isDraw: false, isTimeout: true };
      } else if (!isPlayer1 && newP2Time <= 0) {
        const updatedGame = await this.prisma.game.update({
          where: { id: gameId },
          data: { status: 'finished', winnerId: opponentId, turn: null, player2TimeLeft: 0 },
          include: { guesses: true },
        });
        return { updatedGame, feedback: { position: 0, number: 0 }, isDraw: false, isTimeout: true };
      }
    }

    const feedback = this.generateFeedback(guessStr, secret);

    // Save guess
    await this.prisma.guess.create({
      data: {
        gameId,
        playerId,
        guess: guessStr,
        position: feedback.position,
        number: feedback.number,
      },
    });

    // Check Win/Draw logic
    const allGuesses = await this.prisma.guess.findMany({ where: { gameId } });
    const p1Guesses = allGuesses.filter((g) => g.playerId === game.player1Id);
    const p2Guesses = allGuesses.filter((g) => g.playerId === game.player2Id);

    let nextTurn = opponentId;
    let newStatus = game.status;
    let winnerId = null;
    let isDraw = false;
    let lastChance = game.lastChance;

    if (feedback.position === 4) {
      if (game.lastChance) {
        // P2 guesses correctly on last chance -> DRAW
        newStatus = 'finished';
        nextTurn = null;
        isDraw = true;
      } else if (p1Guesses.length !== p2Guesses.length) {
        // P1 guessed correctly, give P2 last chance
        lastChance = true;
      } else {
        // P2 guessed correctly first? Or no last chance needed
        newStatus = 'finished';
        nextTurn = null;
        winnerId = playerId;
      }
    } else {
      if (game.lastChance) {
        // Last chance failed -> P1 Wins
        newStatus = 'finished';
        nextTurn = null;
        winnerId = opponentId;
      } else if (p1Guesses.length >= game.maxRounds && p2Guesses.length >= game.maxRounds) {
        // Reached max rounds without winning -> Draw
        newStatus = 'finished';
        nextTurn = null;
        isDraw = true;
      }
    }

    const updatedGame = await this.prisma.game.update({
      where: { id: gameId },
      data: {
        turn: nextTurn,
        status: newStatus,
        winnerId: winnerId,
        lastChance: lastChance,
        player1TimeLeft: newP1Time,
        player2TimeLeft: newP2Time,
        lastMoveAt: now,
      },
      include: { guesses: true },
    });

    return { updatedGame, feedback, isDraw, isTimeout: false };
  }
}
