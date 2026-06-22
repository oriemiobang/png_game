import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

type MatchState = {
  currentRound: number;
  player1Wins: number;
  player2Wins: number;
  maxRounds: number;
  roundHistory: Array<{
    round: number;
    winnerId: string | null;
    guesses: number;
    timeMs: number;
    startedAt: string | null;
    endedAt: string | null;
  }>;
};

@Injectable()
export class GameService {
  private readonly matchStates = new Map<string, MatchState>();

  constructor(private prisma: PrismaService) {}

  private getMatchState(gameId: string, maxRounds: number): MatchState {
    const existing = this.matchStates.get(gameId);
    if (existing) {
      if (existing.maxRounds !== maxRounds) {
        existing.maxRounds = maxRounds;
      }
      return existing;
    }

    const created: MatchState = {
      currentRound: 1,
      player1Wins: 0,
      player2Wins: 0,
      maxRounds,
      roundHistory: [],
    };
    this.matchStates.set(gameId, created);
    return created;
  }

  private attachMatchState<T extends Record<string, any>>(game: T) {
    const state = this.getMatchState(game.id, game.maxRounds ?? 3);
    return {
      ...game,
      currentRound: state.currentRound,
      player1Wins: state.player1Wins,
      player2Wins: state.player2Wins,
      maxRounds: state.maxRounds,
      roundHistory: state.roundHistory,
    };
  }

  private recordRoundResult(gameId: string, winnerId: string | null, game: any, roundGuesses: any[] = []) {
    if (!winnerId) {
      const state = this.getMatchState(gameId, game.maxRounds ?? 3);
      const startedAt = roundGuesses[0]?.createdAt ? new Date(roundGuesses[0].createdAt) : null;
      const endedAt = roundGuesses.length > 0 ? new Date(roundGuesses[roundGuesses.length - 1].createdAt) : null;
      state.roundHistory.push({
        round: state.currentRound,
        winnerId: null,
        guesses: roundGuesses.length,
        timeMs: startedAt && endedAt ? Math.max(0, endedAt.getTime() - startedAt.getTime()) : 0,
        startedAt: startedAt?.toISOString() ?? null,
        endedAt: endedAt?.toISOString() ?? null,
      });
      return;
    }

    const state = this.getMatchState(gameId, game.maxRounds ?? 3);
    if (winnerId === game.player1Id) {
      state.player1Wins += 1;
    } else if (winnerId === game.player2Id) {
      state.player2Wins += 1;
    }

    const startedAt = roundGuesses[0]?.createdAt ? new Date(roundGuesses[0].createdAt) : null;
    const endedAt = roundGuesses.length > 0 ? new Date(roundGuesses[roundGuesses.length - 1].createdAt) : null;
    state.roundHistory.push({
      round: state.currentRound,
      winnerId,
      guesses: roundGuesses.length,
      timeMs: startedAt && endedAt ? Math.max(0, endedAt.getTime() - startedAt.getTime()) : 0,
      startedAt: startedAt?.toISOString() ?? null,
      endedAt: endedAt?.toISOString() ?? null,
    });
  }

  private async recordUserOutcome(game: any, winnerId: string | null, isDraw: boolean) {
    if (game.resultRecorded) {
      return;
    }

    const player1Id = game.player1Id;
    const player2Id = game.player2Id;
    const now = new Date();

    if (player1Id) {
      await this.prisma.user.update({
        where: { id: player1Id },
        data: {
          gamesPlayed: { increment: 1 },
          wins: winnerId === player1Id ? { increment: 1 } : undefined,
          losses: winnerId && winnerId !== player1Id && !isDraw ? { increment: 1 } : undefined,
          draws: isDraw ? { increment: 1 } : undefined,
          lastPlayedAt: now,
        } as any,
      });
    }

    if (player2Id) {
      await this.prisma.user.update({
        where: { id: player2Id },
        data: {
          gamesPlayed: { increment: 1 },
          wins: winnerId === player2Id ? { increment: 1 } : undefined,
          losses: winnerId && winnerId !== player2Id && !isDraw ? { increment: 1 } : undefined,
          draws: isDraw ? { increment: 1 } : undefined,
          lastPlayedAt: now,
        } as any,
      });
    }

    await this.prisma.game.update({
      where: { id: game.id },
      data: { resultRecorded: true } as any,
    });
  }

  async resetMatch(gameId: string, resetSeries = false) {
    const game = await this.prisma.game.findUnique({ where: { id: gameId } });
    if (!game) {
      throw new Error('Game not found');
    }

    const state = this.getMatchState(gameId, game.maxRounds);
    const nextState: MatchState = resetSeries
      ? {
          currentRound: 1,
          player1Wins: 0,
          player2Wins: 0,
          maxRounds: game.maxRounds,
          roundHistory: [],
        }
      : {
          currentRound: Math.min(state.currentRound + 1, game.maxRounds),
          player1Wins: state.player1Wins,
          player2Wins: state.player2Wins,
          maxRounds: game.maxRounds,
          roundHistory: state.roundHistory,
        };

    this.matchStates.set(gameId, nextState);

    await this.prisma.guess.deleteMany({ where: { gameId } });

    const updatedGame = await this.prisma.game.update({
      where: { id: gameId },
      data: {
        status: 'waiting',
        winnerId: null,
        resultRecorded: false,
        turn: null,
        lastChance: false,
        player1Secret: null,
        player2Secret: null,
        player1TimeLeft: null,
        player2TimeLeft: null,
        lastMoveAt: null,
      } as any,
      include: {
        player1: { select: { id: true } },
        player2: { select: { id: true } },
        guesses: true,
      },
    });

    return this.attachMatchState(updatedGame);
  }

  // Helper to ensure user exists before creating game/guess
  async ensureUser(userId: string) {
    let user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: { id: true },
    });
    if (!user) {
      user = await this.prisma.user.create({
        data: { id: userId },
        select: { id: true },
      });
    }
    return user;
  }

  async createGame(
    gameId: string,
    playerId: string,
    settings?: { maxRounds?: number; timeLimit?: number; isPrivate?: boolean },
  ) {
    await this.ensureUser(playerId);
    const game = await this.prisma.game.create({
      data: {
        id: gameId,
        player1Id: playerId,
        maxRounds: settings?.maxRounds ?? 3,
        timeLimit: settings?.timeLimit ?? 60,
        isPrivate: settings?.isPrivate ?? false,
        resultRecorded: false,
      } as any,
      include: {
        player1: { select: { id: true } },
        player2: { select: { id: true } },
      },
    });

    this.matchStates.set(gameId, {
      currentRound: 1,
      player1Wins: 0,
      player2Wins: 0,
      maxRounds: game.maxRounds,
      roundHistory: [],
    });

    return this.attachMatchState(game);
  }

  /**
   * Creates a game that already has both players assigned — used exclusively
   * by the matchmaking flow so neither player has to click "Join".
   */
  async createGameForMatch(
    gameId: string,
    player1Id: string,
    player2Id: string,
    settings: { maxRounds: number; timeLimit: number },
  ) {
    await this.ensureUser(player1Id);
    await this.ensureUser(player2Id);

    const game = await this.prisma.game.create({
      data: {
        id: gameId,
        player1Id,
        player2Id,
        maxRounds: settings.maxRounds,
        timeLimit: settings.timeLimit,
        isPrivate: false,
        resultRecorded: false,
        // Set initial turn to player2 (joiner) — consistent with joinGame()
        turn: player2Id,
      } as any,
      include: {
        player1: { select: { id: true } },
        player2: { select: { id: true } },
      },
    });

    this.matchStates.set(gameId, {
      currentRound: 1,
      player1Wins: 0,
      player2Wins: 0,
      maxRounds: game.maxRounds,
      roundHistory: [],
    });

    return this.attachMatchState(game);
  }

  async getPublicRooms() {
    const rooms = await this.prisma.game.findMany({
      where: {
        isPrivate: false,
        status: 'waiting',
      },
      include: {
        player1: { select: { id: true } },
      },
    });

    return rooms.map((room) => this.attachMatchState(room));
  }

  /**
   * Cancel (delete) a waiting room created by the given player.
   * Only works while the game is still in 'waiting' status.
   */
  async cancelGame(gameId: string, playerId: string) {
    const game = await this.prisma.game.findUnique({ where: { id: gameId } });
    if (!game) throw new Error('Room not found');
    if (game.player1Id !== playerId) throw new Error('Only the host can cancel the room');
    if (game.status !== 'waiting') throw new Error('Cannot cancel a game that has already started');

    // Delete guesses first (FK constraint), then the game
    await this.prisma.guess.deleteMany({ where: { gameId } });
    await this.prisma.game.delete({ where: { id: gameId } });

    // Clean up in-memory state
    this.matchStates.delete(gameId);
  }

  async joinGame(gameId: string, playerId: string) {
    await this.ensureUser(playerId);
    const game = await this.prisma.game.findUnique({ where: { id: gameId } });

    if (!game) throw new Error('Room does not exist!');
    if (game.player2Id) throw new Error('Room is already full!');

    const updatedGame = await this.prisma.game.update({
      where: { id: gameId },
      data: {
        player2Id: playerId,
        turn: playerId, // Usually the joined player starts or we can randomize
      },
      include: {
        player1: { select: { id: true, name: true } },
        player2: { select: { id: true, name: true } },
      },
    });

    return this.attachMatchState(updatedGame);
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
      const startedGame = await this.prisma.game.update({
        where: { id: gameId },
        data: { 
          status: 'playing', 
          turn: game.player2Id,
          player1TimeLeft: game.timeLimit * 60 * 1000,
          player2TimeLeft: game.timeLimit * 60 * 1000,
          lastMoveAt: new Date()
        },
      });
      return this.attachMatchState(startedGame);
    }

    return this.attachMatchState(updatedGame);
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

    const state = this.getMatchState(gameId, game.maxRounds);

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
        this.recordRoundResult(gameId, opponentId, game);
        await this.recordUserOutcome(updatedGame, opponentId, false);
        return { updatedGame: this.attachMatchState(updatedGame), feedback: { position: 0, number: 0 }, isDraw: false, isTimeout: true };
      } else if (!isPlayer1 && newP2Time <= 0) {
        const updatedGame = await this.prisma.game.update({
          where: { id: gameId },
          data: { status: 'finished', winnerId: opponentId, turn: null, player2TimeLeft: 0 },
          include: { guesses: true },
        });
        this.recordRoundResult(gameId, opponentId, game);
        await this.recordUserOutcome(updatedGame, opponentId, false);
        return { updatedGame: this.attachMatchState(updatedGame), feedback: { position: 0, number: 0 }, isDraw: false, isTimeout: true };
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
        round: state.currentRound,
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

    if (newStatus === 'finished') {
      const roundGuesses = allGuesses.filter((guess) => guess.round === state.currentRound);

      this.recordRoundResult(gameId, winnerId, game, roundGuesses);

      if (state.currentRound >= game.maxRounds) {
        await this.recordUserOutcome(updatedGame, winnerId, isDraw);
      }
    }

    return { updatedGame: this.attachMatchState(updatedGame), feedback, isDraw, isTimeout: false };
  }
}
