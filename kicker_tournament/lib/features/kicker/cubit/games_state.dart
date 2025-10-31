import 'package:equatable/equatable.dart';
import 'package:kicker_tournament/features/kicker/models/game_models.dart';

class GamesState extends Equatable {
  final bool isLoading;
  final bool hasError;

  final List<Game> games;
  final Game? selectedGame;
  static const Object _noValue = Object();

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
    Object? selectedGame = _noValue,
    List<LeaderboardEntry>? leaderboard,
  }) {
    return GamesState(
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      games: games ?? this.games,
      selectedGame: identical(selectedGame, _noValue) ? this.selectedGame : selectedGame as Game?,
      leaderboard: leaderboard ?? this.leaderboard,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        hasError,
        games,
        selectedGame,
        leaderboard,
      ];
}
