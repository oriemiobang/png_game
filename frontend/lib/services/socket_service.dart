import 'package:flutter/material.dart';
import 'package:png_game/classes/data.dart';
import 'package:png_game/storage/saved_data.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'dart:math';

class SocketService with ChangeNotifier {
  late io.Socket socket;
  bool isConnected = false;
  bool gameJoined = false;
  dynamic gameInfo = {};
  SavedData savedData = SavedData();
  
  // Add reconnection properties
  bool _isManuallyDisconnected = false;
  int _reconnectAttempts = 0;
  final int _maxReconnectAttempts = 5;
  
  String game_id = '';
  String player_id = '';

  SocketService() {
    connect();
    savedData = SavedData();
  }

  void connect() {
    socket = io.io('https://png-game.onrender.com', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
      'reconnection': true,
      'reconnectionAttempts': _maxReconnectAttempts,
      'reconnectionDelay': 1000,
      'reconnectionDelayMax': 5000,
      'timeout': 20000,
    });

    socket.connect();

    // Listen to connects
    socket.onConnect((_) {
      isConnected = true;
      _reconnectAttempts = 0;
      print('Connected to server');
      
      // Rejoin game if we were in one
      if (gameJoined && game_id.isNotEmpty && player_id.isNotEmpty) {
        _rejoinGame();
      }
      
      notifyListeners();
    });

    // Listen to reconnection events (using available methods)
    socket.onReconnect((_) {
      print('Reconnected to server');
      isConnected = true;
      _reconnectAttempts = 0;
      
      // Rejoin game after reconnection
      if (gameJoined && game_id.isNotEmpty && player_id.isNotEmpty) {
        _rejoinGame();
      }
      
      notifyListeners();
    });

    // Listen to reconnection errors
    socket.onReconnectError((data) {
      print('Reconnection Error: $data');
      _reconnectAttempts++;
      isConnected = false;
      notifyListeners();
    });

    socket.onReconnectFailed((_) {
      print('Reconnection Failed after $_reconnectAttempts attempts');
      isConnected = false;
      notifyListeners();
    });

    // Listen to connecting event (this is available and similar to onReconnecting)
    socket.on('connecting', (_) {
      print('Connecting to server...');
      isConnected = false;
      notifyListeners();
    });

    // Listen to disconnects
    socket.onDisconnect((_) {
      isConnected = false;
      print('Disconnected from server');
      notifyListeners();
    });

    // Listen to game joiner
    socket.on('gameJoined', (data) async {
      gameJoined = true;
      game_id = data['gameId'];
      player_id = data['playerId'];
      
      // Save game state for reconnection
      await _saveGameState();
      
      print('Game joined: $data');
      notifyListeners();
    });

    // Listen to game rejoined event (from backend)
    socket.on('gameRejoined', (data) {
      print('Successfully rejoined game: ${data['gameId']}');
      gameInfo = data['gameState'];
      Data().updateData(data['gameState']);
      notifyListeners();
    });

    // Listen to rejoin failed event
    socket.on('rejoinFailed', (data) {
      print('Failed to rejoin game: ${data['message']}');
      gameJoined = false;
      game_id = '';
      player_id = '';
      notifyListeners();
    });

    // Listen to player reconnected event
    socket.on('playerReconnected', (data) {
      print('Player ${data['playerId']} reconnected to the game');
      // You can show a snackbar or notification here
    });

    // Listen to last chance
    socket.on('lastChance', (data) {
      Data().updateLastChance(data);
      notifyListeners();
    });

    socket.off('sendMessage');
    socket.on('sendMessage', (data) {
      Data().updateChatData(data);
    });
    
    socket.on('gameEnd', (data) {
      if (data != null) {
        Data().updateWinner(data);
        print('Game end data: $data');
        notifyListeners();
      }
    });

    // Listen to random game info
    socket.on('randomGameInfo', (data) {
      Data().updateRandomGames(data);
      notifyListeners();
    });
    
    // Listen for turn error
    socket.on('turnWait', (data) {
      Data().updateNotYourTurn(data);
      notifyListeners();
    });
    
    socket.onConnectError((data) {
      print('Connection Error: $data');
      isConnected = false;
      notifyListeners();
    });

    socket.onError((data) {
      print('Socket Error: $data');
    });

    // Listen to random room game
    socket.on('randomRoomGame', (data) {
      Data().updateRandomRoomGame(data);
      notifyListeners();
    });

    socket.on('requestNewGame', (data) {
      Data().updateNewGame(data);
      notifyListeners();
      print('Request data $data');
    });

    // Game data
    socket.on('gameInfo', (data) {
      gameInfo = data;
      Data().updateData(data);
      print('Data in the game info: $data');
      notifyListeners();
    });
  }

  // Rejoin game after reconnection
  void _rejoinGame() async {
    print('Rejoining game: $game_id as player: $player_id');
    
    // Add a small delay to ensure socket is ready
    await Future.delayed(Duration(milliseconds: 500));
    
    socket.emit('rejoinGame', {
      'gameId': game_id,
      'playerId': player_id
    });
  }

  // Save game state for reconnection
  Future<void> _saveGameState() async {
    // You can save this to shared preferences for persistence
    // For now, we'll just keep it in memory
    print('Game state saved for reconnection - Game: $game_id, Player: $player_id');
  }

  // Manual disconnect (call this when app goes to background)
  void disconnect() {
    _isManuallyDisconnected = true;
    socket.disconnect();
    isConnected = false;
    print('Manually disconnected socket');
    notifyListeners();
  }

  // Manual reconnect (call this when app comes to foreground)
  void reconnect() {
    _isManuallyDisconnected = false;
    if (!isConnected) {
      print('Manually reconnecting socket...');
      socket.connect();
    }
  }

  void sendGuess(String guess) async {
    if (!isConnected) {
      print('Not connected, cannot send guess');
      return;
    }
    
    final gameId = Data().gameId;
    final userId = Data().userId;
    
    print('Sending guess: $guess for game: $gameId, user: $userId');
    
    socket.emit(
      'makeGuess', 
      {'gameId': gameId, 'playerId': userId, 'guess': guess}
    );
  }

  void chat({
    required String gameId,
    required String playerId,
    required String message
  }) {
    if (!isConnected) {
      print('Not connected, cannot send message');
      return;
    }
    
    socket.emit(
      'chat', 
      {'gameId': gameId, 'playerId': playerId, 'message': message}
    );
  }

  void submitSecret(String secret) async {
    if (!isConnected) {
      print('Not connected, cannot submit secret');
      return;
    }
    
    final gameId = Data().gameId;
    final userId = Data().userId;
    
    print('Submitting secret for game: $gameId, user: $userId');
    
    socket.emit('submitSecret',
      {'gameId': gameId, 'playerId': userId, 'secretNumber': secret}
    );
  }

  String createGame() {
    final random = Random();
    const hexChars = '0123456789abcdef';

    String playerId = 'PNG${List.generate(9, (_) => random.nextInt(10)).join()}';
    String gameId = 'PNG${List.generate(15, (_) => hexChars[random.nextInt(16)]).join()}';
    player_id = playerId;
    game_id = gameId;

    Data().updateGameId(gameId);
    Data().updateUserId(playerId);

    socket.emit('createGame', {'playerId': playerId, 'gameId': gameId});
    notifyListeners();

    return gameId;
  }

  String createRandomGame() {
    final random = Random();
    const hexChars = '0123456789abcdef';

    String playerId = 'PNG${List.generate(9, (_) => random.nextInt(10)).join()}';
    String gameId = 'PNG${List.generate(15, (_) => hexChars[random.nextInt(16)]).join()}';
    player_id = playerId;
    game_id = gameId;

    Data().updateGameId(gameId);
    Data().updateUserId(playerId);

    socket.emit('createRandomGames', {'playerId': playerId, 'gameId': gameId});
    notifyListeners();

    return gameId;
  }

  void joinGame(String gameCode) async {
    final random = Random();

    String playerId = 'PNG${List.generate(9, (_) => random.nextInt(10)).join()}';
    player_id = playerId;
    game_id = gameCode;

    Data().updateGameId(gameCode);
    Data().updateUserId(playerId);

    socket.emit('joinGame', {'gameId': gameCode, 'playerId': playerId});
    notifyListeners();
  }

  void joinRandomGames(gameCode) {
    final random = Random();

    String playerId = 'PNG${List.generate(9, (_) => random.nextInt(10)).join()}';
    player_id = playerId;
    game_id = gameCode;

    Data().updateGameId(gameCode);
    Data().updateUserId(playerId);

    socket.emit('joinRandomGame', {'gameId': gameCode, 'playerId': playerId});
    notifyListeners();
  }

  void requestNewGame(playerId, gameId, approved) {
    if (!isConnected) {
      print('Not connected, cannot request new game');
      return;
    }
    
    socket.emit('newGame',
      {'playerId': playerId, 'gameId': gameId, 'approved': approved}
    );
  }

  // Getter for connection status
  bool get connectionStatus => isConnected;
  
  // Getter for game joined status
  bool get isGameJoined => gameJoined;
}