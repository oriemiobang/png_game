import 'package:cloud_firestore/cloud_firestore.dart';

class MyUser {
  final String? uid;
  MyUser({this.uid});
}

class UserData {
  final String? playerId;
  final String? userName;
  final Timestamp? createdAt;
  final bool? isOnline;

  final List<Game>? games;

  UserData({
    this.createdAt,
    this.games,
    this.isOnline,
  
    this.playerId,
    this.userName,

  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      playerId: json['playerId'],
      userName: json['user_name'],
      createdAt: json['createdAt'],
      isOnline: json['isOnline'],
     
      games: (json['games'] as List?)
          ?.map((game) => Game.fromJson(Map<String, dynamic>.from(game)))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'playerId': playerId,
      'user_name': userName,
      'createdAt': createdAt,
      'isOnline': isOnline,
     
      'games': games?.map((g) => g.toJson()).toList(),
    };
  }
}

class Game {
  final String? winner;
  final String? gameId;
  final String? opponentId;
  final String? mySecretCode;
  final String? opponentSecretCode;
  final String? turn;
  final bool? lastChance;
  final Guesses? guesses;

  Game({
    this.winner,
    this.gameId,
    this.opponentId,
    this.mySecretCode,
    this.opponentSecretCode,
    this.turn,
    this.lastChance,
    this.guesses,
  });

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      winner: json['winner'],
      gameId: json['gameId'],
      opponentId: json['opponentId'],
      mySecretCode: json['my_secret_code'],
      opponentSecretCode: json['opponent_secret_code'],
      turn: json['turn'],
      lastChance: json['lastChance'],
      guesses: json['guesses'] != null
          ? Guesses.fromJson(Map<String, dynamic>.from(json['guesses']))
          : null,
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
      'guesses': guesses?.toJson(),
    };
  }
}

class Guesses {
  final List<Guess>? player1;
  final List<Guess>? player2;

  Guesses({this.player1, this.player2});

  factory Guesses.fromJson(Map<String, dynamic> json) {
    return Guesses(
      player1: (json['player1'] as List?)
          ?.map((g) => Guess.fromJson(Map<String, dynamic>.from(g)))
          .toList(),
      player2: (json['player2'] as List?)
          ?.map((g) => Guess.fromJson(Map<String, dynamic>.from(g)))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'player1': player1?.map((g) => g.toJson()).toList(),
      'player2': player2?.map((g) => g.toJson()).toList(),
    };
  }
}

class Guess {
  final int? guess;
  final FeedbackData? feedback;

  Guess({this.guess, this.feedback});

  factory Guess.fromJson(Map<String, dynamic> json) {
    return Guess(
      guess: json['guess'],
      feedback: json['feedback'] != null
          ? FeedbackData.fromJson(Map<String, dynamic>.from(json['feedback']))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'guess': guess,
      'feedback': feedback?.toJson(),
    };
  }
}

class FeedbackData {
  final int? position;
  final int? number;

  FeedbackData({this.position, this.number});

  factory FeedbackData.fromJson(Map<String, dynamic> json) {
    return FeedbackData(
      position: json['position'],
      number: json['number'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'position': position,
      'number': number,
    };
  }
}
