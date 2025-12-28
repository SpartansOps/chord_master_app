import 'package:chord_master_app/app/di.dart';
import 'package:chord_master_app/domain/chord.dart';
import 'package:chord_master_app/presenter/pages/chord/chord_viewmodel.dart';
import 'package:flutter/material.dart';

class ChordPage extends StatefulWidget {
  final dynamic arguments;
  const ChordPage({super.key, this.arguments});

  @override
  State<ChordPage> createState() => _ChordPageState();
}

class _ChordPageState extends State<ChordPage> {
  final _viewModel = instance<ChordViewModel>();

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Chord get chord => widget.arguments as Chord;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(),
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
                      (chord.chordIntro ?? "").isEmpty
                          ? const SizedBox()
                          : Text(
                              "INTRO: ${chord.chordIntro}",
                              style: TextStyle(
                                fontSize: snapshot.data,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                      Text(
                        chord.chordContent ?? "",
                        style: TextStyle(
                          fontSize: snapshot.data!,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
        floatingActionButton: FloatingActionButton.extended(
          heroTag: "fontSize",
          onPressed: () => showBottomSheetOptions(context),
          label: const Icon(Icons.more_horiz),
        ),
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
      builder: (context) => StreamBuilder<double>(
        initialData: _viewModel.defaultFontSize,
        stream: _viewModel.fontSizeStream,
        builder: (context, snapshot) {
          return SizedBox(
            height: 68,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      const Text('Tamanho'),
                      const Spacer(),
                      IconButton(
                        onPressed: _viewModel.decreaseFont,
                        icon: const Icon(
                          Icons.text_decrease,
                          size: 20,
                        ),
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
    );
  }
}
