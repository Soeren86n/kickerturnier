import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kicker_tournament/features/kicker/cubit/games_cubit.dart';
import 'package:kicker_tournament/features/kicker/cubit/games_state.dart';
import 'package:kicker_tournament/utils/date_format_helper.dart';

class GameDetailScreen extends StatelessWidget {
  static const route = '/detail';
  const GameDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final id = ModalRoute.of(context)!.settings.arguments as String?;
    if (id == null) {
      return const Scaffold(body: Center(child: Text('Kein Spiel ausgewählt.')));
    }
    context.read<GamesCubit>().selectGameById(id);

    return Scaffold(
      appBar: AppBar(title: const Text('Spiel-Details')),
      body: BlocBuilder<GamesCubit, GamesState>(
        builder: (context, state) {
          if (state.isLoading && state.selectedGame == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final game = state.selectedGame;
          if (game == null) {
            return const Center(child: Text('Spiel nicht gefunden.'));
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _row('Spieler A', game.playerA.name),
                _row('Spieler B', game.playerB.name),
                const SizedBox(height: 8),
                _row('Tore', '${game.goalsA} : ${game.goalsB}'),
                const SizedBox(height: 8),
                _row('Gewinner', game.goalsA == game.goalsB ? 'Unentschieden' : (game.winner?.name ?? '–')),
                const SizedBox(height: 8),
                _row('Datum', Utils.formatDateTime(game.gamePlayedAt)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 120, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
