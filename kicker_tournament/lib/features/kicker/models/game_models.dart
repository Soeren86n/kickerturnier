import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class Player extends Equatable {
  final String id;
  final String name;

  const Player({required this.id, required this.name});

  Map<String, dynamic> toMap() => {'id': id, 'name': name};

  static Player fromMap(Map<String, dynamic> map) {
    return Player(
      id: map['id'] as String,
      name: map['name'] as String,
    );
  }

  @override
  List<Object?> get props => [id, name];
}

@immutable
class Game extends Equatable {
  final String id;
  final Player playerA;
  final Player playerB;
  final int goalsA;
  final int goalsB;
  final String winnerId;
  final DateTime gamePlayedAt;

  const Game({
    required this.id,
    required this.playerA,
    required this.playerB,
    required this.goalsA,
    required this.goalsB,
    required this.winnerId,
    required this.gamePlayedAt,
  });

  Player? get winner {
    if (winnerId == playerA.id) {
      return playerA;
    } else if (winnerId == playerB.id) {
      return playerB;
    } else {
      return null;
    }
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'playerA': playerA.toMap(),
        'playerB': playerB.toMap(),
        'goalsA': goalsA,
        'goalsB': goalsB,
        'winnerId': winnerId,
        'gamePlayedAt': gamePlayedAt.toIso8601String(),
      };

  String toJson() => jsonEncode(toMap());

  static Game fromMap(Map<String, dynamic> map) {
    return Game(
      id: map['id'] as String,
      playerA: Player.fromMap(map['playerA'] as Map<String, dynamic>),
      playerB: Player.fromMap(map['playerB'] as Map<String, dynamic>),
      goalsA: map['goalsA'] as int,
      goalsB: map['goalsB'] as int,
      winnerId: map['winnerId'] as String,
      gamePlayedAt: DateTime.parse(map['gamePlayedAt'] as String),
    );
  }

  static Game fromJson(String source) => fromMap(jsonDecode(source));

  @override
  List<Object?> get props => [
        id,
        playerA,
        playerB,
        goalsA,
        goalsB,
        winnerId,
        gamePlayedAt,
      ];
}

@immutable
class LeaderboardEntry extends Equatable {
  final Player player;
  final int wins;
  final int goalsScored;
  final int goalsConceded;
  final int gamesPlayed;

  const LeaderboardEntry({
    required this.player,
    required this.wins,
    required this.goalsScored,
    required this.goalsConceded,
    required this.gamesPlayed,
  });

  int get goalDifference => goalsScored - goalsConceded;

  @override
  List<Object?> get props => [player, wins, goalsScored, goalsConceded, gamesPlayed];
}
