import 'package:kicker_tournament/features/kicker/models/game_models.dart';

abstract class GamesRepository {
  Future<List<Game>> loadAllGames();
  Future<Game> addGame({
    required Player playerA,
    required Player playerB,
    required int goalsA,
    required int goalsB,
    DateTime? createdAt,
  });
  Future<Game?> getGameById(String id);
  Future<void> deleteGameByID(String id);

  Future<List<LeaderboardEntry>> loadLeaderboard();
  Future<Player> upsertPlayerByName(String name);
}
