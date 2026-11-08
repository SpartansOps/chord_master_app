import 'package:chord_master_app/domain/chord.dart';
import 'package:chord_master_app/presenter/pages/chord/chord_editor_page.dart';
import 'package:chord_master_app/presenter/pages/chord/chord_page.dart';
import 'package:chord_master_app/presenter/pages/cifra_club/cifra_club_page.dart';
import 'package:chord_master_app/presenter/pages/library/library_page.dart';
import 'package:chord_master_app/presenter/pages/setlist/setlist_page.dart';
import 'package:chord_master_app/presenter/pages/shell/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

abstract class AppRoutes {
  static const library = '/';
  static const setlist = '/repertorio';
  static const newChord = '/nova';
  static const cifraClub = '/cifra-club';

  static String chord(String id) => '/cifra/${Uri.encodeComponent(id)}';
  static String editChord(String id) => '/cifra/${Uri.encodeComponent(id)}/editar';
  static String setlistItem(int index) => '/repertorio/$index';
}

final _rootKey = GlobalKey<NavigatorState>();

/// Biblioteca e Repertório ficam no shell (com navegação inferior);
/// as demais telas abrem por cima, em tela cheia.
final appRouter = GoRouter(
  navigatorKey: _rootKey,
  initialLocation: AppRoutes.library,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => AppShell(shell: shell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.library,
              builder: (_, __) => const LibraryPage(),
              routes: [
                GoRoute(
                  path: 'cifra/:id',
                  parentNavigatorKey: _rootKey,
                  builder: (_, state) => ChordPage.library(id: state.pathParameters['id']!),
                  routes: [
                    GoRoute(
                      path: 'editar',
                      parentNavigatorKey: _rootKey,
                      builder: (_, state) => ChordEditorPage(chordId: state.pathParameters['id']),
                    ),
                  ],
                ),
                GoRoute(
                  path: 'nova',
                  parentNavigatorKey: _rootKey,
                  builder: (_, state) => ChordEditorPage(prefill: state.extra as Chord?),
                ),
                GoRoute(
                  path: 'cifra-club',
                  parentNavigatorKey: _rootKey,
                  builder: (_, __) => const CifraClubPage(),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.setlist,
              builder: (_, __) => const SetlistPage(),
              routes: [
                GoRoute(
                  path: ':index',
                  parentNavigatorKey: _rootKey,
                  builder: (_, state) =>
                      ChordPage.setlist(index: int.tryParse(state.pathParameters['index']!) ?? -1),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);
