import 'package:kicker_tournament/features/kicker/data/games_local_data_source.dart';
import 'package:kicker_tournament/features/kicker/data/games_repository.dart';
import 'package:kicker_tournament/features/kicker/models/game_models.dart';

/// Concrete repository implementation orchestrating access to data sources.
///
/// Why: separating the repository interface from its implementation decouples
/// the domain layer from storage details and makes testing and future changes
/// (e.g., adding a REST API) much easier.
class GamesRepositoryImpl implements GamesRepository {
  GamesRepositoryImpl({required GamesLocalDataSource localDataSource}) : _local = localDataSource;

  final GamesLocalDataSource _local;

  @override
  Future<Game> addGame({
    required Player playerA,
    required Player playerB,
    required int goalsA,
    required int goalsB,
    DateTime? createdAt,
  }) {
    return _local.addGame(
      playerA: playerA,
      playerB: playerB,
      goalsA: goalsA,
      goalsB: goalsB,
      createdAt: createdAt,
    );
  }

  @override
  Future<void> deleteGameByID(String id) => _local.deleteGameByID(id);

  @override
  Future<Game?> getGameById(String id) => _local.getGameById(id);

  @override
  Future<List<Game>> loadAllGames() => _local.loadAllGames();

  @override
  Future<List<LeaderboardEntry>> loadLeaderboard() => _local.loadLeaderboard();

  @override
  Future<Player> upsertPlayerByName(String name) => _local.upsertPlayerByName(name);
}
