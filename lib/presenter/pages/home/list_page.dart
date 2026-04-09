import 'package:chord_master_app/app/di.dart';
import 'package:chord_master_app/domain/chord.dart';
import 'package:chord_master_app/presenter/pages/home/home_viewmodel.dart';
import 'package:chord_master_app/presenter/resources/routes/routes_manager.dart';
import 'package:chord_master_app/presenter/resources/widgets/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:chord_master_app/presenter/pages/cifra_club/cifra_club_page.dart';
import 'package:url_launcher/url_launcher.dart';

class ListChordPage extends StatefulWidget {
  const ListChordPage({super.key});

  @override
  State<ListChordPage> createState() => _ListChordPageState();
}

class _ListChordPageState extends State<ListChordPage> {
  final _viewModel = instance<HomeViewModel>();

  @override
  void initState() {
    _viewModel.getChordList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text("Lista de músicas"),
      ),
      body: StreamBuilder<List<Chord>>(
        initialData: const [],
        stream: _viewModel.listChordsStream,
        builder: (context, snapshot) {
          List<Chord> chords = snapshot.data ?? [];

          if (chords.isEmpty) {
            return Center(
              child: Text(
                'Nehuma música adicionada',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            );
          }

          return ReorderableListView.builder(
            buildDefaultDragHandles: false,
            itemCount: chords.length,
            onReorder: (oldIndex, newIndex) {
              _viewModel.reorderChordList(oldIndex, newIndex);
            },
            itemBuilder: (context, index) {
              return ListTile(
                key: ObjectKey(chords[index]),
                leading: ReorderableDragStartListener(
                  index: index,
                  child: const Icon(Icons.drag_handle),
                ),
                title: Text(
                  "${chords[index].chordName ?? "MÚSICA SEM NOME"} - ${chords[index].chordNumber?.toString() ?? "Nº"}",
                ),
                subtitle: (chords[index].chordLink ?? "").isEmpty
                    ? Container()
                    : Align(
                        alignment: Alignment.topLeft,
                        child: TextButton(
                          onPressed: () async {
                            final urlString = chords[index].chordLink!;
                            final uri = Uri.parse(urlString.startsWith('http') ? urlString : 'https://$urlString');
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri, mode: LaunchMode.externalApplication);
                            } else {
                              if (context.mounted) {
                                showSnackBar(context, content: "Não foi possível abrir o link");
                              }
                            }
                          },
                          child: Text(
                            chords[index].chordLink!,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                trailing: IconButton(
                    icon: const Icon(Icons.delete_outline_rounded),
                    onPressed: () async {
                      await _viewModel.deleteChordOfList(chords[index]);
                      if (mounted) {
                        showSnackBar(context,
                            content: "Cifra removida da lista");
                      }
                    }),
                onTap: () {
                  if ((chords[index].chordLink ?? "").contains("cifraclub.com.br")) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CifraClubPage(initialChord: chords[index]),
                      ),
                    );
                  } else {
                    Navigator.pushNamed(
                      context,
                      Routes.chord,
                      arguments: chords[index],
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
