import { Injectable } from '@nestjs/common';

@Injectable()
export class RatingService {
  /**
   * Calculates new ELO ratings for two players.
   * @param ratingA Player A's current rating
   * @param ratingB Player B's current rating
   * @param gamesPlayedA Player A's total games played
   * @param gamesPlayedB Player B's total games played
   * @param outcome 1 if A wins, 0 if B wins, 0.5 for draw
   * @returns Object containing new ratings and the rating change
   */
  calculateNewRatings(
    ratingA: number,
    ratingB: number,
    gamesPlayedA: number,
    gamesPlayedB: number,
    outcome: number, // 1 for A win, 0 for B win, 0.5 for draw
  ): {
    newRatingA: number;
    newRatingB: number;
    ratingChangeA: number;
    ratingChangeB: number;
  } {
    const getK = (gamesPlayed: number) => {
      if (gamesPlayed < 30) return 40;
      if (gamesPlayed > 100) return 20;
      return 32;
    };

    const kA = getK(gamesPlayedA);
    const kB = getK(gamesPlayedB);

    const expectedA = 1 / (1 + Math.pow(10, (ratingB - ratingA) / 400));
    const expectedB = 1 - expectedA;

    const outcomeA = outcome;
    const outcomeB = outcome === 0.5 ? 0.5 : outcome === 1 ? 0 : 1;

    const ratingChangeA = Math.round(kA * (outcomeA - expectedA));
    const ratingChangeB = Math.round(kB * (outcomeB - expectedB));

    return {
      newRatingA: ratingA + ratingChangeA,
      newRatingB: ratingB + ratingChangeB,
      ratingChangeA,
      ratingChangeB,
    };
  }
}
