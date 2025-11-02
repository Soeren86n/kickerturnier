import 'package:flutter_test/flutter_test.dart';
import 'package:kicker_tournament/features/kicker/data/games_local_data_source.dart';
import 'package:kicker_tournament/features/kicker/models/game_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  test('addGame', () async {
    final repo = GamesLocalDataSource();

    Player playerA = const Player(id: 'p1', name: 'Jürgen');
    Player playerB = const Player(id: 'p2', name: 'Willi');
    Player playerC = const Player(id: 'p3', name: 'Hans');

    await repo.addGame(
      playerA: playerA,
      playerB: playerB,
      goalsA: 10,
      goalsB: 1,
      createdAt: DateTime(2025, 1, 10, 10, 0),
    );
    await repo.addGame(
      playerA: playerB,
      playerB: playerC,
      goalsA: 5,
      goalsB: 5,
      createdAt: DateTime(2025, 1, 11, 9, 0),
    );
    await repo.addGame(
      playerA: playerC,
      playerB: playerA,
      goalsA: 10,
      goalsB: 1,
      createdAt: DateTime(2025, 1, 12, 8, 0),
    );

    final all = await repo.loadAllGames();
    expect(all.length, 3);
  });
}
