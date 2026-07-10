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
            guess: string;
            id: string;
            round: number;
            gameId: string;
            createdAt: Date;
            playerId: string;
            position: number;
        }[];
        opponentGuesses: {
            number: number;
            guess: string;
            id: string;
            round: number;
            gameId: string;
            createdAt: Date;
            playerId: string;
            position: number;
        }[];
        opponentSecret: string;
        mySecret: string;
    }>;
    analyzeGuess(gameId: string, guessIndexStr: string, req: any): Promise<{
        analysis: string;
    }>;
}
