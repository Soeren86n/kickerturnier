import 'package:equatable/equatable.dart';
import 'package:kicker_tournament/features/kicker/models/game_models.dart';

enum OperationState { idle, loading, success, failure }

class OperationStatus extends Equatable {
  const OperationStatus._(this.state, this.message);

  const OperationStatus.idle() : this._(OperationState.idle, null);
  const OperationStatus.loading() : this._(OperationState.loading, null);
  const OperationStatus.success() : this._(OperationState.success, null);
  const OperationStatus.failure(String? message) : this._(OperationState.failure, message);

  final OperationState state;
  final String? message;

  bool get isIdle => state == OperationState.idle;
  bool get isLoading => state == OperationState.loading;
  bool get isSuccess => state == OperationState.success;
  bool get isFailure => state == OperationState.failure;

  OperationStatus copyWith({
    OperationState? state,
    String? message,
  }) {
    return OperationStatus._(
      state ?? this.state,
      state == OperationState.failure ? (message ?? this.message) : null,
    );
  }

  @override
  List<Object?> get props => [state, message];
}

class GamesState extends Equatable {
  const GamesState({
    this.games = const [],
    this.selectedGame,
    this.leaderboard = const [],
    this.listStatus = const OperationStatus.idle(),
    this.saveStatus = const OperationStatus.idle(),
    this.deleteStatus = const OperationStatus.idle(),
    this.leaderboardStatus = const OperationStatus.idle(),
    this.selectedGameStatus = const OperationStatus.idle(),
  });
  final List<Game> games;
  final Game? selectedGame;
  final List<LeaderboardEntry> leaderboard;

  final OperationStatus listStatus;
  final OperationStatus saveStatus;
  final OperationStatus deleteStatus;
  final OperationStatus leaderboardStatus;
  final OperationStatus selectedGameStatus;

  static const Object _noValue = Object();

  GamesState copyWith({
    List<Game>? games,
    Object? selectedGame = _noValue,
    List<LeaderboardEntry>? leaderboard,
    OperationStatus? listStatus,
    OperationStatus? saveStatus,
    OperationStatus? deleteStatus,
    OperationStatus? leaderboardStatus,
    OperationStatus? selectedGameStatus,
  }) {
    return GamesState(
      games: games ?? this.games,
      selectedGame: identical(selectedGame, _noValue) ? this.selectedGame : selectedGame as Game?,
      leaderboard: leaderboard ?? this.leaderboard,
      listStatus: listStatus ?? this.listStatus,
      saveStatus: saveStatus ?? this.saveStatus,
      deleteStatus: deleteStatus ?? this.deleteStatus,
      leaderboardStatus: leaderboardStatus ?? this.leaderboardStatus,
      selectedGameStatus: selectedGameStatus ?? this.selectedGameStatus,
    );
  }

  @override
  List<Object?> get props => [
        games,
        selectedGame,
        leaderboard,
        listStatus,
        saveStatus,
        deleteStatus,
        leaderboardStatus,
        selectedGameStatus,
      ];
}
