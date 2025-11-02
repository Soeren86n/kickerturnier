import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kicker_tournament/core/di/locator.dart';
import 'package:kicker_tournament/core/routing/app_router.dart';
import 'package:kicker_tournament/features/kicker/cubit/games_cubit.dart';
import 'package:kicker_tournament/features/kicker/data/games_repository.dart';

class KickerApp extends StatelessWidget {
  const KickerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<GamesRepository>.value(
      value: getIt<GamesRepository>(),
      child: BlocProvider(
        create: (context) => GamesCubit(gamesRepository: context.read<GamesRepository>())..initLoad(),
        child: MaterialApp.router(
          title: 'Kicker Turnier',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: Colors.teal,
          ),
          routerConfig: appRouter,
        ),
      ),
    );
  }
}
