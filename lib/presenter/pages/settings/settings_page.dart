import 'package:chord_master_app/app/di.dart';
import 'package:chord_master_app/domain/settings.dart';
import 'package:chord_master_app/presenter/pages/settings/settings_viewmodel.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _viewModel = instance<SettingsViewModel>();
  
  @override
  void initState() {
    _viewModel.init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<Settings>(
          stream: _viewModel.settingsStream,
          builder: (context, snapshot) {
            Settings settings = snapshot.data ?? Settings.empty();
            return Column(
              children: [
                ListTile(
                  title: const Text('Modo noturno'),
                  subtitle: const Text('Habilite/Desabilite o modo noturno'),
                  trailing: Switch(
                    value: settings.darkMode,
                    onChanged: _viewModel.setDarkMode,
                  ),
                ),
              ],
            );
          }
        ),
      ),
    );
  }
}
