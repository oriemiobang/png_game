export declare class RatingService {
    calculateNewRatings(ratingA: number, ratingB: number, gamesPlayedA: number, gamesPlayedB: number, outcome: number): {
        newRatingA: number;
        newRatingB: number;
        ratingChangeA: number;
        ratingChangeB: number;
    };
}
