import { useState } from 'react';
import { ArrowLeft, Send } from 'lucide-react';
import { Button } from './ui/button';
import { Input } from './ui/input';
import { ScrollArea } from './ui/scroll-area';

interface ChatRoomProps {
  onNavigate: (screen: string) => void;
}

export function ChatRoom({ onNavigate }: ChatRoomProps) {
  const [message, setMessage] = useState('');

  // Mock data
  const [chatMessages] = useState([
    { id: 1, text: 'hey man hurry up', sender: 'opponent', time: '11:18' },
    { id: 2, text: 'Give me a sec!', sender: 'me', time: '11:19' },
    { id: 3, text: 'This game is intense!', sender: 'opponent', time: '11:20' },
    { id: 4, text: 'I know right? Good luck!', sender: 'me', time: '11:21' },
  ]);

  const handleSendMessage = () => {
    if (message.trim()) {
      console.log('Send message:', message);
      setMessage('');
    }
  };

  return (
    <div className="h-full flex flex-col bg-gradient-to-b from-purple-50 to-pink-50 dark:from-slate-900 dark:to-slate-800">
      {/* Header */}
      <div className="bg-white dark:bg-slate-950 shadow-sm border-b dark:border-slate-800 px-4 py-4">
        <div className="flex items-center gap-3">
          <Button 
            variant="ghost" 
            size="icon" 
            className="h-9 w-9"
            onClick={() => onNavigate('game-board')}
          >
            <ArrowLeft className="h-5 w-5" />
          </Button>
          <div>
            <h2 className="font-semibold dark:text-white">Chat Room</h2>
            <p className="text-xs text-slate-500 dark:text-slate-400">Talk with your opponent</p>
          </div>
        </div>
      </div>

      {/* Chat Messages */}
      <ScrollArea className="flex-1 px-4 py-4">
        <div className="space-y-3">
          {chatMessages.map((msg) => (
            <div
              key={msg.id}
              className={`flex ${msg.sender === 'me' ? 'justify-end' : 'justify-start'}`}
            >
              <div
                className={`max-w-[75%] rounded-2xl px-4 py-2 shadow-sm ${
                  msg.sender === 'me'
                    ? 'bg-gradient-to-r from-purple-500 to-pink-500 text-white'
                    : 'bg-white dark:bg-slate-800 text-slate-900 dark:text-white border border-slate-200 dark:border-slate-700'
                }`}
              >
                <div className="text-sm">{msg.text}</div>
                <div
                  className={`text-xs mt-1 ${
                    msg.sender === 'me' ? 'text-purple-100' : 'text-slate-500 dark:text-slate-400'
                  }`}
                >
                  {msg.time}
                </div>
              </div>
            </div>
          ))}
        </div>
      </ScrollArea>

      {/* Chat Input */}
      <div className="bg-white dark:bg-slate-950 border-t dark:border-slate-800 px-4 py-4">
        <div className="flex gap-2">
          <Input
            placeholder="Type your message..."
            value={message}
            onChange={(e) => setMessage(e.target.value)}
            onKeyDown={(e) => e.key === 'Enter' && handleSendMessage()}
            className="flex-1 bg-slate-50 dark:bg-slate-900 border-2 border-slate-200 dark:border-slate-700 focus-visible:border-purple-500"
          />
          <Button
            size="icon"
            onClick={handleSendMessage}
            disabled={!message.trim()}
            className="bg-gradient-to-r from-purple-500 to-pink-500 hover:from-purple-600 hover:to-pink-600 h-10 w-10"
          >
            <Send className="h-4 w-4" />
          </Button>
        </div>
      </div>
    </div>
  );
}