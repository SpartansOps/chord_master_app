import 'package:chord_master_app/app/di.dart';
import 'package:chord_master_app/domain/settings.dart';
import 'package:chord_master_app/presenter/pages/settings/settings_viewmodel.dart';
import 'package:chord_master_app/presenter/resources/routes/routes_manager.dart';
import 'package:chord_master_app/presenter/resources/theme/app_theme.dart';
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: instance<SettingsViewModel>().settingsStream,
      builder: (context, snapshot) {
        return MaterialApp(
          title: 'Chord Master',
          theme: getApplicationTheme(snapshot.data ?? Settings.empty()),
          initialRoute: Routes.home,
          onGenerateRoute: RouteManager.getRoute,
        );
      },
    );
  }
}
