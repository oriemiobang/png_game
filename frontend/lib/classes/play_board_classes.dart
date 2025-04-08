import 'package:flutter/material.dart';

class PlayBoardClasses with ChangeNotifier {
  List _guesses = [];
  String _mySecret = '';
  bool _isSubmitted = false;
  bool _showSecret = false;
  String _chatValue = '';

  static final PlayBoardClasses _instance = PlayBoardClasses._internal();
  // Get the singleton instance
  factory PlayBoardClasses() => _instance;
  // Private constructor
  PlayBoardClasses._internal();

  List get guesses => _guesses;
  String get mySecret => _mySecret;
  bool get isSubmitted => _isSubmitted;
  bool get showSecret => _showSecret;
  String get chatValue => _chatValue;

  void setGuesses(List data) {
    _guesses = data;
    notifyListeners();
  }

  void setMySecret(String data) {
    _mySecret = data;
    notifyListeners();
  }

  void setIsSubmitted(bool data) {
    _isSubmitted = data;
    notifyListeners();
  }

  void setShowSecret(bool data) {
    _showSecret = data;
    notifyListeners();
  }

  void setChatValue(String data) {
    _chatValue = data;
    notifyListeners();
  }
}
