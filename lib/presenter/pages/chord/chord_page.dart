import 'package:chord_master_app/app/di.dart';
import 'package:chord_master_app/domain/chord.dart';
import 'package:chord_master_app/presenter/pages/chord/chord_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:chord_master_app/domain/utils/chord_transposer.dart';
import 'package:chord_master_app/presenter/pages/home/home_viewmodel.dart';
import 'package:chord_master_app/presenter/resources/widgets/snack_bar.dart';
import 'package:chord_master_app/presenter/resources/widgets/chord_content_viewer.dart';

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
  bool _showYoutubePlayer = false;

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
    showSnackBar(context, content: "Cifra adicionada à lista!");
  }

  String _getNoteName(int shift) {
    final notes = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'];
    int index = shift % 12;
    if (index < 0) index += 12;
    return notes[index];
  }

  void _showOptionsSheet() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => StreamBuilder<double>(
          initialData: _viewModel.defaultFontSize,
          stream: _viewModel.fontSizeStream,
          builder: (context, snapshot) {
            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Tom
                  Row(
                    children: [
                      Icon(Icons.music_note, size: 20, color: primaryColor),
                      const SizedBox(width: 12),
                      const Text(
                        'Tom',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          setModalState(() => currentToneShift--);
                          setState(() {});
                        },
                        icon: const Icon(Icons.remove),
                        style: IconButton.styleFrom(
                          backgroundColor: isDark ? Colors.white12 : Colors.grey[100],
                        ),
                      ),
                      Container(
                        width: 70,
                        alignment: Alignment.center,
                        child: Text(
                          currentToneShift == 0
                              ? 'Original'
                              : '${currentToneShift > 0 ? '+' : ''}$currentToneShift (${_getNoteName(currentToneShift)})',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: currentToneShift != 0
                                ? primaryColor
                                : isDark
                                    ? Colors.white60
                                    : Colors.grey[600],
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setModalState(() => currentToneShift++);
                          setState(() {});
                        },
                        icon: const Icon(Icons.add),
                        style: IconButton.styleFrom(
                          backgroundColor: isDark ? Colors.white12 : Colors.grey[100],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Fonte
                  Row(
                    children: [
                      Icon(Icons.text_fields, size: 20, color: primaryColor),
                      const SizedBox(width: 12),
                      const Text(
                        'Fonte',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          _viewModel.decreaseFont();
                          setModalState(() {});
                        },
                        icon: const Icon(Icons.remove),
                        style: IconButton.styleFrom(
                          backgroundColor: isDark ? Colors.white12 : Colors.grey[100],
                        ),
                      ),
                      Container(
                        width: 50,
                        alignment: Alignment.center,
                        child: Text(
                          snapshot.data!.toStringAsFixed(1),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          _viewModel.increaseFont();
                          setModalState(() {});
                        },
                        icon: const Icon(Icons.add),
                        style: IconButton.styleFrom(
                          backgroundColor: isDark ? Colors.white12 : Colors.grey[100],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Margem
                  Row(
                    children: [
                      Icon(Icons.format_indent_increase, size: 20, color: primaryColor),
                      const SizedBox(width: 12),
                      const Text(
                        'Margem',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          _viewModel.decreaseMargin();
                          setModalState(() {});
                        },
                        icon: const Icon(Icons.remove),
                        style: IconButton.styleFrom(
                          backgroundColor: isDark ? Colors.white12 : Colors.grey[100],
                        ),
                      ),
                      Container(
                        width: 50,
                        alignment: Alignment.center,
                        child: Text(
                          _viewModel.defaultMargin.toStringAsFixed(0),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          _viewModel.increaseMargin();
                          setModalState(() {});
                        },
                        icon: const Icon(Icons.add),
                        style: IconButton.styleFrom(
                          backgroundColor: isDark ? Colors.white12 : Colors.grey[100],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Salvar
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                        _addToPlaylist();
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.playlist_add),
                      label: const Text('Salvar na Lista'),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            chord.chordName ?? "Cifra",
            style: const TextStyle(fontSize: 18),
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            if (_youtubeController != null)
              IconButton(
                tooltip: "Vídeo",
                icon: Icon(
                  _showYoutubePlayer ? Icons.close : Icons.play_circle_fill,
                ),
                onPressed: () {
                  setState(() {
                    _showYoutubePlayer = !_showYoutubePlayer;
                  });
                },
              ),
            IconButton(
              tooltip: "Opções",
              icon: const Icon(Icons.more_vert),
              onPressed: _showOptionsSheet,
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_showYoutubePlayer && _youtubeController != null)
                        Container(
                          width: double.infinity,
                          color: theme.colorScheme.surface,
                          child: Column(
                            children: [
                              YoutubePlayer(
                                controller: _youtubeController!,
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      StreamBuilder<double>(
                        initialData: _viewModel.defaultMargin,
                        stream: _viewModel.marginStream,
                        builder: (context, marginSnapshot) {
                          return Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: marginSnapshot.data!,
                            ),
                            child: ChordContentViewer(
                              intro: ChordTransposer.transposePlainText(
                                  chord.chordIntro ?? "", currentToneShift),
                              content: ChordTransposer.transposePlainText(
                                  chord.chordContent ?? "", currentToneShift),
                              fontSize: snapshot.data!,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            }),
      ),
    );
  }
}
