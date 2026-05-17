import { useState } from 'react';
import { HomePage } from './components/HomePage';
import { CreateGame } from './components/CreateGame';
import { WaitingRoom } from './components/WaitingRoom';
import { RoomList } from './components/RoomList';
import { GameBoard } from './components/GameBoard';
import { GameResult } from './components/GameResult';
import { ChatRoom } from './components/ChatRoom';
import { ThemeProvider } from './contexts/ThemeContext';
import { Toaster } from './components/ui/sonner';

type Screen = 'home' | 'create-game' | 'waiting-room' | 'room-list' | 'game-board' | 'result' | 'chat';

export default function App() {
  const [currentScreen, setCurrentScreen] = useState<Screen>('home');

  const navigate = (screen: string) => {
    setCurrentScreen(screen as Screen);
  };

  const renderScreen = () => {
    switch (currentScreen) {
      case 'home':
        return <HomePage onNavigate={navigate} />;
      case 'create-game':
        return <CreateGame onNavigate={navigate} />;
      case 'waiting-room':
        return <WaitingRoom onNavigate={navigate} />;
      case 'room-list':
        return <RoomList onNavigate={navigate} />;
      case 'game-board':
        return <GameBoard onNavigate={navigate} />;
      case 'result':
        return <GameResult onNavigate={navigate} />;
      case 'chat':
        return <ChatRoom onNavigate={navigate} />;
      default:
        return <HomePage onNavigate={navigate} />;
    }
  };

  return (
    <ThemeProvider>
      <div className="min-h-screen w-full bg-white dark:bg-black flex items-center justify-center">
        {/* Mobile Container */}
        <div className="h-screen w-full max-w-md bg-white dark:bg-slate-950 shadow-2xl overflow-hidden">
          {renderScreen()}
        </div>
        <Toaster />
      </div>
    </ThemeProvider>
  );
}