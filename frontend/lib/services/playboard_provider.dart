import 'package:flutter/material.dart';

class PlayBoardProvider with ChangeNotifier {
  bool _secretSubmitted = false;
  bool _hideText = false;
  bool _showMine = true;

  List<Map<String, String>> _guesses = [
    {'guess': '1324', 'position': '2', 'number': '3'},
    {'guess': '1358', 'position': '2', 'number': '3'},
    {'guess': '1324', 'position': '2', 'number': '3'},
    {'guess': '1324', 'position': '2', 'number': '3'},
  ];

  bool get secretSubmitted => _secretSubmitted;
  bool get hideText => _hideText;
  bool get showMine => _showMine;
  List<Map<String, String>> get guesses => _guesses;

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
