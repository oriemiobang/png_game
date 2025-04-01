import 'package:flutter/material.dart';

class PlayBoardProvider with ChangeNotifier {
  bool _secretSubmitted = false;
  bool _hideText = false;
  bool _showMine = true;

  String _gameId = '';
  String _playerId = '';

  final List<Map<String, String>> _guesses = [];

  bool get secretSubmitted => _secretSubmitted;
  bool get hideText => _hideText;
  bool get showMine => _showMine;
  String get gameId => _gameId;
  String get playerId => _playerId;
  List<Map<String, String>> get guesses => _guesses;

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

  void addGuess(String guess, String position, String number) {
    _guesses.add({'guess': guess, 'position': position, 'number': number});
    notifyListeners();
  }
}
