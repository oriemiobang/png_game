import 'package:flutter/material.dart';
import 'package:png_game/storage/saved_data.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'dart:math';

class SocketService with ChangeNotifier {
  late io.Socket socket;
  bool isConnected = false;
  bool gameJoined = false;
  SavedData savedData = SavedData();

  String game_id = '';
  String player_id = '';

  SocketService() {
    connect();
    savedData = SavedData();
  }

  void connect() {
    socket = io.io('http://192.168.35.222:5000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false
    });

    socket.connect();

// listen to conects
    socket.onConnect((_) {
      isConnected = true;
      print('connected to server');
      notifyListeners();
    });

    // list to disconects
    socket.onDisconnect((_) {
      isConnected = false;
      print('disconnected from server');
      notifyListeners();
    });

    // listen to game joiner
    socket.on('gameJoined', (data) async {
      gameJoined = true;

      game_id = data['gameId'];
      player_id = data['playerId'];
      final gameId = await savedData.getSaveGameId();
      final userId = await savedData.getUserId();

      print('$game_id, $player_id');
      print('$gameId, $userId');

      print(data);
      notifyListeners();
    });

    // listen to game events
    socket.on('lastChance', (data) {
      print(data.message);
      notifyListeners();
    });
    socket.on('gameEnd', (data) {
      print(data);
      notifyListeners();
    });
    socket.onConnectError((data) {
      print('Connection Error: $data');
    });

    socket.onError((data) {
      print('Socket Error: $data');
    });

    // game data
    socket.on('gameInfo', (data) {
      print(data);
      notifyListeners();
    });
  }

  void sendGuess(String guess) async {
    final gameId = await savedData.getSaveGameId();
    final userId = await savedData.getUserId();
    print('$gameId, $userId, $guess');
    print('guess: ${guess}, gameId: $gameId, userId: $userId');
    socket.emit(
        'makeGuess', {'gameId': gameId, 'playerId': userId, 'guess': guess});
  }

  void submitSecret(String secret) async {
    final gameId = await savedData.getSaveGameId();
    final userId = await savedData.getUserId();
    print('secret: ${secret}, gameId: $gameId, userId: $userId');
    socket.emit('submitSecret',
        {'gameId': gameId, 'playerId': userId, 'secretNumber': secret});
  }

  String createGame() {
    final random = Random();
    const hexChars = '0123456789abcdef';

    String playerId =
        'PNG${List.generate(9, (_) => random.nextInt(10)).join()}';
    String gameId =
        'PNG${List.generate(15, (_) => hexChars[random.nextInt(16)]).join()}';
    player_id = playerId;
    game_id = gameId;

    savedData.setGameId(gameId);
    savedData.setUserId(playerId);

    socket.emit('createGame', {'playerId': playerId, 'gameId': gameId});
    notifyListeners();

    return gameId;
  }

  void joinGame(String gameCode) async {
    final random = Random();

    String playerId =
        'PNG${List.generate(9, (_) => random.nextInt(10)).join()}';
    player_id = playerId;
    game_id = gameCode;
    await savedData.setUserId(playerId);
    await savedData.setGameId(gameCode);

    socket.emit('joinGame', {'gameId': gameCode, 'playerId': playerId});
    notifyListeners();
  }
}
