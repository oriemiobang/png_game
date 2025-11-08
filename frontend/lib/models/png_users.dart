import 'dart:convert';

class PNGUser {
  final DateTime createdAt;
  final bool isOnline;
  final String userName;
  final List<Game> games;

  PNGUser({
    required this.createdAt,
    required this.isOnline,
    required this.userName,
    required this.games,
  });

  factory PNGUser.fromJson(Map<String, dynamic> json) {
    return PNGUser(
      createdAt: DateTime.parse(json['createdAt']),
      isOnline: json['isOnline'] ?? false,
      userName: json['user_name'] ?? '',
      games: (json['games'] as List<dynamic>?)
              ?.map((game) => Game.fromJson(game))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'createdAt': createdAt.toIso8601String(),
      'isOnline': isOnline,
      'user_name': userName,
      'games': games.map((g) => g.toJson()).toList(),
    };
  }
}

class Game {
  final String winner;
  final String gameId;
  final String opponentId;
  final String mySecretCode;
  final String opponentSecretCode;
  final String turn;
  final bool lastChance;
  final Guesses guesses;

  Game({
    required this.winner,
    required this.gameId,
    required this.opponentId,
    required this.mySecretCode,
    required this.opponentSecretCode,
    required this.turn,
    required this.lastChance,
    required this.guesses,
  });

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      winner: json['winner'] ?? '',
      gameId: json['gameId'] ?? '',
      opponentId: json['opponentId'] ?? '',
      mySecretCode: json['my_secret_code'] ?? '',
      opponentSecretCode: json['opponent_secret_code'] ?? '',
      turn: json['turn'] ?? '',
      lastChance: json['lastChance'] ?? false,
      guesses: Guesses.fromJson(json['guesses'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'winner': winner,
      'gameId': gameId,
      'opponentId': opponentId,
      'my_secret_code': mySecretCode,
      'opponent_secret_code': opponentSecretCode,
      'turn': turn,
      'lastChance': lastChance,
      'guesses': guesses.toJson(),
    };
  }
}

class Guesses {
  final List<Guess> player1;
  final List<Guess> player2;

  Guesses({required this.player1, required this.player2});

  factory Guesses.fromJson(Map<String, dynamic> json) {
    return Guesses(
      player1: (json['player1'] as List<dynamic>?)
              ?.map((g) => Guess.fromJson(g))
              .toList() ??
          [],
      player2: (json['player2'] as List<dynamic>?)
              ?.map((g) => Guess.fromJson(g))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'player1': player1.map((g) => g.toJson()).toList(),
      'player2': player2.map((g) => g.toJson()).toList(),
    };
  }
}

class Guess {
  final int guess;
  final FeedbackData feedback;

  Guess({required this.guess, required this.feedback});

  factory Guess.fromJson(Map<String, dynamic> json) {
    return Guess(
      guess: json['guess'] ?? 0,
      feedback: FeedbackData.fromJson(json['feedback'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'guess': guess,
      'feedback': feedback.toJson(),
    };
  }
}

class FeedbackData {
  final int position;
  final int number;

  FeedbackData({required this.position, required this.number});

  factory FeedbackData.fromJson(Map<String, dynamic> json) {
    return FeedbackData(
      position: json['position'] ?? 0,
      number: json['number'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'position': position,
      'number': number,
    };
  }
}
