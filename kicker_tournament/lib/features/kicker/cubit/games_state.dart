import 'package:kicker_tournament/features/kicker/models/game_models.dart';

class GamesState {
  final bool isLoading;
  final bool hasError;

  final List<Game> games;
  final Game? selectedGame;

  final List<LeaderboardEntry> leaderboard;

  const GamesState({
    this.isLoading = false,
    this.hasError = false,
    this.games = const [],
    this.selectedGame,
    this.leaderboard = const [],
  });

  GamesState copyWith({
    bool? isLoading,
    bool? hasError,
    List<Game>? games,
    Game? selectedGame,
    List<LeaderboardEntry>? leaderboard,
  }) {
    return GamesState(
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      games: games ?? this.games,
      selectedGame: selectedGame ?? this.selectedGame,
      leaderboard: leaderboard ?? this.leaderboard,
    );
  }
}
