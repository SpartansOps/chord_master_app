import 'package:chord_master_app/presenter/design_system/app_theme.dart';
import 'package:chord_master_app/presenter/resources/routes/app_router.dart';
import 'package:chord_master_app/presenter/state/settings_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChordMasterApp extends ConsumerWidget {
  const ChordMasterApp({super.key});

  static final _light = buildAppTheme(Brightness.light);
  static final _dark = buildAppTheme(Brightness.dark);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final darkMode = ref.watch(settingsProvider.select((s) => s.darkMode));
    return MaterialApp.router(
      title: 'Chord Master',
      debugShowCheckedModeBanner: false,
      theme: _light,
      darkTheme: _dark,
      themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,
      routerConfig: appRouter,
    );
  }
}
