import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kicker_tournament/core/logging/logger.dart';
import 'package:kicker_tournament/core/exceptions.dart';
import 'package:kicker_tournament/features/kicker/cubit/games_state.dart';
import 'package:kicker_tournament/features/kicker/data/games_repository.dart';

class GamesCubit extends Cubit<GamesState> {
  final GamesRepository gamesRepository;

  GamesCubit({required this.gamesRepository}) : super(const GamesState());

  Future<void> initLoad() async {
    emit(state.copyWith(listStatus: const OperationStatus.loading()));
    try {
      final games = await gamesRepository.loadAllGames();
      emit(state.copyWith(
        games: games,
        listStatus: const OperationStatus.success(),
      ));
    } catch (error, stackTrace) {
      log.e('initLoad failed', error: error, stackTrace: stackTrace);
      emit(state.copyWith(
        listStatus: OperationStatus.failure(_mapError(error)),
      ));
    }
  }

  Future<void> addGame({
    required String nameA,
    required String nameB,
    required int goalsA,
    required int goalsB,
  }) async {
    emit(state.copyWith(saveStatus: const OperationStatus.loading()));
    try {
      final playerA = await gamesRepository.upsertPlayerByName(nameA);
      final playerB = await gamesRepository.upsertPlayerByName(nameB);
      await gamesRepository.addGame(
        playerA: playerA,
        playerB: playerB,
        goalsA: goalsA,
        goalsB: goalsB,
      );
      final games = await gamesRepository.loadAllGames();
      emit(state.copyWith(
        games: games,
        saveStatus: const OperationStatus.success(),
      ));
    } catch (error, stackTrace) {
      log.e('addGame failed', error: error, stackTrace: stackTrace);
      emit(state.copyWith(
        saveStatus: OperationStatus.failure(_mapError(error)),
      ));
    }
  }

  Future<void> selectGameById(String id) async {
    emit(state.copyWith(selectedGameStatus: const OperationStatus.loading()));
    try {
      final game = await gamesRepository.getGameById(id);
      emit(state.copyWith(
        selectedGame: game,
        selectedGameStatus: const OperationStatus.success(),
      ));
    } catch (error, stackTrace) {
      log.e('selectGameById failed', error: error, stackTrace: stackTrace);
      emit(state.copyWith(
        selectedGameStatus: OperationStatus.failure(_mapError(error)),
      ));
    }
  }

  Future<void> deleteGameById(String id) async {
    emit(state.copyWith(deleteStatus: const OperationStatus.loading()));
    try {
      await gamesRepository.deleteGameByID(id);
      final games = await gamesRepository.loadAllGames();
      emit(state.copyWith(
        games: games,
        deleteStatus: const OperationStatus.success(),
      ));
    } catch (error, stackTrace) {
      log.e('deleteGameById failed', error: error, stackTrace: stackTrace);
      emit(state.copyWith(
        deleteStatus: OperationStatus.failure(_mapError(error)),
      ));
    }
  }

  Future<void> loadLeaderboard() async {
    emit(state.copyWith(leaderboardStatus: const OperationStatus.loading()));
    try {
      final leaderboard = await gamesRepository.loadLeaderboard();
      emit(state.copyWith(
        leaderboard: leaderboard,
        leaderboardStatus: const OperationStatus.success(),
      ));
    } catch (error, stackTrace) {
      log.e('loadLeaderboard failed', error: error, stackTrace: stackTrace);
      emit(state.copyWith(
        leaderboardStatus: OperationStatus.failure(_mapError(error)),
      ));
    }
  }

  String _mapError(Object error) {
    if (error is ValidationException) return error.message;
    if (error is StorageException) return error.message;
    if (error is DataFormatException) return error.message;
    return error.toString();
  }
}
