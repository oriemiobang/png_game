import 'package:flutter/material.dart';

class Data with ChangeNotifier {
  Map? _data;
  String? _userId; // New private variable
  String? _gameId;

  static final Data _instance = Data._internal();

  // Private constructor
  Data._internal();

  // Get the singleton instance
  factory Data() => _instance;

  // Getters
  Map? get data => _data;
  String? get userId => _userId;
  String? get gameId => _gameId;

  // Setters
  void updateData(Map newData) {
    _data = newData;
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
