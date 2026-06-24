export declare class AiService {
    private readonly logger;
    private genAI;
    private model;
    constructor();
    analyzeGuess(secretCode: string, pastGuesses: Array<{
        guess: string;
        pos: number;
        num: number;
    }>, currentGuess: {
        guess: string;
        pos: number;
        num: number;
    }): Promise<string>;
}
