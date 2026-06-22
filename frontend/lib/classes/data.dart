import 'package:flutter/material.dart';

class Data with ChangeNotifier {
  Map? _data;
  String? _userId; // New private variable
  String? _gameId;
  Map? _winner;
  Map? _lastChance;
  String? _currentPlayer;
  String? _currentOpponent;
  Map? _notYourTurn;
  Map _randomGames = {};
  Map _randomRoomGame = {};
  Map? _newGame;
  bool _gameOver = false;
  int _unreadMessages = 0;

  // ── Matchmaking state ──
  bool _isSearchingForMatch = false;
  bool _matchmakingTimedOut = false;
  Map<String, dynamic>? _matchFoundData;

  // ── Private room state ──
  Map<String, dynamic>? _opponentJoined; // set when 'playerJoined' fires

  //

  final List _chatData = [];

  static final Data _instance = Data._internal();

  // Private constructor
  Data._internal();

  // Get the singleton instance
  factory Data() => _instance;

  // Getters
  Map? get data => _data;
  bool get gameOver => _gameOver;
  Map? get winner => _winner;
  String? get userId => _userId;
  String? get gameId => _gameId;
  String? get currentPlayer => _currentPlayer;
  String? get currentOpponent => _currentOpponent;
  Map? get lastChance => _lastChance;
  Map? get notYourTurn => _notYourTurn;
  Map? get randomGames => _randomGames;
  Map? get randomRoomGame => _randomRoomGame;
  Map? get newGame => _newGame;
  int get unreadMessages => _unreadMessages;

  // ── Matchmaking getters ──
  bool get isSearchingForMatch => _isSearchingForMatch;
  bool get matchmakingTimedOut => _matchmakingTimedOut;
  Map<String, dynamic>? get matchFoundData => _matchFoundData;

  // ── Private room getters ──
  Map<String, dynamic>? get opponentJoined => _opponentJoined;

  List? get chatData => _chatData;

  // Setters

  void updateGameOver(bool newValue) {
    _gameOver = newValue;
    notifyListeners();
  }

  void resetMatchState() {
    _data = null;
    _winner = null;
    _lastChance = null;
    _notYourTurn = null;
    _newGame = null;
    _gameOver = false;
    _chatData.clear();
    _unreadMessages = 0;
    _opponentJoined = null;
    notifyListeners();
  }

  // ── Matchmaking setters ──
  void setSearchingForMatch(bool value) {
    _isSearchingForMatch = value;
    _matchmakingTimedOut = false;
    notifyListeners();
  }

  void setMatchmakingTimedOut() {
    _isSearchingForMatch = false;
    _matchmakingTimedOut = true;
    notifyListeners();
  }

  void setMatchFound(Map<String, dynamic> data) {
    _isSearchingForMatch = false;
    _matchmakingTimedOut = false;
    _matchFoundData = data;
    notifyListeners();
  }

  void resetMatchmakingState() {
    _isSearchingForMatch = false;
    _matchmakingTimedOut = false;
    _matchFoundData = null;
    notifyListeners();
  }

  void updateOpponentJoined(Map<String, dynamic> data) {
    _opponentJoined = data;
    notifyListeners();
  }

  void updateNewGame(Map? newData) {
    _newGame = newData;
    notifyListeners();
  }

  void updateData(Map newData) {
    _data = newData;
    notifyListeners();
  }

  void updateRandomRoomGame(Map newData) {
    _randomRoomGame = newData;
    notifyListeners();
  }

  void updateRandomGames(Map newData) {
    _randomGames = newData;
    notifyListeners();
  }

  void updateCurrentOpponent(String opponent) {
    _currentOpponent = opponent;
    notifyListeners();
  }

  void updateNotYourTurn(Map? newData) {
    _notYourTurn = newData;
    notifyListeners();
  }

  void updateCurrentPlayer(String player) {
    _currentPlayer = player;
    notifyListeners();
  }

  void updateChatData(Map newData) {
    _chatData.add(newData);
    debugPrint('the chat data $chatData');
    notifyListeners();
  }

  void incrementUnreadMessages() {
    _unreadMessages++;
    notifyListeners();
  }

  void clearUnreadMessages() {
    _unreadMessages = 0;
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

  List _publicRooms = [];
  List get publicRooms => _publicRooms;

  void updatePublicRooms(List rooms) {
    _publicRooms = rooms;
    notifyListeners();
  }
}
