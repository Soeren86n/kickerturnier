import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kicker_tournament/features/kicker/ui/game_detail_screen.dart';
import 'package:kicker_tournament/features/kicker/ui/games_list_screen.dart';
import 'package:kicker_tournament/features/kicker/ui/new_game_screen.dart';

/// Centralized router configuration with type-safe routes.
///
/// Why: go_router provides declarative, URL-based navigation with type safety,
/// better deeplink support, and cleaner code than string-based Navigator.pushNamed.
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'games',
      builder: (context, state) => const GamesListScreen(),
    ),
    GoRoute(
      path: '/new',
      name: 'newGame',
      builder: (context, state) => const NewGameScreen(),
    ),
    GoRoute(
      path: '/game/:id',
      name: 'gameDetail',
      builder: (context, state) {
        final gameId = state.pathParameters['id']!;
        return GameDetailScreen(gameId: gameId);
      },
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('Fehler')),
    body: Center(
      child: Text('Seite nicht gefunden: ${state.uri}'),
    ),
  ),
);
