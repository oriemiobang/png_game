import 'package:flutter/material.dart';

class Data with ChangeNotifier {
  Map? _data;
  String? _userId; // New private variable
  String? _gameId;
  Map? _winner;
  Map? _lastChance;
  String? _currentPlayer;
  String? _currentOpponent;

  List _chatData = [];

  static final Data _instance = Data._internal();

  // Private constructor
  Data._internal();

  // Get the singleton instance
  factory Data() => _instance;

  // Getters
  Map? get data => _data;
  Map? get winner => _winner;
  String? get userId => _userId;
  String? get gameId => _gameId;
  String? get currentPlayer => _currentPlayer;
  String? get currentOpponent => _currentOpponent;
  Map? get lastChance => _lastChance;

  List? get chatData => _chatData;

  // Setters
  void updateData(Map newData) {
    _data = newData;
    notifyListeners();
  }

  void updateCurrentOpponent(String opponent) {
    _currentOpponent = opponent;
    notifyListeners();
  }

  void updateCurrentPlayer(String player) {
    _currentPlayer = player;
    notifyListeners();
  }

  void updateChatData(Map newData) {
    _chatData.add(newData);
    print('the chat data $chatData');
    notifyListeners();
  }

  void updateLastChance(Map? data) {
    _lastChance = data;
    notifyListeners();
  }

  void updateWinner(Map? newWinner) {
    _winner = newWinner;
    notifyListeners();
  }

  void updateGameId(String newData) {
    _gameId = newData;
    notifyListeners();
  }

  void updateUserId(String newUserId) {
    _userId = newUserId;
    notifyListeners();
  }
}
