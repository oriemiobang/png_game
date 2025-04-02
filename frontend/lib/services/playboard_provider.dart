import 'package:flutter/material.dart';
import 'package:png_game/services/socket_service.dart';
import 'package:png_game/storage/saved_data.dart';

class PlayBoardProvider with ChangeNotifier {
  bool _secretSubmitted = false;
  bool _hideText = false;
  bool _showMine = true;
  SocketService socketService = SocketService();
  SavedData savedData = SavedData();

  PlayBoardProvider() {
    socketService = SocketService();
    savedData = SavedData();
  }
  String _gameId = '';
  String _playerId = '';

  // List _guesses = [];

  bool get secretSubmitted => _secretSubmitted;
  bool get hideText => _hideText;
  bool get showMine => _showMine;
  String get gameId => _gameId;
  String get playerId => _playerId;
  // List get guesses => _guesses;

  void setGameId(String id) {
    _gameId = id;
    notifyListeners();
  }

  void setPlayerId(String id) {
    _playerId = id;
    notifyListeners();
  }

  void toggleHideText() {
    _hideText = !_hideText;
    notifyListeners();
  }

  void submitSecret() {
    _secretSubmitted = true;
    notifyListeners();
  }

  void toggleBoard(bool isMine) {
    _showMine = isMine;
    notifyListeners();
  }

  // void addGuess(String guess, String position, String number) async {
  //   final data = await savedData.getData();
  //   final userId = await savedData.getUserId();
  //   String player = data['player1'] == userId ? 'player1' : 'player2';
  //   print('my data $data');
  //   print('current palyer $player');
  //   print('current list ${data['guesses'][player]}');
  //   // _guesses = data['guesses'][player];
  //   print('after assigning guesses $_guesses');
  //   // _guesses.add({'guess': guess, 'position': position, 'number': number});
  //   notifyListeners();
  // }
}
