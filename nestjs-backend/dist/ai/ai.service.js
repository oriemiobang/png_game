"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var AiService_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.AiService = void 0;
const common_1 = require("@nestjs/common");
const generative_ai_1 = require("@google/generative-ai");
let AiService = AiService_1 = class AiService {
    constructor() {
        this.logger = new common_1.Logger(AiService_1.name);
        const apiKey = process.env.GEMINI_API_KEY;
        if (apiKey) {
            this.genAI = new generative_ai_1.GoogleGenerativeAI(apiKey);
            this.model = this.genAI.getGenerativeModel({ model: 'gemini-1.5-flash' });
        }
        else {
            this.logger.warn('GEMINI_API_KEY is not set. AI Analysis will return mock data.');
        }
    }
    async analyzeGuess(secretCode, pastGuesses, currentGuess) {
        if (!this.model) {
            return "AI Analysis is currently disabled because the API key is not configured.";
        }
        const pastContext = pastGuesses.length > 0
            ? pastGuesses.map((g, i) => `Turn ${i + 1}: Guessed "${g.guess}", Result: ${g.pos} correct positions, ${g.num} correct numbers.`).join('\n')
            : 'No past guesses. This is the first turn.';
        const prompt = `You are an expert coach for a Mastermind-style game. The secret code the player is trying to guess is "${secretCode}".
The player receives feedback after each guess: "correct positions" means the digit is correct and in the right place. "correct numbers" means the digit is in the secret code but might be in the wrong place.

Here is the context of what the player has guessed so far:
${pastContext}

In the current turn, the player guessed "${currentGuess.guess}" and the result was ${currentGuess.pos} correct positions and ${currentGuess.num} correct numbers.

Analyze this current turn briefly. Did they make a logical mistake based on the previous clues? Was it a good guess? What would have been a better approach?
Keep your response concise, friendly, but professional (under 3 sentences). Do not reveal the secret code directly in your advice unless necessary to explain their blunder.`;
        try {
            const result = await this.model.generateContent(prompt);
            const response = await result.response;
            return response.text();
        }
        catch (error) {
            this.logger.error('Failed to generate AI content', error);
            return "Sorry, the AI coach is currently unavailable to analyze this move.";
        }
    }
};
exports.AiService = AiService;
exports.AiService = AiService = AiService_1 = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [])
], AiService);
//# sourceMappingURL=ai.service.js.map