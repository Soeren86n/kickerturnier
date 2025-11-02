import 'package:get_it/get_it.dart';
import 'package:kicker_tournament/features/kicker/data/games_local_data_source.dart';
import 'package:kicker_tournament/features/kicker/data/games_repository.dart';
import 'package:kicker_tournament/features/kicker/data/games_repository_impl.dart';

final GetIt getIt = GetIt.instance;

void setupLocator() {
  // Data sources
  getIt.registerLazySingleton<GamesLocalDataSource>(
    () => GamesLocalDataSource(),
  );

  // Repositories
  getIt.registerLazySingleton<GamesRepository>(
    () => GamesRepositoryImpl(localDataSource: getIt<GamesLocalDataSource>()),
  );
}
