import 'package:chord_master_app/app/di.dart';
import 'package:chord_master_app/domain/chord.dart';
import 'package:chord_master_app/presenter/pages/chord/chord_viewmodel.dart';
import 'package:chord_master_app/presenter/pages/home/home_viewmodel.dart';
import 'package:chord_master_app/presenter/pages/settings/settings_viewmodel.dart';
import 'package:chord_master_app/presenter/pages/cifra_club/cifra_club_page.dart';
import 'package:chord_master_app/presenter/resources/routes/routes_manager.dart';
import 'package:chord_master_app/presenter/resources/widgets/custom_text_field.dart';
import 'package:chord_master_app/presenter/resources/widgets/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

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
      BuildContext context, String title, Stream<List<Chord>> stream) {
    return Expanded(
      child: Card(
        elevation: 1,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: StreamBuilder<List<Chord>>(
            stream: stream,
            builder: (context, snapshot) {
              final count = snapshot.data?.length ?? 0;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    count.toString(),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ],
              );
            },
          ),
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
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6A00FF), Color(0xFF00C6FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child:
                  const Icon(Icons.music_note, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 10),
            const Text(
              'Chord Master',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'v1.2.1',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  onTap: () => _viewModel.downloadChords(isDownload: true),
                  child: const Row(
                    spacing: 8.0,
                    children: [Icon(Icons.cloud_download), Text("Atualizar")],
                  ),
                ),
                PopupMenuItem(
                  onTap: () => _viewModel.refreshChords(),
                  child: const Row(
                    spacing: 8.0,
                    children: [Icon(Icons.refresh), Text("Recarregar")],
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
                    context, "Músicas", _viewModel.unfilteredChordsStream),
                const SizedBox(width: 12),
                _buildStatCard(
                    context, "Na Lista", _viewModel.listChordsStream),
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
                        padding: const EdgeInsets.only(bottom: 48.0),
                        itemCount: chord.length,
                        itemBuilder: (context, index) {
                          return Card(
                            elevation: 1,
                            margin: const EdgeInsets.only(bottom: 8.0),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(Icons.queue_music,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer),
                              ),
                              title: Text(
                                "${chord[index].chordNumber?.toString() ?? "Nº"} - ${chord[index].chordName ?? "MÚSICA SEM NOME"}",
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: (chord[index].chordLink ?? "").isEmpty
                                  ? Container()
                                  : Align(
                                      alignment: Alignment.topLeft,
                                      child: TextButton(
                                        onPressed: () async {
                                          final urlString =
                                              chord[index].chordLink!;
                                          final uri = Uri.parse(
                                              urlString.startsWith('http')
                                                  ? urlString
                                                  : 'https://$urlString');
                                          if (await canLaunchUrl(uri)) {
                                            await launchUrl(uri,
                                                mode: LaunchMode
                                                    .externalApplication);
                                          } else {
                                            if (context.mounted) {
                                              showSnackBar(context,
                                                  content:
                                                      "Não foi possível abrir o link");
                                            }
                                          }
                                        },
                                        child: Text(
                                          chord[index].chordLink!,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                              trailing: PopupMenuButton(
                                position: PopupMenuPosition.under,
                                itemBuilder: (BuildContext context) {
                                  return [
                                    PopupMenuItem(
                                      onTap: () {
                                        _viewModel.addChordList(chord[index]);
                                        showSnackBar(context,
                                            content:
                                                "Cifra adicionada na lista");
                                      },
                                      child: const Text("Adicionar na lista"),
                                    ),
                                    PopupMenuItem(
                                      onTap: () {
                                        instance<ChordViewModel>().chord =
                                            chord[index];
                                        Navigator.pushNamed(context,
                                            Routes.createOrUpdateChord);
                                      },
                                      child: const Text("Editar"),
                                    ),
                                    PopupMenuItem(
                                      onTap: () {
                                        Clipboard.setData(ClipboardData(
                                            text: chord[index].chordContent ??
                                                ""));
                                      },
                                      child: const Text("Copiar"),
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
      floatingActionButton: Row(
        spacing: 8.0,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: "cifra",
            backgroundColor: Colors.orange.shade700,
            foregroundColor: Colors.white,
            onPressed: () => _openCifraClub(context),
            label: const Row(
              children: [Text('Cifra Club'), SizedBox(width: 5), Icon(Icons.my_library_music)],
            ),
          ),
          FloatingActionButton(
            heroTag: "add",
            onPressed: () =>
                Navigator.pushNamed(context, Routes.createOrUpdateChord),
            child: const Icon(Icons.add),
          ),
          FloatingActionButton.extended(
            heroTag: "list",
            onPressed: () => Navigator.pushNamed(context, Routes.listChords),
            label: const Row(
              children: [
                Text('Lista'),
                SizedBox(width: 10),
                Icon(Icons.library_books)
              ],
            ),
          ),
        ],
      ),
    );
  }
}
