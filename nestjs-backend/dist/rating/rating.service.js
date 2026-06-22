"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.RatingService = void 0;
const common_1 = require("@nestjs/common");
let RatingService = class RatingService {
    calculateNewRatings(ratingA, ratingB, gamesPlayedA, gamesPlayedB, outcome) {
        const getK = (gamesPlayed) => {
            if (gamesPlayed < 30)
                return 40;
            if (gamesPlayed > 100)
                return 20;
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
};
exports.RatingService = RatingService;
exports.RatingService = RatingService = __decorate([
    (0, common_1.Injectable)()
], RatingService);
//# sourceMappingURL=rating.service.js.map