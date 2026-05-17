import { useState } from 'react';
import { ArrowLeft, Search, Users, Lock, Trophy, Clock, RefreshCw } from 'lucide-react';
import { Button } from './ui/button';
import { Input } from './ui/input';
import { Card, CardContent } from './ui/card';
import { Badge } from './ui/badge';
import { ScrollArea } from './ui/scroll-area';

interface RoomListProps {
  onNavigate: (screen: string) => void;
}

export function RoomList({ onNavigate }: RoomListProps) {
  const [searchQuery, setSearchQuery] = useState('');

  // Mock room data
  const rooms = [
    { 
      id: 1, 
      name: 'Quick Match', 
      host: 'Player123', 
      players: 1, 
      maxPlayers: 2, 
      rounds: 3,
      isPrivate: false,
      status: 'waiting' 
    },
    { 
      id: 2, 
      name: 'Pro Players Only', 
      host: 'MasterMind', 
      players: 1, 
      maxPlayers: 2, 
      rounds: 5,
      isPrivate: false,
      status: 'waiting' 
    },
    { 
      id: 3, 
      name: 'Beginner Friendly', 
      host: 'NewbieFan', 
      players: 1, 
      maxPlayers: 2, 
      rounds: 3,
      isPrivate: false,
      status: 'waiting' 
    },
    { 
      id: 4, 
      name: 'Tournament Finals', 
      host: 'ChampionX', 
      players: 2, 
      maxPlayers: 2, 
      rounds: 7,
      isPrivate: true,
      status: 'playing' 
    },
    { 
      id: 5, 
      name: 'Casual Game', 
      host: 'RelaxedGamer', 
      players: 1, 
      maxPlayers: 2, 
      rounds: 3,
      isPrivate: false,
      status: 'waiting' 
    },
  ];

  const filteredRooms = rooms.filter(room => 
    room.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
    room.host.toLowerCase().includes(searchQuery.toLowerCase())
  );

  return (
    <div className="h-full flex flex-col bg-gradient-to-b from-slate-50 to-slate-100 dark:from-slate-900 dark:to-slate-800">
      {/* Header */}
      <div className="bg-white dark:bg-slate-950 shadow-sm border-b dark:border-slate-800">
        <div className="px-4 py-4">
          <div className="flex items-center gap-3 mb-4">
            <Button 
              variant="ghost" 
              size="icon" 
              className="h-9 w-9"
              onClick={() => onNavigate('home')}
            >
              <ArrowLeft className="h-5 w-5" />
            </Button>
            <div>
              <h1 className="text-slate-900 dark:text-white">Available Rooms</h1>
              <p className="text-xs text-slate-500 dark:text-slate-400">{filteredRooms.length} rooms found</p>
            </div>
          </div>

          {/* Search Bar */}
          <div className="relative">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-400" />
            <Input
              placeholder="Search rooms..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="pl-10 h-11 bg-slate-50 dark:bg-slate-900 dark:border-slate-700"
            />
          </div>
        </div>

        {/* Filter Tabs */}
        <div className="flex gap-2 px-4 pb-3 overflow-x-auto">
          <Button size="sm" className="rounded-full bg-blue-600 hover:bg-blue-700">
            All
          </Button>
          <Button size="sm" variant="outline" className="rounded-full dark:border-slate-700 dark:hover:bg-slate-800">
            Waiting
          </Button>
          <Button size="sm" variant="outline" className="rounded-full dark:border-slate-700 dark:hover:bg-slate-800">
            Playing
          </Button>
          <Button size="sm" variant="outline" className="rounded-full dark:border-slate-700 dark:hover:bg-slate-800">
            <RefreshCw className="h-3 w-3 mr-1" />
            Refresh
          </Button>
        </div>
      </div>

      {/* Room List */}
      <ScrollArea className="flex-1">
        <div className="p-4 space-y-3">
          {filteredRooms.length === 0 ? (
            <Card className="dark:bg-slate-950 dark:border-slate-800">
              <CardContent className="p-8 text-center text-slate-500 dark:text-slate-400">
                <Users className="h-12 w-12 mx-auto mb-3 text-slate-300 dark:text-slate-600" />
                <div className="mb-2">No rooms found</div>
                <div className="text-sm">Try adjusting your search</div>
              </CardContent>
            </Card>
          ) : (
            filteredRooms.map((room) => (
              <Card 
                key={room.id} 
                className="cursor-pointer transition-all active:scale-98 hover:shadow-md dark:bg-slate-950 dark:border-slate-800 dark:hover:bg-slate-900"
                onClick={() => room.status === 'waiting' && onNavigate('game-board')}
              >
                <CardContent className="p-4">
                  <div className="flex items-start gap-3">
                    <div className="w-12 h-12 bg-gradient-to-br from-blue-400 to-purple-600 rounded-xl flex items-center justify-center flex-shrink-0">
                      <Trophy className="h-6 w-6 text-white" />
                    </div>
                    
                    <div className="flex-1 min-w-0">
                      <div className="flex items-start justify-between gap-2 mb-2">
                        <div className="flex items-center gap-2">
                          <h3 className="text-slate-900 dark:text-white truncate">{room.name}</h3>
                          {room.isPrivate && (
                            <Lock className="h-3 w-3 text-amber-600 flex-shrink-0" />
                          )}
                        </div>
                        <Badge 
                          variant={room.status === 'waiting' ? 'default' : 'secondary'}
                          className={room.status === 'waiting' ? 'bg-green-500' : ''}
                        >
                          {room.status}
                        </Badge>
                      </div>
                      
                      <div className="text-xs text-slate-500 dark:text-slate-400 mb-3">
                        Host: {room.host}
                      </div>

                      <div className="flex items-center gap-3 text-xs text-slate-600 dark:text-slate-400">
                        <div className="flex items-center gap-1">
                          <Users className="h-3 w-3" />
                          <span>{room.players}/{room.maxPlayers}</span>
                        </div>
                        <div className="flex items-center gap-1">
                          <Trophy className="h-3 w-3" />
                          <span>{room.rounds} rounds</span>
                        </div>
                        <div className="flex items-center gap-1">
                          <Clock className="h-3 w-3" />
                          <span>60s</span>
                        </div>
                      </div>
                    </div>
                  </div>

                  {room.status === 'waiting' && (
                    <Button 
                      className="w-full mt-3 bg-blue-600 hover:bg-blue-700"
                      size="sm"
                    >
                      Join Room
                    </Button>
                  )}
                </CardContent>
              </Card>
            ))
          )}
        </div>
      </ScrollArea>

      {/* Bottom Action */}
      <div className="bg-white dark:bg-slate-950 border-t dark:border-slate-800 px-4 py-4">
        <Button
          className="w-full h-12 bg-gradient-to-r from-green-600 to-blue-600 hover:from-green-700 hover:to-blue-700"
          onClick={() => onNavigate('create-game')}
        >
          Create New Room
        </Button>
      </div>
    </div>
  );
}