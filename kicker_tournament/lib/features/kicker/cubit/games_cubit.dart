import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kicker_tournament/features/kicker/cubit/games_state.dart';
import 'package:kicker_tournament/features/kicker/data/games_repository.dart';

class GamesCubit extends Cubit<GamesState> {
  final GamesRepository gamesRepository;

  GamesCubit({required this.gamesRepository}) : super(const GamesState());

  Future<void> initLoad() async {
    emit(state.copyWith(isLoading: true, hasError: false));
    try {
      final games = await gamesRepository.loadAllGames();
      emit(state.copyWith(
        isLoading: false,
        games: games,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, hasError: true));
    }
  }

  Future<void> addGame({
    required String nameA,
    required String nameB,
    required int goalsA,
    required int goalsB,
  }) async {
    emit(state.copyWith(isLoading: true, hasError: false));
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
        isLoading: false,
        games: games,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, hasError: true));
    }
  }

  Future<void> selectGameById(String id) async {
    emit(state.copyWith(isLoading: true, hasError: false));
    try {
      final game = await gamesRepository.getGameById(id);
      emit(state.copyWith(isLoading: false, selectedGame: game));
    } catch (e) {
      emit(state.copyWith(isLoading: false, hasError: true));
    }
  }

  Future<void> deleteGameById(String id) async {
    emit(state.copyWith(isLoading: true, hasError: false));
    try {
      await gamesRepository.deleteGameByID(id);
      final games = await gamesRepository.loadAllGames();
      emit(state.copyWith(
        isLoading: false,
        games: games,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, hasError: true));
    }
  }

  Future<void> loadLeaderboard() async {
    emit(state.copyWith(isLoading: true, hasError: false));
    try {
      final leaderboard = await gamesRepository.loadLeaderboard();
      emit(state.copyWith(
        isLoading: false,
        leaderboard: leaderboard,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, hasError: true));
    }
  }
}
