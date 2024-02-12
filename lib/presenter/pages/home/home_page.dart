import 'package:chord_master_app/app/constants.dart';
import 'package:chord_master_app/app/di.dart';
import 'package:chord_master_app/domain/chord.dart';
import 'package:chord_master_app/presenter/pages/home/home_viewmodel.dart';
import 'package:chord_master_app/presenter/resources/routes/routes_manager.dart';
import 'package:chord_master_app/presenter/resources/widgets/custom_text_field.dart';
import 'package:chord_master_app/presenter/resources/widgets/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

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
    _viewModel.getAllChords();
    _viewModel.getEvent.listen(
      (event) {
        if (event == HomeEvent.errorDownloadChords) {
          showSnackBar(context, content: _viewModel.getEventMessage);
        } else if (event == HomeEvent.downloadingChords) {
          showSnackBar(context, content: _viewModel.getEventMessage);
        } else if (event == HomeEvent.successDownload) {
          showSnackBar(context, content: _viewModel.getEventMessage);
        } else if (event == HomeEvent.showDialogPermissionStorage) {
          dialogPermissionStorage();
        } else if (event == HomeEvent.errorLoadChords) {
          showSnackBar(context, content: _viewModel.getEventMessage);
        } else if (event == HomeEvent.invalidFileType) {
          showSnackBar(context, content: _viewModel.getEventMessage);
        } else if (event == HomeEvent.fileNotSelected) {
          showSnackBar(context, content: _viewModel.getEventMessage);
        }
      },
    );

    super.initState();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Olá!'),
        actions: [
          IconButton(
            onPressed: () => _viewModel.pickFile(),
            icon: const Icon(Icons.file_download_rounded),
          ),
          IconButton(
            onPressed: () => Navigator.pushNamed(context, Routes.settings),
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CustomTextField(
              controller: _ctrlSearch,
              hint: 'Digite o nome ou o numero da música',
              onChanged: _viewModel.filterChords,
              suffixIcon: const Icon(Icons.search),
            ),
            const SizedBox(height: 16.0),
            StreamBuilder<List<Chord>>(
              initialData: const [],
              stream: _viewModel.chordsStream,
              builder: (context, snapshot) {
                List<Chord> chord = snapshot.data ?? [];
            
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
            
                if (chord.isEmpty) {
                  return Expanded(
                    child: Center(
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        children: [
                          Text(
                            'Nenhuma música encontrada',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          ElevatedButton(
                            onPressed: () => _viewModel.getAllChords(),
                            child: const Text('Clique para recarregar'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
            
                return Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
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
                          onSelected: (value) {
                            switch (value) {
                              case Constants.addListValue:
                                _viewModel.addChordList(chord[index]);
                                showSnackBar(context,
                                    content: "Cifra adicionada na lista");
                              default:
                                throw UnimplementedError(
                                    'Option not implemented!');
                            }
                          },
                          position: PopupMenuPosition.under,
                          itemBuilder: (BuildContext context) {
                            return [
                              const PopupMenuItem(
                                value: Constants.addListValue,
                                child: Text("Adicionar na lista"),
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
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, Routes.listChords),
        label: const Row(
          children: [
            Text('Lista'),
            SizedBox(width: 10),
            Icon(Icons.library_books)
          ],
        ),
      ),
    );
  }

  void dialogPermissionStorage() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Atenção"),
          content: const Text(
            "Para que o app funcione corretamente é necessário aceitar o uso de permissão de acesso aos diretórios do dispositivo.",
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                final value = await _viewModel.permissionService.requestPermissionStorage();
                if (value == PermissionStatus.granted) {
                  if (mounted) {
                    Navigator.pop(context);
                    await _viewModel.getAllChords();
                  }
                }
              },
              child: const Text("Prosseguir"),
            ),
          ],
        );
      },
    );
  }
}
