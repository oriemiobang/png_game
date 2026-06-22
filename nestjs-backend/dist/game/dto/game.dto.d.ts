export declare class JoinQueueDto {
    maxRounds: number;
    timeLimit: number;
}
export declare class CreateGameDto {
    gameId: string;
    settings?: any;
}
export declare class JoinGameDto {
    gameId: string;
}
export declare class CancelGameDto {
    gameId: string;
}
export declare class SubmitSecretDto {
    gameId: string;
    secretNumber: string;
}
export declare class MakeGuessDto {
    gameId: string;
    guess: string;
}
export declare class ChatDto {
    gameId: string;
    message: string;
}
export declare class TimeoutDto {
    gameId: string;
}
export declare class RejoinGameDto {
    gameId: string;
}
export declare class NewGameDto {
    gameId: string;
    approved?: boolean;
}
export declare class LeaveGameDto {
    gameId: string;
}
