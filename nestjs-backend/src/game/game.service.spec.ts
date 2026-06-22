import { Test, TestingModule } from '@nestjs/testing';
import { GameService } from './game.service';
import { PrismaService } from '../prisma/prisma.service';
import { RatingService } from '../rating/rating.service';

describe('GameService', () => {
  let service: GameService;

  beforeEach(async () => {
    // Create a mock PrismaService to avoid hitting the actual DB during simple unit tests
    const mockPrismaService = {};
    const mockRatingService = {};

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        GameService,
        { provide: PrismaService, useValue: mockPrismaService },
        { provide: RatingService, useValue: mockRatingService },
      ],
    }).compile();

    service = module.get<GameService>(GameService);
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
      // Secret has two 1s, two 2s.
      // Guess has 1 at pos 0 (correct), 1 at pos 1 (wrong pos), 2 at pos 2 (wrong pos), 2 at pos 3 (correct)
      expect(feedback).toEqual({ position: 2, number: 2 });
    });
  });
});
