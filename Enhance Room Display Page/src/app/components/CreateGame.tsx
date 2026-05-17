import { useState } from 'react';
import { ArrowLeft, Lock, Unlock, Users, Clock } from 'lucide-react';
import { Button } from './ui/button';
import { Input } from './ui/input';
import { Label } from './ui/label';
import { Card, CardContent } from './ui/card';
import { Switch } from './ui/switch';

interface CreateGameProps {
  onNavigate: (screen: string) => void;
}

export function CreateGame({ onNavigate }: CreateGameProps) {
  const [isPrivate, setIsPrivate] = useState(false);
  const [roomName, setRoomName] = useState('');
  const [maxRounds, setMaxRounds] = useState('3');

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
            <h1 className="text-slate-900 dark:text-white">Create New Game</h1>
            <p className="text-xs text-slate-500 dark:text-slate-400">Set up your game room</p>
          </div>
        </div>
      </div>

      {/* Form Content */}
      <div className="flex-1 overflow-auto p-6 space-y-6">
        {/* Room Name */}
        <Card className="dark:bg-slate-950 dark:border-slate-800">
          <CardContent className="p-5 space-y-3">
            <Label htmlFor="room-name" className="text-slate-700 dark:text-slate-300">Room Name</Label>
            <Input
              id="room-name"
              placeholder="Enter room name..."
              value={roomName}
              onChange={(e) => setRoomName(e.target.value)}
              className="h-12 dark:bg-slate-900 dark:border-slate-700"
            />
          </CardContent>
        </Card>

        {/* Game Settings */}
        <Card className="dark:bg-slate-950 dark:border-slate-800">
          <CardContent className="p-5 space-y-4">
            <h3 className="text-slate-700 dark:text-slate-300 mb-3">Game Settings</h3>
            
            {/* Max Rounds */}
            <div className="space-y-2">
              <Label htmlFor="max-rounds" className="text-slate-600 dark:text-slate-400">Maximum Rounds</Label>
              <div className="flex gap-2">
                {['3', '5', '7', '10'].map((num) => (
                  <button
                    key={num}
                    onClick={() => setMaxRounds(num)}
                    className={`flex-1 h-12 rounded-lg border-2 transition-all ${
                      maxRounds === num
                        ? 'border-blue-500 bg-blue-50 dark:bg-blue-950 text-blue-700 dark:text-blue-400'
                        : 'border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-900 text-slate-600 dark:text-slate-300'
                    }`}
                  >
                    {num}
                  </button>
                ))}
              </div>
            </div>

            {/* Time per Turn */}
            <div className="flex items-center justify-between py-3 border-t dark:border-slate-800">
              <div className="flex items-center gap-3">
                <Clock className="h-5 w-5 text-slate-500 dark:text-slate-400" />
                <div>
                  <div className="text-sm text-slate-700 dark:text-slate-300">Time Limit</div>
                  <div className="text-xs text-slate-500 dark:text-slate-400">60 seconds per turn</div>
                </div>
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Privacy Settings */}
        <Card className="dark:bg-slate-950 dark:border-slate-800">
          <CardContent className="p-5">
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-3">
                {isPrivate ? (
                  <Lock className="h-5 w-5 text-amber-600" />
                ) : (
                  <Unlock className="h-5 w-5 text-green-600" />
                )}
                <div>
                  <div className="text-sm text-slate-700 dark:text-slate-300">Private Room</div>
                  <div className="text-xs text-slate-500 dark:text-slate-400">
                    {isPrivate ? 'Only invited players can join' : 'Anyone can join'}
                  </div>
                </div>
              </div>
              <Switch
                checked={isPrivate}
                onCheckedChange={setIsPrivate}
              />
            </div>
          </CardContent>
        </Card>

        {/* Preview */}
        <Card className="bg-gradient-to-br from-blue-50 to-purple-50 dark:from-blue-950/50 dark:to-purple-950/50 border-blue-200 dark:border-blue-900">
          <CardContent className="p-5">
            <div className="flex items-center gap-3 mb-3">
              <div className="w-10 h-10 bg-white dark:bg-slate-800 rounded-xl flex items-center justify-center">
                <Users className="h-5 w-5 text-blue-600 dark:text-blue-400" />
              </div>
              <div className="flex-1">
                <div className="text-sm text-slate-900 dark:text-white">
                  {roomName || 'My Game Room'}
                </div>
                <div className="text-xs text-slate-600 dark:text-slate-400">
                  Best of {maxRounds} rounds
                </div>
              </div>
              {isPrivate && (
                <Lock className="h-4 w-4 text-amber-600 dark:text-amber-500" />
              )}
            </div>
            <div className="flex gap-2 text-xs">
              <span className="px-2 py-1 bg-white dark:bg-slate-800 rounded-full text-slate-600 dark:text-slate-300">
                {maxRounds} rounds
              </span>
              <span className="px-2 py-1 bg-white dark:bg-slate-800 rounded-full text-slate-600 dark:text-slate-300">
                60s/turn
              </span>
              <span className="px-2 py-1 bg-white dark:bg-slate-800 rounded-full text-slate-600 dark:text-slate-300">
                {isPrivate ? 'Private' : 'Public'}
              </span>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Bottom Actions */}
      <div className="bg-white dark:bg-slate-950 border-t dark:border-slate-800 px-6 py-4 space-y-3">
        <Button
          className="w-full h-12 bg-gradient-to-r from-blue-600 to-purple-600 hover:from-blue-700 hover:to-purple-700"
          onClick={() => onNavigate('waiting-room')}
        >
          Create Room
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