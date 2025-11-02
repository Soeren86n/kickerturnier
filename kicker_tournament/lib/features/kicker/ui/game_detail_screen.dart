import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kicker_tournament/features/kicker/cubit/games_cubit.dart';
import 'package:kicker_tournament/features/kicker/cubit/games_state.dart';
import 'package:kicker_tournament/utils/date_format_helper.dart';

class GameDetailScreen extends StatefulWidget {
  const GameDetailScreen({super.key, required this.gameId});

  final String gameId;

  @override
  State<GameDetailScreen> createState() => _GameDetailScreenState();
}

class _GameDetailScreenState extends State<GameDetailScreen> {
  bool _requested = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_requested) return;
    _requested = true;
    context.read<GamesCubit>().selectGameById(widget.gameId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Spiel-Details')),
      body: BlocBuilder<GamesCubit, GamesState>(
        builder: (context, state) {
          final status = state.selectedGameStatus;
          final game = state.selectedGame;
          final isCurrentGame = game?.id == widget.gameId;

          if (status.isLoading && !isCurrentGame) {
            return const Center(child: CircularProgressIndicator());
          }
          if (status.isFailure) {
            return Center(
              child: Text(status.message ?? 'Spiel konnte nicht geladen werden.'),
            );
          }
          if (game == null || !isCurrentGame) {
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
