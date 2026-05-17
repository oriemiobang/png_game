import { useState, useEffect } from 'react';
import { ArrowLeft, Clock, MessageCircle, Trophy, User } from 'lucide-react';
import { Button } from './ui/button';
import { Input } from './ui/input';
import { Badge } from './ui/badge';
import { Card, CardContent, CardHeader } from './ui/card';
import { Tabs, TabsContent, TabsList, TabsTrigger } from './ui/tabs';
import { ScrollArea } from './ui/scroll-area';
import { Separator } from './ui/separator';

interface GameBoardProps {
  onNavigate: (screen: string) => void;
}

export function GameBoard({ onNavigate }: GameBoardProps) {
  const [guess, setGuess] = useState('');
  const [timer, setTimer] = useState(0);

  // Mock data
  const [guessHistory] = useState([
    { attempt: 1, guess: '1234', p: 1, n: 2 },
    { attempt: 2, guess: '5678', p: 0, n: 1 },
    { attempt: 3, guess: '9012', p: 2, n: 1 },
  ]);

  // Timer effect
  useEffect(() => {
    const interval = setInterval(() => {
      setTimer((prev) => prev + 1);
    }, 1000);
    return () => clearInterval(interval);
  }, []);

  const formatTime = (seconds: number) => {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins}:${secs.toString().padStart(2, '0')}`;
  };

  const handleSubmitGuess = () => {
    if (guess.length === 4) {
      console.log('Submit guess:', guess);
      setGuess('');
    }
  };

  return (
    <div className="h-full flex flex-col bg-gradient-to-b from-slate-50 to-slate-100 dark:from-slate-900 dark:to-slate-800">
      {/* Header */}
      <div className="bg-white dark:bg-slate-950 shadow-sm border-b dark:border-slate-800 px-4 py-3">
        <div className="flex items-center justify-between mb-2">
          <Button 
            variant="ghost" 
            size="icon" 
            className="h-9 w-9"
            onClick={() => onNavigate('result')}
          >
            <ArrowLeft className="h-5 w-5" />
          </Button>
          <Badge variant="destructive" className="px-3 py-1">
            Opponent's turn
          </Badge>
          <div className="flex items-center gap-2">
            <div className="flex items-center gap-1.5 text-slate-600 dark:text-slate-300 bg-slate-100 dark:bg-slate-800 px-3 py-1.5 rounded-full">
              <Clock className="h-4 w-4" />
              <span className="text-sm tabular-nums">{formatTime(timer)}</span>
            </div>
            <Button 
              variant="ghost" 
              size="icon" 
              className="h-9 w-9 relative"
              onClick={() => onNavigate('chat')}
            >
              <MessageCircle className="h-5 w-5" />
              <span className="absolute -top-1 -right-1 h-4 w-4 bg-red-500 text-white text-xs rounded-full flex items-center justify-center">
                2
              </span>
            </Button>
          </div>
        </div>
        
        {/* Game stats */}
        <div className="flex items-center justify-around pt-2 border-t dark:border-slate-800">
          <div className="flex items-center gap-2">
            <Trophy className="h-4 w-4 text-amber-500" />
            <div>
              <div className="text-xs text-slate-500 dark:text-slate-400">Round</div>
              <div className="tabular-nums dark:text-white">3</div>
            </div>
          </div>
          <Separator orientation="vertical" className="h-8 dark:bg-slate-800" />
          <div className="flex items-center gap-2">
            <User className="h-4 w-4 text-blue-500" />
            <div>
              <div className="text-xs text-slate-500 dark:text-slate-400">Your Score</div>
              <div className="tabular-nums dark:text-white">2</div>
            </div>
          </div>
          <Separator orientation="vertical" className="h-8 dark:bg-slate-800" />
          <div className="flex items-center gap-2">
            <User className="h-4 w-4 text-red-500" />
            <div>
              <div className="text-xs text-slate-500 dark:text-slate-400">Opponent</div>
              <div className="tabular-nums dark:text-white">1</div>
            </div>
          </div>
        </div>
      </div>

      {/* Secret Code */}
      <div className="bg-white dark:bg-slate-950 px-4 py-3 border-b dark:border-slate-800">
        <div className="text-xs text-slate-500 dark:text-slate-400 mb-1">Secret Code</div>
        <div className="flex gap-2">
          {[...Array(4)].map((_, i) => (
            <div
              key={i}
              className="flex-1 h-12 bg-slate-900 dark:bg-slate-700 rounded-lg flex items-center justify-center"
            >
              <span className="text-2xl text-white">*</span>
            </div>
          ))}
        </div>
      </div>

      {/* Game Board Tabs */}
      <div className="flex-1 overflow-hidden flex flex-col">
        <Tabs defaultValue="my-board" className="flex flex-col flex-1">
          <TabsList className="grid w-full grid-cols-2 mx-4 mt-3 dark:bg-slate-800">
            <TabsTrigger value="my-board">My Board</TabsTrigger>
            <TabsTrigger value="opponent-board">Opponent's Board</TabsTrigger>
          </TabsList>
          
          <TabsContent value="my-board" className="flex-1 px-4 mt-3 overflow-hidden">
            <Card className="dark:bg-slate-950 dark:border-slate-800">
              <CardHeader className="pb-3">
                <div className="text-sm text-slate-600 dark:text-slate-300">Guess History</div>
              </CardHeader>
              <CardContent className="p-0">
                <ScrollArea className="h-[200px]">
                  <table className="w-full">
                    <thead className="bg-slate-50 dark:bg-slate-900 sticky top-0">
                      <tr className="border-b dark:border-slate-800">
                        <th className="text-left py-2 px-4 text-xs text-slate-600 dark:text-slate-400">#</th>
                        <th className="text-left py-2 px-4 text-xs text-slate-600 dark:text-slate-400">Guess</th>
                        <th className="text-center py-2 px-3 text-xs text-slate-600 dark:text-slate-400">P</th>
                        <th className="text-center py-2 px-3 text-xs text-slate-600 dark:text-slate-400">N</th>
                      </tr>
                    </thead>
                    <tbody>
                      {guessHistory.map((item) => (
                        <tr key={item.attempt} className="border-b last:border-0 dark:border-slate-800">
                          <td className="py-3 px-4 text-slate-500 dark:text-slate-400">{item.attempt}</td>
                          <td className="py-3 px-4 tabular-nums dark:text-white">{item.guess}</td>
                          <td className="py-3 px-3 text-center">
                            <Badge variant="default" className="bg-green-500">
                              {item.p}
                            </Badge>
                          </td>
                          <td className="py-3 px-3 text-center">
                            <Badge variant="default" className="bg-amber-500">
                              {item.n}
                            </Badge>
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </ScrollArea>
              </CardContent>
            </Card>
          </TabsContent>

          <TabsContent value="opponent-board" className="flex-1 px-4 mt-3">
            <Card className="dark:bg-slate-950 dark:border-slate-800">
              <CardContent className="p-8 text-center text-slate-500 dark:text-slate-400">
                Waiting for opponent's moves...
              </CardContent>
            </Card>
          </TabsContent>
        </Tabs>
      </div>

      {/* Bottom Action Section */}
      <div className="bg-white dark:bg-slate-950 border-t dark:border-slate-800 px-4 py-4 space-y-3">
        {/* Guess Input */}
        <div className="space-y-2">
          <div className="text-xs text-slate-600 dark:text-slate-400 px-1">Make Your Guess</div>
          <div className="flex gap-2">
            <Input
              placeholder="Enter 4 digits..."
              value={guess}
              onChange={(e) => {
                const val = e.target.value.replace(/\D/g, '').slice(0, 4);
                setGuess(val);
              }}
              maxLength={4}
              className="flex-1 h-12 text-center text-lg tabular-nums bg-slate-50 dark:bg-slate-900 border-2 border-slate-300 dark:border-slate-700 focus-visible:border-blue-500"
            />
            <Button
              size="lg"
              onClick={handleSubmitGuess}
              disabled={guess.length !== 4}
              className="px-8 bg-green-600 hover:bg-green-700"
            >
              Submit
            </Button>
          </div>
        </div>

        {/* New Game Button */}
        <Button
          variant="outline"
          className="w-full border-2 dark:border-slate-700 dark:hover:bg-slate-800"
          onClick={() => onNavigate('home')}
        >
          Leave Game
        </Button>
      </div>
    </div>
  );
}