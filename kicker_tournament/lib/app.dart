import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/kicker/data/games_local_data_source.dart';
import 'features/kicker/data/games_repository.dart';
import 'features/kicker/cubit/games_cubit.dart';
import 'features/kicker/ui/games_list_screen.dart';
import 'features/kicker/ui/new_game_screen.dart';
import 'features/kicker/ui/game_detail_screen.dart';

class KickerApp extends StatelessWidget {
  const KickerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final GamesRepository gamesRepository = GamesLocalDataSource();

    return RepositoryProvider<GamesRepository>.value(
      value: gamesRepository,
      child: BlocProvider(
        create: (_) => GamesCubit(gamesRepository: gamesRepository)..initLoad(),
        child: MaterialApp(
          title: 'Kicker Turnier',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: Colors.teal,
          ),
          routes: {
            GamesListScreen.route: (_) => const GamesListScreen(),
            NewGameScreen.route: (_) => const NewGameScreen(),
            GameDetailScreen.route: (_) => const GameDetailScreen(),
          },
          initialRoute: GamesListScreen.route,
        ),
      ),
    );
  }
}
