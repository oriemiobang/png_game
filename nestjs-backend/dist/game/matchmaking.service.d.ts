export interface QueueEntry {
    playerId: string;
    socketId: string;
    maxRounds: number;
    timeLimit: number;
    joinedAt: Date;
    ttlTimer: ReturnType<typeof setTimeout>;
}
export declare class MatchmakingService {
    private readonly queue;
    findMatch(playerId: string, maxRounds: number, timeLimit: number): QueueEntry | null;
    addToQueue(playerId: string, socketId: string, maxRounds: number, timeLimit: number, onTimeout: () => void): void;
    removeFromQueue(playerId: string): boolean;
    removeBySocketId(socketId: string): string | null;
    get queueSize(): number;
}
