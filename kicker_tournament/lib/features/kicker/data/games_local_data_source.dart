import 'dart:convert';
import 'package:kicker_tournament/core/logging/logger.dart';
import 'package:kicker_tournament/core/exceptions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kicker_tournament/features/kicker/data/games_repository.dart';
import 'package:kicker_tournament/features/kicker/models/game_models.dart';
import 'package:uuid/uuid.dart';

class GamesLocalDataSource implements GamesRepository {
  final List<Game> _store = [];
  static const _kGamesKey = 'games_store_v1';
  bool _loaded = false;

  Future<void> _ensureLoaded() async {
    if (_loaded) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_kGamesKey);

      if (jsonString != null && jsonString.isNotEmpty) {
        try {
          final List<dynamic> list = jsonDecode(jsonString) as List<dynamic>;
          _store.clear();

          // Fehlerhafte Einträge überspringen statt zu crashen
          for (final item in list) {
            if (item is! Map) {
              log.w('Skipping corrupted game entry: unexpected type ${item.runtimeType}');
              continue;
            }
            final game = Game.fromMapSafe(item.cast<String, dynamic>());
            if (game != null) {
              _store.add(game);
            }
          }

          log.i('Loaded ${_store.length} games from storage');
        } catch (e) {
          // JSON-Parsing fehlgeschlagen - Storage ist korrupt
          log.e('Failed to parse games storage, starting fresh', error: e);
          _store.clear();
        }
      }
    } catch (error, stackTrace) {
      log.e('Failed to load games from storage', error: error, stackTrace: stackTrace);
      throw StorageException(
        'Failed to load games from storage',
        cause: error,
        stackTrace: stackTrace,
      );
    }

    _loaded = true;
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_store.map((g) => g.toMap()).toList());
    final success = await prefs.setString(_kGamesKey, encoded);
    if (!success) {
      log.e('Failed to persist games to storage');
      throw StorageException('Failed to persist games to storage');
    }
  }

  @override
  Future<List<Game>> loadAllGames() async {
    await _ensureLoaded();
    return List<Game>.unmodifiable(_store);
  }

  @override
  Future<Game> addGame({
    required Player playerA,
    required Player playerB,
    required int goalsA,
    required int goalsB,
    DateTime? createdAt,
  }) async {
    await _ensureLoaded();
    final id = const Uuid().v4();
    final winnerID = _getWinnerID(
      playerA: playerA,
      playerB: playerB,
      goalsA: goalsA,
      goalsB: goalsB,
    );
    final game = Game(
      id: id,
      playerA: playerA,
      playerB: playerB,
      goalsA: goalsA,
      goalsB: goalsB,
      winnerId: winnerID,
      gamePlayedAt: createdAt ?? DateTime.now(),
    );
    _store.add(game);
    await _persist();
    return game;
  }

  @override
  Future<Game?> getGameById(String id) async {
    await _ensureLoaded();
    try {
      return _store.firstWhere((game) => game.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> deleteGameByID(String id) async {
    await _ensureLoaded();
    _store.removeWhere((g) => g.id == id);
    await _persist();
  }

  @override
  Future<List<LeaderboardEntry>> loadLeaderboard() async {
    await _ensureLoaded();
    final Map<String, _LeaderboardAccumulator> allPlayers = {};

    for (final game in _store) {
      _updateLeaderboardEntry(
        allPlayers,
        player: game.playerA,
        goalsFor: game.goalsA,
        goalsAgainst: game.goalsB,
        didWin: game.winnerId == game.playerA.id,
      );
      _updateLeaderboardEntry(
        allPlayers,
        player: game.playerB,
        goalsFor: game.goalsB,
        goalsAgainst: game.goalsA,
        didWin: game.winnerId == game.playerB.id,
      );
    }

    final leaderboard = allPlayers.values.map((entry) => entry.toLeaderboardEntry()).toList()
      ..sort((a, b) {
        final winsComparison = b.wins.compareTo(a.wins);
        if (winsComparison != 0) return winsComparison;
        return b.goalDifference.compareTo(a.goalDifference);
      });
    return leaderboard;
  }

  @override
  Future<Player> upsertPlayerByName(String name) async {
    await _ensureLoaded();
    final normalized = name.trim();
    if (normalized.isEmpty) {
      throw DataFormatException('Player name is missing or empty', originalData: name);
    }
    final lookup = normalized.toLowerCase();
    for (final game in _store) {
      if (game.playerA.name.toLowerCase() == lookup) {
        return game.playerA;
      }
      if (game.playerB.name.toLowerCase() == lookup) {
        return game.playerB;
      }
    }

    final id = const Uuid().v4();
    final newPlayer = Player(id: id, name: normalized);
    return newPlayer;
  }

  String _getWinnerID({
    required Player playerA,
    required Player playerB,
    required int goalsA,
    required int goalsB,
  }) {
    if (goalsA > goalsB) return playerA.id;
    if (goalsB > goalsA) return playerB.id;
    return '';
  }
}

class _LeaderboardAccumulator {
  _LeaderboardAccumulator({required this.player});

  final Player player;
  int wins = 0;
  int goalsScored = 0;
  int goalsConceded = 0;
  int gamesPlayed = 0;

  LeaderboardEntry toLeaderboardEntry() => LeaderboardEntry(
        player: player,
        wins: wins,
        goalsScored: goalsScored,
        goalsConceded: goalsConceded,
        gamesPlayed: gamesPlayed,
      );
}

void _updateLeaderboardEntry(
  Map<String, _LeaderboardAccumulator> entries, {
  required Player player,
  required int goalsFor,
  required int goalsAgainst,
  required bool didWin,
}) {
  final accumulator = entries.putIfAbsent(player.id, () => _LeaderboardAccumulator(player: player));
  accumulator.gamesPlayed += 1;
  accumulator.goalsScored += goalsFor;
  accumulator.goalsConceded += goalsAgainst;
  if (didWin) {
    accumulator.wins += 1;
  }
}
