import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:kicker_tournament/core/logging/logger.dart';
import 'package:kicker_tournament/core/exceptions.dart';

@immutable
class Player extends Equatable {
  final String id;
  final String name;

  const Player({required this.id, required this.name});

  Map<String, dynamic> toMap() => {'id': id, 'name': name};

  static Player fromMap(Map<String, dynamic> map) {
    try {
      final id = map['id'] as String?;
      final name = map['name'] as String?;

      if (id == null || id.isEmpty) {
        throw DataFormatException(
          'Player id is missing or empty',
          originalData: map,
        );
      }
      if (name == null || name.isEmpty) {
        throw DataFormatException(
          'Player name is missing or empty',
          originalData: map,
        );
      }

      return Player(id: id, name: name);
    } catch (e, stackTrace) {
      if (e is DataFormatException) rethrow;
      throw DataFormatException(
        'Failed to parse Player from map',
        originalData: map,
        stackTrace: stackTrace,
      );
    }
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
    try {
      final id = map['id'] as String?;
      if (id == null || id.isEmpty) {
        throw DataFormatException(
          'Game id is missing or empty',
          originalData: map,
        );
      }

      final playerAData = map['playerA'] as Map<String, dynamic>?;
      final playerBData = map['playerB'] as Map<String, dynamic>?;
      if (playerAData == null || playerBData == null) {
        throw DataFormatException(
          'Player data is missing',
          originalData: map,
        );
      }

      final playerA = Player.fromMap(playerAData);
      final playerB = Player.fromMap(playerBData);

      final goalsA = map['goalsA'] as int?;
      final goalsB = map['goalsB'] as int?;
      if (goalsA == null || goalsB == null || goalsA < 0 || goalsB < 0) {
        throw DataFormatException(
          'Goals are missing or invalid (must be >= 0)',
          originalData: map,
        );
      }

      final winnerId = map['winnerId'] as String? ?? '';

      final gamePlayedAtString = map['gamePlayedAt'] as String?;
      if (gamePlayedAtString == null || gamePlayedAtString.isEmpty) {
        throw DataFormatException(
          'gamePlayedAt is missing',
          originalData: map,
        );
      }

      final DateTime gamePlayedAt;
      try {
        gamePlayedAt = DateTime.parse(gamePlayedAtString);
      } catch (e) {
        throw DataFormatException(
          'Invalid gamePlayedAt format: $gamePlayedAtString',
          originalData: map,
        );
      }

      return Game(
        id: id,
        playerA: playerA,
        playerB: playerB,
        goalsA: goalsA,
        goalsB: goalsB,
        winnerId: winnerId,
        gamePlayedAt: gamePlayedAt,
      );
    } catch (e, stackTrace) {
      if (e is DataFormatException) rethrow;
      throw DataFormatException(
        'Failed to parse Game from map',
        originalData: map,
        stackTrace: stackTrace,
      );
    }
  }

  static Game? fromMapSafe(Map<String, dynamic> map) {
    try {
      return fromMap(map);
    } catch (e) {
      // Log silently, return null für fehlerhafte Einträge
      log.w('Failed to parse Game: $e');
      return null;
    }
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
  List<Object?> get props =>
      [player, wins, goalsScored, goalsConceded, gamesPlayed];
}
