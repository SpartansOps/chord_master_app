import 'package:chord_master_app/app/di.dart';
import 'package:chord_master_app/domain/chord.dart';
import 'package:chord_master_app/presenter/pages/chord/chord_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:chord_master_app/domain/utils/chord_transposer.dart';
import 'package:chord_master_app/presenter/pages/home/home_viewmodel.dart';
import 'package:chord_master_app/presenter/resources/widgets/snack_bar.dart';

class ChordPage extends StatefulWidget {
  final dynamic arguments;
  const ChordPage({super.key, this.arguments});

  @override
  State<ChordPage> createState() => _ChordPageState();
}

class _ChordPageState extends State<ChordPage> {
  final _viewModel = instance<ChordViewModel>();
  YoutubePlayerController? _youtubeController;
  int currentToneShift = 0;

  Chord get chord => widget.arguments as Chord;

  @override
  void initState() {
    super.initState();
    final link = chord.chordLink ?? "";
    if (link.contains("youtube.com") || link.contains("youtu.be")) {
      String? videoId = YoutubePlayerController.convertUrlToId(link);
      if (videoId != null) {
        _youtubeController = YoutubePlayerController.fromVideoId(
          videoId: videoId,
          autoPlay: false,
          params: const YoutubePlayerParams(
            showControls: true,
            showFullscreenButton: true,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _youtubeController?.close();
    super.dispose();
  }

  void _addToPlaylist() {
    final chordToSave = chord.copyWith(
      chordContent: ChordTransposer.transposePlainText(
          chord.chordContent ?? "", currentToneShift),
      chordIntro: ChordTransposer.transposePlainText(
          chord.chordIntro ?? "", currentToneShift),
    );
    instance<HomeViewModel>().addChordList(chordToSave);
    showSnackBar(context, content: "Cifra adicionada ao repertório na lista!");
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              tooltip: "Adicionar à Lista (mantém tom atual)",
              icon: const Icon(Icons.playlist_add),
              onPressed: _addToPlaylist,
            ),
            IconButton(
              tooltip: "Ajustes de Tom & Fonte",
              icon: const Icon(Icons.tune),
              onPressed: () => showBottomSheetOptions(context),
            ),
          ],
        ),
        body: StreamBuilder<double>(
            initialData: _viewModel.defaultFontSize,
            stream: _viewModel.fontSizeStream,
            builder: (context, snapshot) {
              return SizedBox(
                width: MediaQuery.of(context).size.width,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_youtubeController != null)
                        Theme(
                          data: Theme.of(context)
                              .copyWith(dividerColor: Colors.transparent),
                          child: ExpansionTile(
                            maintainState: true,
                            tilePadding: EdgeInsets.zero,
                            leading: Icon(Icons.smart_display,
                                color: Theme.of(context).colorScheme.primary),
                            title: const Text("Assistir Vídeo (YouTube)",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: YoutubePlayer(
                                  controller: _youtubeController!,
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      (chord.chordIntro ?? "").isEmpty
                          ? const SizedBox()
                          : Text(
                              "INTRO: ${ChordTransposer.transposePlainText(chord.chordIntro ?? "", currentToneShift)}",
                              style: TextStyle(
                                fontSize: snapshot.data,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                      Text(
                        ChordTransposer.transposePlainText(chord.chordContent ?? "", currentToneShift),
                        style: TextStyle(
                          fontSize: snapshot.data!,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
      ),
    );
  }

  void showBottomSheetOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => StreamBuilder<double>(
          initialData: _viewModel.defaultFontSize,
          stream: _viewModel.fontSizeStream,
          builder: (context, snapshot) {
            return SizedBox(
              height: 120,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        const Text('Tom'),
                        const Spacer(),
                        IconButton(
                          onPressed: () {
                            setModalState(() => currentToneShift--);
                            setState(() {}); 
                          },
                          icon: const Icon(Icons.remove, size: 20),
                        ),
                        Text('${currentToneShift > 0 ? '+' : ''}$currentToneShift'),
                        IconButton(
                          onPressed: () {
                            setModalState(() => currentToneShift++);
                            setState(() {});
                          },
                          icon: const Icon(Icons.add, size: 20),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text('Tamanho'),
                        const Spacer(),
                        IconButton(
                          onPressed: _viewModel.decreaseFont,
                          icon: const Icon(Icons.text_decrease, size: 20),
                        ),
                        Text(snapshot.data.toString()),
                        IconButton(
                          onPressed: _viewModel.increaseFont,
                          icon: const Icon(Icons.text_increase),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
