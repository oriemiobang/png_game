import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { RatingService } from '../rating/rating.service';

@Injectable()
export class GameService {
  constructor(
    private prisma: PrismaService,
    private ratingService: RatingService,
  ) {}

  private attachMatchState<T extends Record<string, any>>(game: T) {
    return {
      ...game,
      currentRound: game.currentRound ?? 1,
      player1Wins: game.player1RoundWins ?? 0,
      player2Wins: game.player2RoundWins ?? 0,
      maxRounds: game.maxRounds ?? 3,
      roundHistory: (game.roundResults ?? []).map((r: any) => ({
        round: r.round,
        winnerId: r.winnerId,
        guesses: r.guesses,
        timeMs: r.timeMs,
        startedAt: r.startedAt?.toISOString() ?? null,
        endedAt: r.endedAt?.toISOString() ?? null,
      })),
    };
  }

  private async recordRoundResult(gameId: string, winnerId: string | null, game: any, roundGuesses: any[] = []) {
    const startedAt = roundGuesses[0]?.createdAt ? new Date(roundGuesses[0].createdAt) : null;
    const endedAt = roundGuesses.length > 0 ? new Date(roundGuesses[roundGuesses.length - 1].createdAt) : null;
    const timeMs = startedAt && endedAt ? Math.max(0, endedAt.getTime() - startedAt.getTime()) : 0;

    await this.prisma.roundResult.create({
      data: {
        gameId,
        round: game.currentRound,
        winnerId,
        guesses: roundGuesses.length,
        timeMs,
        startedAt,
        endedAt,
      },
    });

    if (winnerId) {
      if (winnerId === game.player1Id) {
        await this.prisma.game.update({
          where: { id: gameId },
          data: { player1RoundWins: { increment: 1 } },
        });
      } else if (winnerId === game.player2Id) {
        await this.prisma.game.update({
          where: { id: gameId },
          data: { player2RoundWins: { increment: 1 } },
        });
      }
    }
  }

  private async recordUserOutcome(game: any, winnerId: string | null, isDraw: boolean) {
    if (game.resultRecorded) {
      return { ratingChangeA: 0, ratingChangeB: 0 };
    }

    const player1Id = game.player1Id;
    const player2Id = game.player2Id;
    const now = new Date();

    let ratingChangeA = 0;
    let ratingChangeB = 0;

    if (player1Id && player2Id) {
      const p1 = await this.prisma.user.findUnique({ where: { id: player1Id } });
      const p2 = await this.prisma.user.findUnique({ where: { id: player2Id } });

      if (p1 && p2) {
        let outcome = 0.5;
        if (winnerId === player1Id) outcome = 1;
        else if (winnerId === player2Id) outcome = 0;

        const res = this.ratingService.calculateNewRatings(
          p1.rating,
          p2.rating,
          p1.gamesPlayed,
          p2.gamesPlayed,
          outcome,
        );

        ratingChangeA = res.ratingChangeA;
        ratingChangeB = res.ratingChangeB;

        await this.prisma.$transaction([
          this.prisma.user.update({
            where: { id: player1Id },
            data: {
              gamesPlayed: { increment: 1 },
              wins: winnerId === player1Id ? { increment: 1 } : undefined,
              losses: winnerId && winnerId !== player1Id && !isDraw ? { increment: 1 } : undefined,
              draws: isDraw ? { increment: 1 } : undefined,
              lastPlayedAt: now,
              rating: res.newRatingA,
              ratingPeak: res.newRatingA > p1.ratingPeak ? res.newRatingA : undefined,
            } as any,
          }),
          this.prisma.user.update({
            where: { id: player2Id },
            data: {
              gamesPlayed: { increment: 1 },
              wins: winnerId === player2Id ? { increment: 1 } : undefined,
              losses: winnerId && winnerId !== player2Id && !isDraw ? { increment: 1 } : undefined,
              draws: isDraw ? { increment: 1 } : undefined,
              lastPlayedAt: now,
              rating: res.newRatingB,
              ratingPeak: res.newRatingB > p2.ratingPeak ? res.newRatingB : undefined,
            } as any,
          }),
        ]);
      }
    } else {
      // Fallback if someone was playing alone (shouldn't really happen in standard play but just in case)
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
    }

    await this.prisma.game.update({
      where: { id: game.id },
      data: { resultRecorded: true } as any,
    });

    return { ratingChangeA, ratingChangeB };
  }

  async resetMatch(gameId: string, resetSeries = false) {
    const game = await this.prisma.game.findUnique({ where: { id: gameId } });
    if (!game) {
      throw new Error('Game not found');
    }

    if (resetSeries) {
      // Full series reset — clear everything
      await this.prisma.roundResult.deleteMany({ where: { gameId } });
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
          turnStartedAt: null,
          currentRound: 1,
          player1RoundWins: 0,
          player2RoundWins: 0,
        } as any,
        include: {
          player1: { select: { id: true, name: true, rating: true, ratingPeak: true } },
          player2: { select: { id: true, name: true, rating: true, ratingPeak: true } },
          guesses: true,
          roundResults: true,
        },
      });

      return { ...this.attachMatchState(updatedGame), matchOver: false };
    }

    // ── Advance-round path ──
    // Re-read fresh win counts (recordRoundResult may have just written them)
    const freshGame = await this.prisma.game.findUnique({
      where: { id: gameId },
      select: { player1RoundWins: true, player2RoundWins: true, maxRounds: true,
                player1Id: true, player2Id: true },
    });

    const p1Wins = freshGame?.player1RoundWins ?? 0;
    const p2Wins = freshGame?.player2RoundWins ?? 0;
    const maxRounds = freshGame?.maxRounds ?? game.maxRounds;
    const winsNeeded = Math.ceil(maxRounds / 2);

    // Check if the series is already decided
    if (p1Wins >= winsNeeded || p2Wins >= winsNeeded) {
      const seriesWinnerId = p1Wins >= winsNeeded ? freshGame!.player1Id : freshGame!.player2Id;
      // Return matchOver without touching the DB state
      return {
        ...this.attachMatchState({ ...game, player1RoundWins: p1Wins, player2RoundWins: p2Wins, roundResults: [] }),
        matchOver: true,
        seriesWinnerId,
      };
    }

    // Series not yet decided — advance the round
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
        turnStartedAt: null,
        currentRound: { increment: 1 },
      } as any,
      include: {
        player1: { select: { id: true, name: true, rating: true, ratingPeak: true } },
        player2: { select: { id: true, name: true, rating: true, ratingPeak: true } },
        guesses: true,
        roundResults: true,
      },
    });

    return { ...this.attachMatchState(updatedGame), matchOver: false };
  }

  async getGameState(gameId: string) {
    const game = await this.prisma.game.findUnique({
      where: { id: gameId },
      include: {
        player1: { select: { id: true, name: true, rating: true, ratingPeak: true } },
        player2: { select: { id: true, name: true, rating: true, ratingPeak: true } },
        guesses: true,
        roundResults: { orderBy: { round: 'asc' } },
      },
    });

    if (!game) return null;

    // Adjust timers if playing
    if (game.status === 'playing' && game.turnStartedAt && game.timeLimit > 0) {
      const now = new Date();
      const timeSpentMs = now.getTime() - game.turnStartedAt.getTime();
      if (game.turn === game.player1Id) {
        game.player1TimeLeft = Math.max(0, (game.player1TimeLeft ?? 0) - timeSpentMs);
      } else if (game.turn === game.player2Id) {
        game.player2TimeLeft = Math.max(0, (game.player2TimeLeft ?? 0) - timeSpentMs);
      }
      game.turnStartedAt = now;
    }

    return this.attachMatchState(game);
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
        player1: { select: { id: true, name: true, rating: true, ratingPeak: true } },
        player2: { select: { id: true, name: true, rating: true, ratingPeak: true } },
        roundResults: { orderBy: { round: 'asc' } },
      },
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
        player1: { select: { id: true, name: true, rating: true, ratingPeak: true } },
        player2: { select: { id: true, name: true, rating: true, ratingPeak: true } },
        roundResults: { orderBy: { round: 'asc' } },
      },
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
        player1: { select: { id: true, name: true, rating: true, ratingPeak: true } },
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
        roundResults: { orderBy: { round: 'asc' } },
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
      include: {
        player1: { select: { id: true, name: true, rating: true, ratingPeak: true } },
        player2: { select: { id: true, name: true, rating: true, ratingPeak: true } },
        roundResults: { orderBy: { round: 'asc' } },
      },
    });

    if (updatedGame.player1Secret && updatedGame.player2Secret) {
      const startedGame = await this.prisma.game.update({
        where: { id: gameId },
        data: { 
          status: 'playing', 
          turn: updatedGame.player2Id ?? updatedGame.player1Id,
          player1TimeLeft: game.timeLimit * 1000,
          player2TimeLeft: game.timeLimit * 1000,
          turnStartedAt: new Date()
        },
        include: {
          player1: { select: { id: true, name: true, rating: true, ratingPeak: true } },
          player2: { select: { id: true, name: true, rating: true, ratingPeak: true } },
          roundResults: { orderBy: { round: 'asc' } },
        },
      });
      return this.attachMatchState(startedGame);
    }

    return this.attachMatchState(updatedGame);
  }

  generateFeedback(guess: string, secret: string) {
    let position = 0;
    let number = 0;

    const secretArr = secret.split('');
    const guessArr = guess.split('');

    // Step 1: Find exact matches
    for (let i = 0; i < guessArr.length; i++) {
      if (guessArr[i] === secretArr[i]) {
        position++;
        guessArr[i] = null;
        secretArr[i] = null;
      }
    }

    // Step 2: Find number matches (right digit, wrong position)
    for (let i = 0; i < guessArr.length; i++) {
      if (guessArr[i] !== null) {
        const indexInSecret = secretArr.indexOf(guessArr[i]);
        if (indexInSecret !== -1) {
          number++;
          secretArr[indexInSecret] = null;
        }
      }
    }

    return { position, number: position + number };
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
    let newP1Time = game.player1TimeLeft ?? (game.timeLimit * 1000);
    let newP2Time = game.player2TimeLeft ?? (game.timeLimit * 1000);

    if (game.timeLimit > 0 && game.turnStartedAt) {
      const timeSpentMs = now.getTime() - new Date(game.turnStartedAt).getTime();
      if (isPlayer1) {
        newP1Time = Math.max(0, newP1Time - timeSpentMs);
      } else {
        newP2Time = Math.max(0, newP2Time - timeSpentMs);
      }

      // Check for timeout BEFORE processing guess
      if ((isPlayer1 && newP1Time <= 0) || (!isPlayer1 && newP2Time <= 0)) {
        return this.handleTimeout(gameId, playerId);
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
        round: game.currentRound,
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
      }
    }

    if (newStatus === 'finished') {
      lastChance = false;
    }

    let ratingChanges = { ratingChangeA: 0, ratingChangeB: 0 };
    let matchOver = false;
    
    if (newStatus === 'finished') {
      const roundGuesses = allGuesses.filter((guess) => guess.round === game.currentRound);
      await this.recordRoundResult(gameId, winnerId, game, roundGuesses);
      
      // Re-read fresh win counts
      const freshGame = await this.prisma.game.findUnique({
        where: { id: gameId },
        select: { player1RoundWins: true, player2RoundWins: true, maxRounds: true },
      });
      const p1Wins = freshGame?.player1RoundWins ?? 0;
      const p2Wins = freshGame?.player2RoundWins ?? 0;
      const winsNeeded = Math.ceil((freshGame?.maxRounds ?? game.maxRounds) / 2);
      
      if (p1Wins >= winsNeeded || p2Wins >= winsNeeded || game.currentRound >= game.maxRounds) {
        matchOver = true;
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
        turnStartedAt: now,
      },
      include: { 
        guesses: true,
        player1: { select: { id: true, name: true, rating: true, ratingPeak: true } },
        player2: { select: { id: true, name: true, rating: true, ratingPeak: true } },
        roundResults: { orderBy: { round: 'asc' } },
      },
    });

    if (newStatus === 'finished') {
      ratingChanges = await this.recordUserOutcome(updatedGame, winnerId, isDraw);
    }

    return { updatedGame: this.attachMatchState(updatedGame), feedback, isDraw, isTimeout: false, ratingChanges, matchOver };
  }

  async handleTimeout(gameId: string, timeoutPlayerId: string) {
    const game = await this.prisma.game.findUnique({
      where: { id: gameId },
      include: { guesses: true },
    });
    if (!game) throw new Error('Game not found');

    const opponentId = timeoutPlayerId === game.player1Id ? game.player2Id : game.player1Id;

    await this.recordRoundResult(gameId, opponentId, game);

    const updatedGame = await this.prisma.game.update({
      where: { id: gameId },
      data: { 
        status: 'finished', 
        winnerId: opponentId, 
        turn: null, 
        lastChance: false,
        ...(timeoutPlayerId === game.player1Id ? { player1TimeLeft: 0 } : { player2TimeLeft: 0 }),
      },
      include: { 
        guesses: true,
        player1: { select: { id: true, name: true, rating: true, ratingPeak: true } },
        player2: { select: { id: true, name: true, rating: true, ratingPeak: true } },
        roundResults: { orderBy: { round: 'asc' } },
      },
    });

    const p1Wins = updatedGame.player1RoundWins ?? 0;
    const p2Wins = updatedGame.player2RoundWins ?? 0;
    const winsNeeded = Math.ceil((updatedGame.maxRounds ?? 3) / 2);
    let matchOver = false;
    let ratingChanges = { ratingChangeA: 0, ratingChangeB: 0 };

    ratingChanges = await this.recordUserOutcome(updatedGame, opponentId, false);

    if (p1Wins >= winsNeeded || p2Wins >= winsNeeded || game.currentRound >= (updatedGame.maxRounds ?? 3)) {
      matchOver = true;
    }

    return { 
      updatedGame: this.attachMatchState(updatedGame), 
      feedback: { position: 0, number: 0 }, 
      isDraw: false, 
      isTimeout: true, 
      ratingChanges,
      matchOver,
    };
  }

  async forfeitGame(gameId: string, forfeiterId: string) {
    const game = await this.prisma.game.findUnique({
      where: { id: gameId },
      include: {
        player1: true,
        player2: true,
        roundResults: true,
      },
    });

    if (!game || game.status === 'finished') return null;

    const winnerId = forfeiterId === game.player1Id ? game.player2Id : game.player1Id;

    const ratingChanges = await this.recordUserOutcome(game, winnerId, false);

    const updatedGame = await this.prisma.game.update({
      where: { id: gameId },
      data: {
        status: 'finished',
        winnerId,
        resultRecorded: true,
      },
      include: {
        guesses: true,
        player1: { select: { id: true, name: true, rating: true, ratingPeak: true } },
        player2: { select: { id: true, name: true, rating: true, ratingPeak: true } },
        roundResults: { orderBy: { round: 'asc' } },
      },
    });

    return { updatedGame: this.attachMatchState(updatedGame), ratingChanges };
  }

  async getActiveGamesForUser(userId: string) {
    const games = await this.prisma.game.findMany({
      where: {
        status: 'playing',
        OR: [{ player1Id: userId }, { player2Id: userId }],
      },
      select: { id: true },
    });
    return games.map(g => g.id);
  }
}
