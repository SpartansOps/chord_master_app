import 'package:chord_master_app/app/di.dart';
import 'package:chord_master_app/presenter/pages/chord/chord_page.dart';
import 'package:chord_master_app/presenter/pages/chord/create_chord_page.dart';
import 'package:chord_master_app/presenter/pages/home/home_page.dart';
import 'package:chord_master_app/presenter/pages/home/list_page.dart';
import 'package:chord_master_app/presenter/pages/settings/settings_page.dart';
import 'package:flutter/material.dart';

abstract class Routes {
  static const String initial = '/';
  static const String home = '/';
  static const String listChords = '/listChords';
  static const String chord = '/chord';
  static const String settings = '/settings';
  static const String createOrUpdateChord = '/createOrUpdateChord';
}

class RouteManager {
  static Route getRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.home:
        initChordModule();
        initHomeModule();
        return MaterialPageRoute(builder: (_) => const MyHomePage());
      case Routes.chord:
        return MaterialPageRoute(
            builder: (_) => ChordPage(arguments: settings.arguments));
      case Routes.listChords:
        return MaterialPageRoute(builder: (_) => const ListChordPage());
      case Routes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsPage());
      case Routes.createOrUpdateChord:
        return MaterialPageRoute(builder: (_) => const CreateChordPage());
      default:
        return MaterialPageRoute(builder: (_) => const Scaffold());
    }
  }
}
