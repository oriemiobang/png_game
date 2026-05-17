import { Play, Users, Trophy, Moon, Sun } from 'lucide-react';
import { Button } from './ui/button';
import { Card, CardContent } from './ui/card';
import { AppIcon } from './AppIcon';
import { useTheme } from '../contexts/ThemeContext';

interface HomePageProps {
  onNavigate: (screen: string) => void;
}

export function HomePage({ onNavigate }: HomePageProps) {
  const { theme, toggleTheme } = useTheme();

  return (
    <div className="h-full flex flex-col bg-gradient-to-br from-blue-600 via-purple-600 to-pink-600 dark:from-slate-900 dark:via-purple-900 dark:to-slate-900 p-6">
      {/* Header */}
      <div className="text-center pt-8 pb-12 relative">
        {/* Theme Toggle Button */}
        <Button
          variant="ghost"
          size="icon"
          onClick={toggleTheme}
          className="absolute top-0 right-0 text-white hover:bg-white/20 h-10 w-10"
        >
          {theme === 'light' ? (
            <Moon className="h-5 w-5" />
          ) : (
            <Sun className="h-5 w-5" />
          )}
        </Button>

        <div className="inline-flex items-center justify-center mb-4">
          <AppIcon size={100} />
        </div>
        <h1 className="text-white text-4xl mb-2">PNG Game</h1>
        <p className="text-white/90 text-sm">Position Number Guessing</p>
      </div>

      {/* Main Menu Cards */}
      <div className="flex-1 space-y-4">
        <Card 
          className="bg-white/95 dark:bg-slate-800/95 backdrop-blur border-0 shadow-xl cursor-pointer transition-transform active:scale-95"
          onClick={() => onNavigate('create-game')}
        >
          <CardContent className="p-6">
            <div className="flex items-center gap-4">
              <div className="w-14 h-14 bg-gradient-to-br from-green-400 to-green-600 rounded-2xl flex items-center justify-center shadow-lg">
                <Play className="w-7 h-7 text-white" />
              </div>
              <div className="flex-1">
                <h3 className="text-slate-900 dark:text-white mb-1">Create Game</h3>
                <p className="text-sm text-slate-500 dark:text-slate-400">Start a new game room</p>
              </div>
            </div>
          </CardContent>
        </Card>

        <Card 
          className="bg-white/95 dark:bg-slate-800/95 backdrop-blur border-0 shadow-xl cursor-pointer transition-transform active:scale-95"
          onClick={() => onNavigate('room-list')}
        >
          <CardContent className="p-6">
            <div className="flex items-center gap-4">
              <div className="w-14 h-14 bg-gradient-to-br from-blue-400 to-blue-600 rounded-2xl flex items-center justify-center shadow-lg">
                <Users className="w-7 h-7 text-white" />
              </div>
              <div className="flex-1">
                <h3 className="text-slate-900 dark:text-white mb-1">Join Game</h3>
                <p className="text-sm text-slate-500 dark:text-slate-400">Browse available rooms</p>
              </div>
            </div>
          </CardContent>
        </Card>

        <Card 
          className="bg-white/95 dark:bg-slate-800/95 backdrop-blur border-0 shadow-xl cursor-pointer transition-transform active:scale-95"
          onClick={() => onNavigate('game-board')}
        >
          <CardContent className="p-6">
            <div className="flex items-center gap-4">
              <div className="w-14 h-14 bg-gradient-to-br from-purple-400 to-purple-600 rounded-2xl flex items-center justify-center shadow-lg">
                <Trophy className="w-7 h-7 text-white" />
              </div>
              <div className="flex-1">
                <h3 className="text-slate-900 dark:text-white mb-1">Play Solo</h3>
                <p className="text-sm text-slate-500 dark:text-slate-400">Practice against AI</p>
              </div>
            </div>
          </CardContent>
        </Card>

        <Card 
          className="bg-white/95 dark:bg-slate-800/95 backdrop-blur border-0 shadow-xl cursor-pointer transition-transform active:scale-95"
          onClick={() => onNavigate('game-board')}
        >
          <CardContent className="p-6">
            <div className="flex items-center gap-4">
              <div className="w-14 h-14 bg-gradient-to-br from-pink-400 to-pink-600 rounded-2xl flex items-center justify-center shadow-lg">
                <Users className="w-7 h-7 text-white" />
              </div>
              <div className="flex-1">
                <h3 className="text-slate-900 dark:text-white mb-1">Play with Friend</h3>
                <p className="text-sm text-slate-500 dark:text-slate-400">Invite a friend to play</p>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Stats Footer */}
      <div className="mt-6 bg-white/20 dark:bg-white/10 backdrop-blur rounded-2xl p-4 border border-white/30">
        <div className="flex justify-around text-white">
          <div className="text-center">
            <div className="text-2xl mb-1">12</div>
            <div className="text-xs opacity-90">Games Played</div>
          </div>
          <div className="w-px bg-white/30"></div>
          <div className="text-center">
            <div className="text-2xl mb-1">8</div>
            <div className="text-xs opacity-90">Wins</div>
          </div>
          <div className="w-px bg-white/30"></div>
          <div className="text-center">
            <div className="text-2xl mb-1">67%</div>
            <div className="text-xs opacity-90">Win Rate</div>
          </div>
        </div>
      </div>
    </div>
  );
}