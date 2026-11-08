import 'package:chord_master_app/app/app_widget.dart';
import 'package:chord_master_app/app/di.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initAppModule();
  runApp(const MyApp());
}
