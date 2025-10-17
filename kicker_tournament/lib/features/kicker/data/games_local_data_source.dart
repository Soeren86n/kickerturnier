import 'dart:convert';
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
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_kGamesKey);
    if (jsonString != null && jsonString.isNotEmpty) {
      final List<dynamic> list = jsonDecode(jsonString);
      _store
        ..clear()
        ..addAll(list.map((e) => Game.fromMap((e as Map).cast<String, dynamic>())));
    }
    _loaded = true;
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_store.map((g) => g.toMap()).toList());
    await prefs.setString(_kGamesKey, encoded);
  }

  @override
  Future<List<Game>> loadAllGames() async {
    await _ensureLoaded();
    return _store;
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
    final Map<String, LeaderboardEntry> allPlayers = {};

    for (final game in _store) {
      if (!allPlayers.containsKey(game.playerA.id)) {
        allPlayers[game.playerA.id] = LeaderboardEntry(
          player: game.playerA,
          wins: 0,
          goalsScored: 0,
          goalsConceded: 0,
          gamesPlayed: 0,
        );
      }

      final entryA = allPlayers[game.playerA.id]!;
      allPlayers[game.playerA.id] = LeaderboardEntry(
        player: entryA.player,
        wins: entryA.wins + (game.winnerId == game.playerA.id ? 1 : 0),
        goalsScored: entryA.goalsScored + game.goalsA,
        goalsConceded: entryA.goalsConceded + game.goalsB,
        gamesPlayed: entryA.gamesPlayed + 1,
      );

      if (!allPlayers.containsKey(game.playerB.id)) {
        allPlayers[game.playerB.id] = LeaderboardEntry(
          player: game.playerB,
          wins: 0,
          goalsScored: 0,
          goalsConceded: 0,
          gamesPlayed: 0,
        );
      }

      final entryB = allPlayers[game.playerB.id]!;
      allPlayers[game.playerB.id] = LeaderboardEntry(
        player: entryB.player,
        wins: entryB.wins + (game.winnerId == game.playerB.id ? 1 : 0),
        goalsScored: entryB.goalsScored + game.goalsB,
        goalsConceded: entryB.goalsConceded + game.goalsA,
        gamesPlayed: entryB.gamesPlayed + 1,
      );
    }

    final leaderboard = allPlayers.values.toList()
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
    for (final game in _store) {
      if (game.playerA.name == name) {
        return game.playerA;
      }
      if (game.playerB.name == name) {
        return game.playerB;
      }
    }

    final id = const Uuid().v4();
    final newPlayer = Player(id: id, name: name);
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
