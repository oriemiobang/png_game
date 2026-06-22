import { Injectable } from '@nestjs/common';
import { Server } from 'socket.io';

export interface QueueEntry {
  playerId: string;
  socketId: string;
  maxRounds: number;
  timeLimit: number; // in minutes (0 = no timer)
  joinedAt: Date;
  ttlTimer: ReturnType<typeof setTimeout>;
}

/** Tolerance in minutes: 0 means exact match only. */
const TIME_LIMIT_TOLERANCE = 0;
const QUEUE_TTL_MS = 5 * 60 * 1000; // 5 minutes

@Injectable()
export class MatchmakingService {
  /** Map<playerId, QueueEntry> */
  private readonly queue = new Map<string, QueueEntry>();

  /**
   * Try to find a compatible opponent for the given settings.
   * Returns the matched QueueEntry (and removes it from the queue) or null.
   */
  findMatch(
    playerId: string,
    maxRounds: number,
    timeLimit: number,
  ): QueueEntry | null {
    for (const [queuedPlayerId, entry] of this.queue.entries()) {
      if (queuedPlayerId === playerId) continue; // don't match yourself

      const roundsMatch = entry.maxRounds === maxRounds;
      const timeMatch =
        Math.abs(entry.timeLimit - timeLimit) <= TIME_LIMIT_TOLERANCE;

      if (roundsMatch && timeMatch) {
        // Found a match — remove from queue and cancel their TTL timer
        clearTimeout(entry.ttlTimer);
        this.queue.delete(queuedPlayerId);
        return entry;
      }
    }
    return null;
  }

  /**
   * Add a player to the matchmaking queue.
   * The `onTimeout` callback is invoked when the TTL expires.
   */
  addToQueue(
    playerId: string,
    socketId: string,
    maxRounds: number,
    timeLimit: number,
    onTimeout: () => void,
  ): void {
    // Remove any existing entry for this player first (re-queueing)
    this.removeFromQueue(playerId);

    const ttlTimer = setTimeout(() => {
      this.queue.delete(playerId);
      onTimeout();
    }, QUEUE_TTL_MS);

    this.queue.set(playerId, {
      playerId,
      socketId,
      maxRounds,
      timeLimit,
      joinedAt: new Date(),
      ttlTimer,
    });
  }

  /**
   * Remove a player from the queue (cancel search or on disconnect).
   * Returns true if the player was in the queue.
   */
  removeFromQueue(playerId: string): boolean {
    const entry = this.queue.get(playerId);
    if (!entry) return false;
    clearTimeout(entry.ttlTimer);
    this.queue.delete(playerId);
    return true;
  }

  /**
   * Remove a player from the queue by their socket ID.
   * Used when a socket disconnects and we don't know the playerId.
   */
  removeBySocketId(socketId: string): string | null {
    for (const [playerId, entry] of this.queue.entries()) {
      if (entry.socketId === socketId) {
        clearTimeout(entry.ttlTimer);
        this.queue.delete(playerId);
        return playerId;
      }
    }
    return null;
  }

  /** How many players are currently searching. */
  get queueSize(): number {
    return this.queue.size;
  }
}
