import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'dart:math';

class SocketService with ChangeNotifier {
  late io.Socket socket;
  bool isConnected = false;

  String? game_id;
  String? player_id;

  SocketService() {
    connect();
  }

  void connect() {
    socket = io.io('http://localhost:5000', <String, dynamic>{
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

    // listen to game events
    socket.on('lastChance', (data) {
      print(data.message);
      notifyListeners();
    });
    socket.on('gameEnd', (data) {
      print(data);
      notifyListeners();
    });

    // game data
    socket.on('gameInfo', (data) {
      print(data);
      notifyListeners();
    });
  }

  void sendGuess(String guess) {
    socket.emit(
        'makeGuess', {'gameId': game_id, 'playerId': player_id, guess: guess});
  }

  void submitSecret(String secret) {
    socket.emit('submitSecret',
        {'gameId': game_id, 'playerId': player_id, 'secretNumber': secret});
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
    socket.emit('createGame', {playerId: playerId, gameId: gameId});

    return gameId;
  }

  void joinGame(String gameCode) {
    final random = Random();

    String playerId =
        'PNG${List.generate(9, (_) => random.nextInt(10)).join()}';
    player_id = playerId;
    socket.emit('joinGame', {'gameId': gameCode, 'playerId': playerId});
  }
}
