import { Injectable, Logger } from '@nestjs/common';
import { GoogleGenerativeAI } from '@google/generative-ai';

@Injectable()
export class AiService {
  private readonly logger = new Logger(AiService.name);
  private genAI: GoogleGenerativeAI;
  private model: any;

  constructor() {
    const apiKey = process.env.GEMINI_API_KEY;
    if (apiKey) {
      this.genAI = new GoogleGenerativeAI(apiKey);
      this.model = this.genAI.getGenerativeModel({ model: 'gemini-pro' });
    } else {
      this.logger.warn('GEMINI_API_KEY is not set. AI Analysis will return mock data.');
    }
  }

  async analyzeGuess(
    secretCode: string,
    pastGuesses: Array<{ guess: string; pos: number; num: number }>,
    currentGuess: { guess: string; pos: number; num: number }
  ): Promise<string> {
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
    } catch (error) {
      this.logger.error('Failed to generate AI content', error);
      return "Sorry, the AI coach is currently unavailable to analyze this move.";
    }
  }
}
