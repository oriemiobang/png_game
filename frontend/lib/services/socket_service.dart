import 'package:flutter/material.dart';
import 'package:png_game/classes/data.dart';
import 'package:png_game/core/env.dart';
import 'package:png_game/storage/saved_data.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'dart:math';

class SocketService with ChangeNotifier {
  late io.Socket socket;
  bool isConnected = false;
  bool gameJoined = false;
  String? lastError;
  dynamic gameInfo = {};
  SavedData savedData = SavedData();

  //   Map? _data;
  // String? _userId; // New private variable
  // String? _gameId;
  // Map? _winner;

  String gameId = '';
  String playerId = '';

  String? _currentPlayerId() => Data().userId;

  void resetJoinState() {
    gameJoined = false;
    lastError = null;
    notifyListeners();
  }

  SocketService() {
    connect();
    savedData = SavedData();
  }

  void connect() {
    socket = io.io(AppEnv.backendBaseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false
    });

    socket.connect();

// listen to conects
    socket.onConnect((_) {
      isConnected = true;
      lastError = null;
      debugPrint('connected to server');
      notifyListeners();
    });

    // list to disconects
    socket.onDisconnect((_) {
      isConnected = false;
      debugPrint('disconnected from server');
      notifyListeners();
    });

    socket.on('publicRooms', (data) {
      Data().updatePublicRooms(data as List);
      notifyListeners();
    });

    // listen to game joiner
    socket.on('gameJoined', (data) async {
      gameJoined = true;

      gameId = data['gameId'];
      playerId = data['playerId'];

      debugPrint('$data');
      notifyListeners();
    });

    // list to last chance
    socket.on('lastChance', (data) {
      Data().updateLastChance(data);
      notifyListeners();
    });

    socket.off('sendMessage');
    socket.on('sendMessage', (data) {
      final messageData = Map<String, dynamic>.from(data as Map);
      Data().updateChatData(messageData);

      final currentUserId = Data().userId;
      final senderId = messageData['currentSender']?.toString();
      if (currentUserId != null && senderId != null && senderId != currentUserId) {
        Data().incrementUnreadMessages();
      }
    });
    socket.on('gameEnd', (data) {
      if (data != null) {
        Data().updateWinner(data);
        debugPrint('game end data: $data');
        notifyListeners();
      }
    });

    // listen to random game info
    socket.on('randomGameInfo', (data) {
      Data().updateRandomGames(data);
      notifyListeners();
    });
    // listen for trun error
    socket.on('turnWait', (data) {
      Data().updateNotYourTurn(data);
      notifyListeners();
    });
    socket.onConnectError((data) {
      lastError = '$data';
      debugPrint('Connection Error: $data');
      notifyListeners();
    });

    socket.onError((data) {
      lastError = '$data';
      debugPrint('Socket Error: $data');
      notifyListeners();
    });

    socket.on('room_error', (data) {
      lastError = '$data';
      debugPrint('Room Error: $data');
      notifyListeners();
    });

    // ── Matchmaking listeners ──
    socket.on('searchingForMatch', (data) {
      Data().setSearchingForMatch(true);
      notifyListeners();
    });

    socket.on('matchFound', (data) async {
      final matchData = Map<String, dynamic>.from(data as Map);
      final mGameId = matchData['gameId']?.toString() ?? '';
      final mPlayerId = Data().userId ?? '';

      gameId = mGameId;
      playerId = mPlayerId;
      Data().updateGameId(mGameId);
      Data().setMatchFound(matchData);

      // Mark as joined so screens listening to gameJoined also navigate.
      gameJoined = true;
      notifyListeners();
    });

    socket.on('matchmakingTimeout', (_) {
      Data().setMatchmakingTimedOut();
      notifyListeners();
    });

    socket.on('matchmakingCancelled', (_) {
      Data().resetMatchmakingState();
      notifyListeners();
    });

    // ── Private room listeners ──
    socket.on('playerJoined', (data) {
      final joined = Map<String, dynamic>.from(data as Map);
      Data().updateOpponentJoined(joined);
      notifyListeners();
    });

    socket.on('gameCancelled', (_) {
      Data().resetMatchState();
      notifyListeners();
    });

    // list to random room game
    socket.on('randomRoomGame', (data) {
      Data().updateRandomRoomGame(data);
      notifyListeners();
    });

    socket.on('requestNewGame', (data) {
      Data().updateNewGame(data);
      notifyListeners();
      debugPrint('request data $data');
    });

    // game data
    socket.on('gameInfo', (data) {
      gameInfo = data;
      // savedData.setData(data);
      Data().updateData(data);
      debugPrint('data in the game info: $data');
      notifyListeners();
      // print('this is the game info: $data');
    });
  }

  void sendGuess(String guess) async {
    final gameId = Data().gameId;
    // await savedData.getSaveGameId();
    final userId = Data().userId;
    // await savedData.getUserId();
    // print('$gameId, $userId, $guess');
    // print('guess: $guess, gameId: $gameId, userId: $userId');
    socket.emit(
        'makeGuess', {'gameId': gameId, 'playerId': userId, 'guess': guess});
  }

  void chat(
      {required String gameId,
      required String playerId,
      required String message}) {
    socket.emit(
        'chat', {'gameId': gameId, 'playerId': playerId, 'message': message});
  }

  void submitSecret(String secret) async {
    final gameId = Data().gameId;
    // await savedData.getSaveGameId();
    final userId = Data().userId;
    // await savedData.getUserId();
    // print('secret: $secret, gameId: $gameId, userId: $userId');
    socket.emit('submitSecret',
        {'gameId': gameId, 'playerId': userId, 'secretNumber': secret});
  }

  String createGame({int maxRounds = 3, int timeLimit = 60, bool isPrivate = false}) {
    gameJoined = false;
    lastError = null;
    Data().resetMatchState();
    final playerId = _currentPlayerId();
    if (playerId == null) {
      lastError = 'Please sign in first';
      notifyListeners();
      return '';
    }
    final random = Random();
    const hexChars = '0123456789abcdef';

    String gameId =
        'PNG${List.generate(15, (_) => hexChars[random.nextInt(16)]).join()}';
    this.playerId = playerId;
    this.gameId = gameId;

    // savedData.setGameId(gameId);
    Data().updateGameId(gameId);

    socket.emit('createGame', {
      'playerId': playerId, 
      'gameId': gameId,
      'settings': {
        'maxRounds': maxRounds,
        'timeLimit': timeLimit,
        'isPrivate': isPrivate
      }
    });
    notifyListeners();

    return gameId;
  }

  String createRandomGame() {
    gameJoined = false;
    lastError = null;
    Data().resetMatchState();
    final playerId = _currentPlayerId();
    if (playerId == null) {
      lastError = 'Please sign in first';
      notifyListeners();
      return '';
    }
    final random = Random();
    const hexChars = '0123456789abcdef';

    String gameId =
        'PNG${List.generate(15, (_) => hexChars[random.nextInt(16)]).join()}';
    this.playerId = playerId;
    this.gameId = gameId;

    // savedData.setGameId(gameId);
    Data().updateGameId(gameId);

    socket.emit('createRandomGames', {'playerId': playerId, 'gameId': gameId});
    notifyListeners();

    return gameId;
  }

  /// Emit joinQueue — the server will either match immediately or queue us.
  void findMatch({int maxRounds = 3, int timeLimit = 3}) {
    gameJoined = false;
    lastError = null;
    Data().resetMatchState();
    Data().resetMatchmakingState();

    final pid = _currentPlayerId();
    if (pid == null) {
      lastError = 'Please sign in first';
      notifyListeners();
      return;
    }
    playerId = pid;

    socket.emit('joinQueue', {
      'playerId': pid,
      'maxRounds': maxRounds,
      'timeLimit': timeLimit,
    });
    notifyListeners();
  }

  /// Cancel an active matchmaking search.
  void cancelMatchmaking() {
    final pid = _currentPlayerId();
    if (pid == null) return;
    socket.emit('cancelMatchmaking', {'playerId': pid});
    Data().resetMatchmakingState();
    notifyListeners();
  }

  void joinGame(String gameCode) async {
    gameJoined = false;
    lastError = null;
    Data().resetMatchState();
    final playerId = _currentPlayerId();
    if (playerId == null) {
      lastError = 'Please sign in first';
      notifyListeners();
      return;
    }
    this.playerId = playerId;
    gameId = gameCode;
    // await savedData.setUserId(playerId);
    // await savedData.setGameId(gameCode);

    Data().updateGameId(gameCode);
    // Data().updateData({});
    // Data().updateWinner({});

    socket.emit('joinGame', {'gameId': gameCode, 'playerId': playerId});
    notifyListeners();
  }

  void joinRandomGames(gameCode) {
    gameJoined = false;
    lastError = null;
    Data().resetMatchState();
    final playerId = _currentPlayerId();
    if (playerId == null) {
      lastError = 'Please sign in first';
      notifyListeners();
      return;
    }
    this.playerId = playerId;
    gameId = gameCode;
    // await savedData.setUserId(playerId);
    // await savedData.setGameId(gameCode);

    Data().updateGameId(gameCode);
    // Data().updateData({});
    // Data().updateWinner({});

    socket.emit('joinRandomGame', {'gameId': gameCode, 'playerId': playerId});
    notifyListeners();
  }

  void requestNewGame(playerId, gameId, approved) {
    socket.emit('newGame',
        {'playerId': playerId, 'gameId': gameId, 'approved': approved});
  }

  /// Cancel a private room the current player created.
  void cancelGame() {
    final gId = Data().gameId;
    final pId = _currentPlayerId();
    if (gId == null || pId == null) return;
    socket.emit('cancelGame', {'gameId': gId, 'playerId': pId});
  }

  void reportTimeout() {
    final gameId = Data().gameId;
    final userId = Data().userId;
    if (gameId != null && userId != null) {
      socket.emit('timeout', {'gameId': gameId, 'playerId': userId});
    }
  }
}
