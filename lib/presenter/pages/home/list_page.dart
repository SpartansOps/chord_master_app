import 'package:chord_master_app/app/di.dart';
import 'package:chord_master_app/domain/chord.dart';
import 'package:chord_master_app/presenter/pages/home/home_viewmodel.dart';
import 'package:chord_master_app/presenter/resources/routes/routes_manager.dart';
import 'package:chord_master_app/presenter/resources/widgets/snack_bar.dart';
import 'package:flutter/material.dart';

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

          return SingleChildScrollView(
            child: ListView.builder(
              itemCount: chords.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.queue_music_rounded),
                  title: Text(
                    "${chords[index].chordName ?? "MÚSICA SEM NOME"} - ${chords[index].chordNumber?.toString() ?? "Nº"}",
                  ),
                  subtitle: (chords[index].chordLink ?? "").isEmpty
                      ? Container()
                      : Align(
                          alignment: Alignment.topLeft,
                          child: TextButton(
                            onPressed: () {},
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
                        showSnackBar(context, content: "Cifra removida da lista");
                      }
                    }
                  ),
                  onTap: () => Navigator.pushNamed(
                    context,
                    Routes.chord,
                    arguments: chords[index],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
