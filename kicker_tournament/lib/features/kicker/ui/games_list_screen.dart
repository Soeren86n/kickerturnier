import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kicker_tournament/features/kicker/cubit/games_cubit.dart';
import 'package:kicker_tournament/features/kicker/cubit/games_state.dart';
import 'package:kicker_tournament/features/kicker/models/game_models.dart';
import 'package:kicker_tournament/features/kicker/ui/game_detail_screen.dart';
import 'package:kicker_tournament/features/kicker/ui/new_game_screen.dart';
import 'package:kicker_tournament/utils/date_format_helper.dart';

class GamesListScreen extends StatelessWidget {
  static const route = '/';
  const GamesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spiele'),
        actions: [
          IconButton(
            tooltip: 'Rangliste',
            icon: const Icon(Icons.leaderboard),
            onPressed: () async {
              final cubit = context.read<GamesCubit>();
              await cubit.loadLeaderboard();
              if (!context.mounted) return;
              _showLeaderboard(context);
            },
          ),
          IconButton(
            tooltip: 'Aktualisieren',
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<GamesCubit>().initLoad(),
          ),
        ],
      ),
      body: BlocBuilder<GamesCubit, GamesState>(
        builder: (context, state) {
          if (state.isLoading && state.games.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.hasError) {
            return const Center(child: Text('Fehler beim Laden.'));
          }
          if (state.games.isEmpty) {
            return const Center(child: Text('Noch keine Spiele erfasst.'));
          }
          return ListView.separated(
            itemCount: state.games.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final game = state.games[index];
              return ListTile(
                title: Text('${game.playerA.name} ${game.goalsA} : ${game.goalsB} ${game.playerB.name}'),
                subtitle: Text(_subtitle(game)),
                onTap: () {
                  Navigator.pushNamed(context, GameDetailScreen.route, arguments: game.id);
                },
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    await context.read<GamesCubit>().deleteGameById(game.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Spiel gelöscht')),
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Neues Spiel'),
        onPressed: () => Navigator.pushNamed(context, NewGameScreen.route),
      ),
    );
  }

  String _subtitle(Game game) {
    if (game.goalsA == game.goalsB) return 'Unentschieden · ${Utils.formatDateTime(game.gamePlayedAt)}';
    final w = game.winner?.name ?? '–';
    return 'Gewinner: $w · ${Utils.formatDateTime(game.gamePlayedAt)}';
  }

  void _showLeaderboard(BuildContext context) {
    final state = context.read<GamesCubit>().state;
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) {
        final leaderBoard = state.leaderboard;
        if (leaderBoard.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Noch keine Teilnehmer oder Spiele vorhanden.'),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: leaderBoard.length,
          separatorBuilder: (_, __) => const Divider(height: 16),
          itemBuilder: (context, i) {
            final entry = leaderBoard[i];
            return ListTile(
              leading: CircleAvatar(child: Text('${i + 1}')),
              title: Text(entry.player.name),
              subtitle: Text(
                  'Siege: ${entry.wins} · Tordiff: ${entry.goalDifference} · Tore: ${entry.goalsScored}:${entry.goalsConceded} · Spiele: ${entry.gamesPlayed}'),
            );
          },
        );
      },
    );
  }
}
