import { useState, useEffect } from 'react';
import { ArrowLeft, Copy, Check, Users, Crown, User } from 'lucide-react';
import { Button } from './ui/button';
import { Card, CardContent } from './ui/card';
import { Badge } from './ui/badge';
import { toast } from 'sonner@2.0.3';

interface WaitingRoomProps {
  onNavigate: (screen: string) => void;
}

export function WaitingRoom({ onNavigate }: WaitingRoomProps) {
  const [copied, setCopied] = useState(false);
  const [dots, setDots] = useState('');
  const roomCode = 'ABCD1234';

  // Animated dots for waiting state
  useEffect(() => {
    const interval = setInterval(() => {
      setDots((prev) => (prev.length >= 3 ? '' : prev + '.'));
    }, 500);
    return () => clearInterval(interval);
  }, []);

  const copyRoomCode = () => {
    navigator.clipboard.writeText(roomCode);
    setCopied(true);
    toast.success('Room code copied!');
    setTimeout(() => setCopied(false), 2000);
  };

  return (
    <div className="h-full flex flex-col bg-gradient-to-b from-slate-50 to-slate-100 dark:from-slate-900 dark:to-slate-800">
      {/* Header */}
      <div className="bg-white dark:bg-slate-950 shadow-sm border-b dark:border-slate-800 px-4 py-4">
        <div className="flex items-center gap-3">
          <Button 
            variant="ghost" 
            size="icon" 
            className="h-9 w-9"
            onClick={() => onNavigate('home')}
          >
            <ArrowLeft className="h-5 w-5" />
          </Button>
          <div>
            <h1 className="text-slate-900 dark:text-white">Waiting Room</h1>
            <p className="text-xs text-slate-500 dark:text-slate-400">My Game Room</p>
          </div>
        </div>
      </div>

      {/* Content */}
      <div className="flex-1 overflow-auto p-6 space-y-6">
        {/* Room Code Card */}
        <Card className="bg-gradient-to-br from-blue-500 to-purple-600 border-0 shadow-xl">
          <CardContent className="p-6 text-center">
            <div className="text-white/80 text-sm mb-2">Room Code</div>
            <div className="text-white text-4xl tracking-wider mb-4">
              {roomCode}
            </div>
            <Button
              onClick={copyRoomCode}
              className="bg-white text-blue-600 hover:bg-white/90"
            >
              {copied ? (
                <>
                  <Check className="h-4 w-4 mr-2" />
                  Copied!
                </>
              ) : (
                <>
                  <Copy className="h-4 w-4 mr-2" />
                  Copy Code
                </>
              )}
            </Button>
          </CardContent>
        </Card>

        {/* Waiting Animation */}
        <Card className="border-2 border-dashed border-slate-300 dark:border-slate-700 dark:bg-slate-950">
          <CardContent className="p-8 text-center">
            <div className="w-16 h-16 mx-auto mb-4 bg-slate-100 dark:bg-slate-800 rounded-full flex items-center justify-center">
              <Users className="h-8 w-8 text-slate-400 animate-pulse" />
            </div>
            <div className="text-slate-900 dark:text-white mb-2">
              Waiting for opponent{dots}
            </div>
            <div className="text-sm text-slate-500 dark:text-slate-400">
              Share the room code with your friend
            </div>
          </CardContent>
        </Card>

        {/* Players List */}
        <Card className="dark:bg-slate-950 dark:border-slate-800">
          <CardContent className="p-5">
            <div className="flex items-center gap-2 mb-4">
              <Users className="h-4 w-4 text-slate-600 dark:text-slate-400" />
              <h3 className="text-sm text-slate-700 dark:text-slate-300">Players (1/2)</h3>
            </div>
            
            {/* Host Player */}
            <div className="flex items-center gap-3 p-3 bg-slate-50 dark:bg-slate-900 rounded-lg">
              <div className="w-10 h-10 bg-gradient-to-br from-blue-500 to-purple-600 rounded-full flex items-center justify-center">
                <User className="h-5 w-5 text-white" />
              </div>
              <div className="flex-1">
                <div className="text-sm text-slate-900 dark:text-white">You</div>
                <div className="text-xs text-slate-500 dark:text-slate-400">Ready</div>
              </div>
              <Badge className="bg-amber-500">
                <Crown className="h-3 w-3 mr-1" />
                Host
              </Badge>
            </div>

            {/* Empty Slot */}
            <div className="flex items-center gap-3 p-3 border-2 border-dashed border-slate-200 dark:border-slate-700 rounded-lg mt-3 dark:bg-slate-950">
              <div className="w-10 h-10 bg-slate-100 dark:bg-slate-800 rounded-full flex items-center justify-center">
                <User className="h-5 w-5 text-slate-400" />
              </div>
              <div className="flex-1">
                <div className="text-sm text-slate-400">Waiting...</div>
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Game Settings Info */}
        <Card className="dark:bg-slate-950 dark:border-slate-800">
          <CardContent className="p-5">
            <h3 className="text-sm text-slate-700 dark:text-slate-300 mb-3">Game Settings</h3>
            <div className="space-y-2 text-sm">
              <div className="flex justify-between">
                <span className="text-slate-500 dark:text-slate-400">Max Rounds</span>
                <span className="text-slate-900 dark:text-white">3</span>
              </div>
              <div className="flex justify-between">
                <span className="text-slate-500 dark:text-slate-400">Time per Turn</span>
                <span className="text-slate-900 dark:text-white">60 seconds</span>
              </div>
              <div className="flex justify-between">
                <span className="text-slate-500 dark:text-slate-400">Room Type</span>
                <span className="text-slate-900 dark:text-white">Private</span>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Bottom Actions */}
      <div className="bg-white dark:bg-slate-950 border-t dark:border-slate-800 px-6 py-4 space-y-3">
        <Button
          className="w-full h-12 bg-green-600 hover:bg-green-700"
          onClick={() => onNavigate('game-board')}
        >
          Start Game (for demo)
        </Button>
        <Button
          variant="outline"
          className="w-full dark:border-slate-700 dark:hover:bg-slate-800"
          onClick={() => onNavigate('home')}
        >
          Cancel
        </Button>
      </div>
    </div>
  );
}