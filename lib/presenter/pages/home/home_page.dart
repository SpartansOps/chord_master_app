import 'package:chord_master_app/app/di.dart';
import 'package:chord_master_app/domain/chord.dart';
import 'package:chord_master_app/presenter/pages/chord/chord_viewmodel.dart';
import 'package:chord_master_app/presenter/pages/home/home_viewmodel.dart';
import 'package:chord_master_app/presenter/pages/settings/settings_viewmodel.dart';
import 'package:chord_master_app/presenter/pages/cifra_club/cifra_club_page.dart';
import 'package:chord_master_app/presenter/resources/routes/routes_manager.dart';
import 'package:chord_master_app/presenter/resources/widgets/admin_password_dialog.dart';
import 'package:chord_master_app/presenter/resources/widgets/custom_text_field.dart';
import 'package:chord_master_app/presenter/resources/widgets/snack_bar.dart';
import 'package:chord_master_app/presenter/resources/widgets/speed_dial_fab.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _viewModel = instance<HomeViewModel>();
  final TextEditingController _ctrlSearch = TextEditingController();

  @override
  void initState() {
    _viewModel.refreshChords();
    if (!_viewModel.isInitialized) {
      _viewModel.isInitialized = true;
      _viewModel.getEvent.listen(
        (event) {
          if (event == HomeEvent.errorDownloadChords) {
            if (!mounted) return;
            showSnackBar(context, content: _viewModel.getEventMessage);
          } else if (event == HomeEvent.successDownload) {
            if (!mounted) return;
            showSnackBar(context, content: _viewModel.getEventMessage);
          }
        },
      );
    }

    super.initState();
  }

  void _openCifraClub(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CifraClubPage()),
    );
    if (result != null && result is Chord) {
      _viewModel.addChordList(result);
    }
  }

  Widget _buildStatCard(
      BuildContext context, String title, IconData icon, Stream<List<Chord>> stream) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        child: StreamBuilder<List<Chord>>(
          stream: stream,
          builder: (context, snapshot) {
            final count = snapshot.data?.length ?? 0;
            return Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      count.toString(),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4A6FA5), Color(0xFF7C9CC4)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.music_note, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chord Master',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
                Text(
                  'v1.2.1',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          StreamBuilder(
            stream: instance<SettingsViewModel>().settingsStream,
            builder: (context, snapshot) {
              final isDark = snapshot.data?.darkMode ?? false;
              return IconButton(
                icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                onPressed: () {
                  instance<SettingsViewModel>().setDarkMode(!isDark);
                },
              );
            },
          ),
          PopupMenuButton(
            position: PopupMenuPosition.under,
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  onTap: () => _viewModel.downloadChords(isDownload: true),
                  child: const Row(
                    children: [
                      Icon(Icons.cloud_download, size: 20),
                      SizedBox(width: 8),
                      Text("Atualizar"),
                    ],
                  ),
                ),
                PopupMenuItem(
                  onTap: () => _viewModel.refreshChords(),
                  child: const Row(
                    children: [
                      Icon(Icons.refresh, size: 20),
                      SizedBox(width: 8),
                      Text("Recarregar"),
                    ],
                  ),
                ),
              ];
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          children: [
            Row(
              children: [
                _buildStatCard(
                    context, "Músicas", Icons.music_note, _viewModel.unfilteredChordsStream),
                const SizedBox(width: 12),
                _buildStatCard(
                    context, "Na Lista", Icons.playlist_play, _viewModel.listChordsStream),
              ],
            ),
            const SizedBox(height: 16.0),
            CustomTextField(
              controller: _ctrlSearch,
              hint: 'Digite o nome ou número',
              onChanged: _viewModel.filterChords,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: const Icon(Icons.navigate_next),
            ),
            const SizedBox(height: 16.0),
            StreamBuilder(
              stream: _viewModel.getEvent,
              builder: (context, snapshotEvents) {
                if (snapshotEvents.data == HomeEvent.downloadingChords) {
                  return const LinearProgressIndicator();
                }

                return StreamBuilder(
                  stream: _viewModel.chordsStream,
                  builder: (context, snapshot) {
                    List<Chord> chord = snapshot.data ?? [];

                    if (chord.isEmpty) {
                      return Expanded(
                        child: Center(
                          child: Text(
                            'Nenhuma música encontrada',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      );
                    }

                    return Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.only(bottom: 80.0),
                        itemCount: chord.length,
                        itemBuilder: (context, index) {
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    chord[index].chordNumber?.toString() ?? "?",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.primary,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                              title: Text(
                                chord[index].chordName ?? "MÚSICA SEM NOME",
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: (chord[index].chordLink ?? "").isEmpty
                                  ? null
                                  : Text(
                                      chord[index].chordLink!,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                              trailing: PopupMenuButton(
                                position: PopupMenuPosition.under,
                                icon: Icon(
                                  Icons.more_vert,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                                itemBuilder: (BuildContext context) {
                                  return [
                                    PopupMenuItem(
                                      onTap: () {
                                        _viewModel.addChordList(chord[index]);
                                        showSnackBar(context,
                                            content: "Cifra adicionada na lista");
                                      },
                                      child: const Row(
                                        children: [
                                          Icon(Icons.playlist_add, size: 20),
                                          SizedBox(width: 8),
                                          Text("Adicionar na lista"),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      onTap: () async {
                                        // O menu já fechou aqui, então usa o context da página
                                        final pageContext = this.context;
                                        if (!await ensureAdmin(pageContext) ||
                                            !pageContext.mounted) {
                                          return;
                                        }
                                        instance<ChordViewModel>().chord =
                                            chord[index];
                                        Navigator.pushNamed(pageContext,
                                            Routes.createOrUpdateChord);
                                      },
                                      child: const Row(
                                        children: [
                                          Icon(Icons.edit_outlined, size: 20),
                                          SizedBox(width: 8),
                                          Text("Editar"),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      onTap: () {
                                        Clipboard.setData(ClipboardData(
                                            text: chord[index].chordContent ??
                                                ""));
                                        showSnackBar(context,
                                            content: "Cifra copiada!");
                                      },
                                      child: const Row(
                                        children: [
                                          Icon(Icons.copy, size: 20),
                                          SizedBox(width: 8),
                                          Text("Copiar"),
                                        ],
                                      ),
                                    ),
                                  ];
                                },
                              ),
                              onTap: () {
                                if ((chord[index].chordLink ?? "").contains("cifraclub.com.br")) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CifraClubPage(initialChord: chord[index]),
                                    ),
                                  );
                                } else {
                                  Navigator.pushNamed(
                                    context,
                                    Routes.chord,
                                    arguments: chord[index],
                                  );
                                }
                              },
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: SpeedDialFab(
        onAddChord: () async {
          if (!await ensureAdmin(context) || !context.mounted) return;
          Navigator.pushNamed(context, Routes.createOrUpdateChord);
        },
        onCifraClub: () => _openCifraClub(context),
        onOpenList: () => Navigator.pushNamed(context, Routes.listChords),
      ),
    );
  }
}
