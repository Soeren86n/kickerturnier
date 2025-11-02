import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kicker_tournament/features/kicker/cubit/games_cubit.dart';
import 'package:kicker_tournament/features/kicker/data/games_local_data_source.dart';
import 'package:kicker_tournament/features/kicker/data/games_repository.dart';
import 'package:kicker_tournament/features/kicker/ui/game_detail_screen.dart';
import 'package:kicker_tournament/features/kicker/ui/games_list_screen.dart';
import 'package:kicker_tournament/features/kicker/ui/new_game_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  Widget buildTestApp() {
    final repo = GamesLocalDataSource();
    final cubit = GamesCubit(gamesRepository: repo)..initLoad();

    return RepositoryProvider<GamesRepository>.value(
      value: repo,
      child: BlocProvider<GamesCubit>.value(
        value: cubit,
        child: MaterialApp(
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

  testWidgets('create new game an appears in list',
      (WidgetTester tester) async {
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
