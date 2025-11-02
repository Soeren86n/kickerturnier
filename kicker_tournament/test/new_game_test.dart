import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kicker_tournament/features/kicker/cubit/games_cubit.dart';
import 'package:kicker_tournament/features/kicker/data/games_local_data_source.dart';
import 'package:kicker_tournament/features/kicker/data/games_repository.dart';
import 'package:kicker_tournament/features/kicker/data/games_repository_impl.dart';
import 'package:kicker_tournament/features/kicker/ui/game_detail_screen.dart';
import 'package:kicker_tournament/features/kicker/ui/games_list_screen.dart';
import 'package:kicker_tournament/features/kicker/ui/new_game_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  Widget buildTestApp() {
    final repo = GamesRepositoryImpl(localDataSource: GamesLocalDataSource());
    final cubit = GamesCubit(gamesRepository: repo)..initLoad();

    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const GamesListScreen(),
        ),
        GoRoute(
          path: '/new',
          builder: (context, state) => const NewGameScreen(),
        ),
        GoRoute(
          path: '/game/:id',
          builder: (context, state) {
            final gameId = state.pathParameters['id']!;
            return GameDetailScreen(gameId: gameId);
          },
        ),
      ],
    );

    return RepositoryProvider<GamesRepository>.value(
      value: repo,
      child: BlocProvider<GamesCubit>.value(
        value: cubit,
        child: MaterialApp.router(
          routerConfig: router,
        ),
      ),
    );
  }

  testWidgets('create new game an appears in list', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    expect(find.text('Noch keine Spiele erfasst.'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(find.text('Neues Spiel'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('playerANameField')), 'Jürgen');
    await tester.enterText(find.byKey(const Key('playerBNameField')), 'Willi');
    await tester.enterText(find.byKey(const Key('goalsAField')), '10');
    await tester.enterText(find.byKey(const Key('goalsBField')), '5');

    await tester.tap(find.byKey(const Key('submitNewGameButton')));
    await tester.pumpAndSettle();

    expect(find.text('Jürgen 10 : 5 Willi'), findsOneWidget);
  });
}
