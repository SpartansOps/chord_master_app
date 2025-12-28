import 'package:chord_master_app/app/di.dart';
import 'package:chord_master_app/domain/chord.dart';
import 'package:chord_master_app/presenter/pages/chord/chord_viewmodel.dart';
import 'package:chord_master_app/presenter/pages/home/home_viewmodel.dart';
import 'package:chord_master_app/presenter/resources/routes/routes_manager.dart';
import 'package:chord_master_app/presenter/resources/widgets/custom_text_field.dart';
import 'package:chord_master_app/presenter/resources/widgets/snack_bar.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('Olá!'),
        actions: [
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
                PopupMenuItem(
                  onTap: () => Navigator.pushNamed(context, Routes.settings),
                  child: const Row(
                    spacing: 8.0,
                    children: [Icon(Icons.settings), Text("Configurações")],
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
            CustomTextField(
              controller: _ctrlSearch,
              hint: 'Digite o nome ou o numero da música',
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
                          return ListTile(
                            leading: const Icon(Icons.queue_music),
                            title: Text(
                              "${chord[index].chordNumber?.toString() ?? "Nº"} - ${chord[index].chordName ?? "MÚSICA SEM NOME"}",
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: (chord[index].chordLink ?? "").isEmpty
                                ? Container()
                                : Align(
                                    alignment: Alignment.topLeft,
                                    child: TextButton(
                                      onPressed: () {},
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
                                          content: "Cifra adicionada na lista");
                                    },
                                    child: const Text("Adicionar na lista"),
                                  ),
                                  PopupMenuItem(
                                    onTap: () {
                                      instance<ChordViewModel>().chord =
                                          chord[index];
                                      Navigator.pushNamed(
                                          context, Routes.createOrUpdateChord);
                                    },
                                    child: const Text("Editar"),
                                  ),
                                  PopupMenuItem(
                                    onTap: () {
                                      Clipboard.setData(ClipboardData(
                                          text:
                                              chord[index].chordContent ?? ""));
                                    },
                                    child: const Text("Copiar"),
                                  ),
                                ];
                              },
                            ),
                            onTap: () => Navigator.pushNamed(
                              context,
                              Routes.chord,
                              arguments: chord[index],
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
