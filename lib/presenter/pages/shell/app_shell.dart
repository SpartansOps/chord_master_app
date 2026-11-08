import 'package:chord_master_app/presenter/design_system/design_system.dart';
import 'package:chord_master_app/presenter/state/setlist_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final setlistCount = ref.watch(setlistProvider.select((s) => s.length));
    return Scaffold(
      backgroundColor: context.colors.background,
      body: shell,
      bottomNavigationBar: AppBottomNav(
        currentIndex: shell.currentIndex,
        onTap: (i) => shell.goBranch(i, initialLocation: i == shell.currentIndex),
        items: [
          const AppNavItem(
            icon: AppIcons.music,
            activeIcon: AppIcons.musicActive,
            label: 'Músicas',
          ),
          AppNavItem(
            icon: AppIcons.setlist,
            activeIcon: AppIcons.setlistActive,
            label: 'Repertório',
            badge: setlistCount,
          ),
        ],
      ),
    );
  }
}
