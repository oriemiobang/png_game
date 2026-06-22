"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const testing_1 = require("@nestjs/testing");
const game_service_1 = require("./game.service");
const prisma_service_1 = require("../prisma/prisma.service");
const rating_service_1 = require("../rating/rating.service");
describe('GameService', () => {
    let service;
    beforeEach(async () => {
        const mockPrismaService = {};
        const mockRatingService = {};
        const module = await testing_1.Test.createTestingModule({
            providers: [
                game_service_1.GameService,
                { provide: prisma_service_1.PrismaService, useValue: mockPrismaService },
                { provide: rating_service_1.RatingService, useValue: mockRatingService },
            ],
        }).compile();
        service = module.get(game_service_1.GameService);
    });
    it('should be defined', () => {
        expect(service).toBeDefined();
    });
    describe('generateFeedback', () => {
        it('should return 4 positions and 0 numbers for an exact match', () => {
            const feedback = service.generateFeedback('1234', '1234');
            expect(feedback).toEqual({ position: 4, number: 0 });
        });
        it('should return 0 positions and 4 numbers when all digits are correct but in wrong places', () => {
            const feedback = service.generateFeedback('4321', '1234');
            expect(feedback).toEqual({ position: 0, number: 4 });
        });
        it('should return 2 positions and 2 numbers for a partial match', () => {
            const feedback = service.generateFeedback('1243', '1234');
            expect(feedback).toEqual({ position: 2, number: 2 });
        });
        it('should return 0 positions and 0 numbers for completely wrong guess', () => {
            const feedback = service.generateFeedback('5678', '1234');
            expect(feedback).toEqual({ position: 0, number: 0 });
        });
        it('should correctly handle duplicate digits if the game allows them', () => {
            const feedback = service.generateFeedback('1122', '1212');
            expect(feedback).toEqual({ position: 2, number: 2 });
        });
    });
});
//# sourceMappingURL=game.service.spec.js.map