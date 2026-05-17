import { Trophy, TrendingUp, Target, Clock, Home, RotateCcw } from 'lucide-react';
import { Button } from './ui/button';
import { Card, CardContent } from './ui/card';
import { Badge } from './ui/badge';

interface GameResultProps {
  onNavigate: (screen: string) => void;
}

export function GameResult({ onNavigate }: GameResultProps) {
  const winner = true; // true if player won, false if lost
  const stats = {
    finalScore: { player: 3, opponent: 2 },
    totalRounds: 5,
    averageGuesses: 6.2,
    totalTime: '8:45',
    bestRound: 4,
  };

  return (
    <div className="h-full flex flex-col bg-gradient-to-b from-slate-50 to-slate-100 dark:from-slate-900 dark:to-slate-800">
      {/* Hero Section */}
      <div className={`px-6 pt-12 pb-8 text-center ${
        winner 
          ? 'bg-gradient-to-br from-amber-400 via-yellow-500 to-orange-500' 
          : 'bg-gradient-to-br from-slate-600 via-slate-700 to-slate-800'
      }`}>
        <div className="mb-4">
          {winner ? (
            <div className="inline-flex items-center justify-center w-24 h-24 bg-white rounded-full shadow-xl mb-4 animate-bounce">
              <Trophy className="h-12 w-12 text-amber-500" />
            </div>
          ) : (
            <div className="inline-flex items-center justify-center w-24 h-24 bg-white/10 rounded-full mb-4">
              <Trophy className="h-12 w-12 text-white/70" />
            </div>
          )}
        </div>
        
        <h1 className="text-white text-3xl mb-2">
          {winner ? 'Victory!' : 'Defeat'}
        </h1>
        <p className="text-white/90 text-sm">
          {winner ? 'Congratulations! You won the match!' : 'Better luck next time!'}
        </p>
      </div>

      {/* Score Card */}
      <div className="px-6 -mt-6 mb-6">
        <Card className="shadow-xl border-0 dark:bg-slate-950 dark:border-slate-800">
          <CardContent className="p-6">
            <div className="text-center mb-6">
              <div className="text-sm text-slate-500 dark:text-slate-400 mb-2">Final Score</div>
              <div className="flex items-center justify-center gap-4">
                <div className="flex-1 text-right">
                  <div className="text-3xl text-slate-900 dark:text-white mb-1">{stats.finalScore.player}</div>
                  <div className="text-xs text-slate-500 dark:text-slate-400">You</div>
                </div>
                <div className="text-2xl text-slate-400">-</div>
                <div className="flex-1 text-left">
                  <div className="text-3xl text-slate-900 dark:text-white mb-1">{stats.finalScore.opponent}</div>
                  <div className="text-xs text-slate-500 dark:text-slate-400">Opponent</div>
                </div>
              </div>
            </div>

            <div className="space-y-3 pt-4 border-t dark:border-slate-800">
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-2 text-slate-600 dark:text-slate-400">
                  <Trophy className="h-4 w-4" />
                  <span className="text-sm">Total Rounds</span>
                </div>
                <span className="text-sm text-slate-900 dark:text-white">{stats.totalRounds}</span>
              </div>
              
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-2 text-slate-600 dark:text-slate-400">
                  <Target className="h-4 w-4" />
                  <span className="text-sm">Avg. Guesses</span>
                </div>
                <span className="text-sm text-slate-900 dark:text-white">{stats.averageGuesses}</span>
              </div>
              
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-2 text-slate-600 dark:text-slate-400">
                  <Clock className="h-4 w-4" />
                  <span className="text-sm">Total Time</span>
                </div>
                <span className="text-sm text-slate-900 dark:text-white">{stats.totalTime}</span>
              </div>
              
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-2 text-slate-600 dark:text-slate-400">
                  <TrendingUp className="h-4 w-4" />
                  <span className="text-sm">Best Round</span>
                </div>
                <Badge className="bg-green-500">Round {stats.bestRound}</Badge>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Round by Round */}
      <div className="flex-1 overflow-auto px-6">
        <h3 className="text-sm text-slate-600 dark:text-slate-400 mb-3">Round by Round</h3>
        <div className="space-y-2 pb-6">
          {[
            { round: 1, winner: 'you', guesses: 5, time: '1:23' },
            { round: 2, winner: 'opponent', guesses: 7, time: '2:15' },
            { round: 3, winner: 'you', guesses: 4, time: '1:05' },
            { round: 4, winner: 'you', guesses: 8, time: '2:34' },
            { round: 5, winner: 'opponent', guesses: 6, time: '1:28' },
          ].map((round) => (
            <Card key={round.round} className={
              round.winner === 'you' 
                ? 'border-green-200 dark:border-green-900 bg-green-50 dark:bg-green-950/30' 
                : 'border-slate-200 dark:border-slate-800 dark:bg-slate-950'
            }>
              <CardContent className="p-4">
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-3">
                    <div className={`w-10 h-10 rounded-full flex items-center justify-center ${
                      round.winner === 'you' 
                        ? 'bg-green-500 text-white' 
                        : 'bg-slate-300 dark:bg-slate-700 text-slate-600 dark:text-slate-300'
                    }`}>
                      {round.round}
                    </div>
                    <div>
                      <div className="text-sm text-slate-900 dark:text-white">Round {round.round}</div>
                      <div className="text-xs text-slate-500 dark:text-slate-400">
                        Winner: {round.winner === 'you' ? 'You' : 'Opponent'}
                      </div>
                    </div>
                  </div>
                  <div className="text-right">
                    <div className="text-sm text-slate-900 dark:text-white">{round.guesses} guesses</div>
                    <div className="text-xs text-slate-500 dark:text-slate-400">{round.time}</div>
                  </div>
                </div>
              </CardContent>
            </Card>
          ))}
        </div>
      </div>

      {/* Bottom Actions */}
      <div className="bg-white dark:bg-slate-950 border-t dark:border-slate-800 px-6 py-4 space-y-3">
        <Button
          className="w-full h-12 bg-gradient-to-r from-blue-600 to-purple-600 hover:from-blue-700 hover:to-purple-700"
          onClick={() => onNavigate('waiting-room')}
        >
          <RotateCcw className="h-4 w-4 mr-2" />
          Play Again
        </Button>
        <Button
          variant="outline"
          className="w-full dark:border-slate-700 dark:hover:bg-slate-800"
          onClick={() => onNavigate('home')}
        >
          <Home className="h-4 w-4 mr-2" />
          Back to Home
        </Button>
      </div>
    </div>
  );
}