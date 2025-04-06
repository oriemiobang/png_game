import 'package:flutter/material.dart';

class Data with ChangeNotifier {
  Map? _data;
  String? _userId; // New private variable
  String? _gameId;
  Map? _winner;
  Map? _lastChance;
  Map? _turn;
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
  Map? get lastChance => _lastChance;
  Map? get turn => _turn;
  List? get chatData => _chatData;

  // Setters
  void updateData(Map newData) {
    _data = newData;
    notifyListeners();
  }

  void updateTurn(Map newData) {
    _turn = newData;
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
