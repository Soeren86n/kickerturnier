import 'package:flutter_test/flutter_test.dart';
import 'package:kicker_tournament/features/kicker/cubit/games_cubit.dart';
import 'package:kicker_tournament/features/kicker/data/games_repository.dart';
import 'package:kicker_tournament/features/kicker/models/game_models.dart';

void main() {
  group('GamesCubit', () {
    late FakeGamesRepository repository;
    late GamesCubit cubit;

    setUp(() {
      repository = FakeGamesRepository();
      cubit = GamesCubit(gamesRepository: repository);
    });

    tearDown(() {
      cubit.close();
    });

    test('initLoad loads games into state and sets success status', () async {
      repository.seedGames([
        repository.buildGame(
          id: 'g1',
          playerAName: 'Alice',
          playerBName: 'Bob',
          goalsA: 5,
          goalsB: 2,
        ),
      ]);

      await cubit.initLoad();

      expect(cubit.state.games, hasLength(1));
      expect(cubit.state.listStatus.isSuccess, isTrue);
      expect(cubit.state.listStatus.isFailure, isFalse);
    });

    test('initLoad marks failure state when repository throws', () async {
      repository.throwOnLoad = true;

      await cubit.initLoad();

      expect(cubit.state.listStatus.isFailure, isTrue);
      expect(cubit.state.games, isEmpty);
    });

    test('addGame persists game and updates state on success', () async {
      await cubit.addGame(nameA: 'Alice', nameB: 'Bob', goalsA: 3, goalsB: 1);

      expect(cubit.state.saveStatus.isSuccess, isTrue);
      expect(cubit.state.games, hasLength(1));
      final game = cubit.state.games.first;
      expect(game.playerA.name, 'Alice');
      expect(game.goalsA, 3);
    });

    test('addGame marks failure when repository throws', () async {
      repository.throwOnAdd = true;

      await cubit.addGame(nameA: 'Alice', nameB: 'Bob', goalsA: 3, goalsB: 1);

      expect(cubit.state.saveStatus.isFailure, isTrue);
      expect(cubit.state.games, isEmpty);
    });
  });
}

class FakeGamesRepository implements GamesRepository {
  final List<Game> _games = [];
  bool throwOnLoad = false;
  bool throwOnAdd = false;

  void seedGames(List<Game> games) {
    _games
      ..clear()
      ..addAll(games);
  }

  Game buildGame({
    required String id,
    required String playerAName,
    required String playerBName,
    required int goalsA,
    required int goalsB,
  }) {
    final playerA = Player(id: 'player-$playerAName', name: playerAName);
    final playerB = Player(id: 'player-$playerBName', name: playerBName);
    final winnerId = goalsA == goalsB ? '' : (goalsA > goalsB ? playerA.id : playerB.id);
    return Game(
      id: id,
      playerA: playerA,
      playerB: playerB,
      goalsA: goalsA,
      goalsB: goalsB,
      winnerId: winnerId,
      gamePlayedAt: DateTime.now(),
    );
  }

  @override
  Future<Game> addGame({
    required Player playerA,
    required Player playerB,
    required int goalsA,
    required int goalsB,
    DateTime? createdAt,
  }) async {
    if (throwOnAdd) {
      throw Exception('add error');
    }
    final game = Game(
      id: 'game-${_games.length + 1}',
      playerA: playerA,
      playerB: playerB,
      goalsA: goalsA,
      goalsB: goalsB,
      winnerId: _winnerId(playerA: playerA, playerB: playerB, goalsA: goalsA, goalsB: goalsB),
      gamePlayedAt: createdAt ?? DateTime.now(),
    );
    _games.add(game);
    return game;
  }

  @override
  Future<void> deleteGameByID(String id) async {
    _games.removeWhere((game) => game.id == id);
  }

  @override
  Future<Game?> getGameById(String id) async {
    try {
      return _games.firstWhere((game) => game.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Game>> loadAllGames() async {
    if (throwOnLoad) {
      throw Exception('load error');
    }
    return List<Game>.unmodifiable(_games);
  }

  @override
  Future<List<LeaderboardEntry>> loadLeaderboard() async {
    return const [];
  }

  @override
  Future<Player> upsertPlayerByName(String name) async {
    final trimmed = name.trim();
    final lookup = trimmed.toLowerCase();
    for (final game in _games) {
      if (game.playerA.name.toLowerCase() == lookup) {
        return game.playerA;
      }
      if (game.playerB.name.toLowerCase() == lookup) {
        return game.playerB;
      }
    }
    return Player(id: 'player-${_games.length + 1}-$lookup', name: trimmed);
  }

  String _winnerId({
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
