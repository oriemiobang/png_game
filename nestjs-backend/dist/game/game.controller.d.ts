import { GameService } from './game.service';
export declare class GameController {
    private readonly gameService;
    constructor(gameService: GameService);
    getGameDetails(gameId: string, req: any): Promise<{
        id: string;
        status: string;
        player1: {
            id: string;
            name: string;
            rating: number;
        };
        player2: {
            id: string;
            name: string;
            rating: number;
        };
        myGuesses: {
            number: number;
            id: string;
            createdAt: Date;
            gameId: string;
            playerId: string;
            guess: string;
            position: number;
            round: number;
        }[];
        opponentGuesses: {
            number: number;
            id: string;
            createdAt: Date;
            gameId: string;
            playerId: string;
            guess: string;
            position: number;
            round: number;
        }[];
        opponentSecret: string;
        mySecret: string;
    }>;
    analyzeGuess(gameId: string, guessIndexStr: string, req: any): Promise<{
        analysis: string;
    }>;
}
