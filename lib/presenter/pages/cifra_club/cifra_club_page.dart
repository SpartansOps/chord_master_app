import 'package:chord_master_app/data/api/cifra_club_scraper.dart';
import 'package:chord_master_app/domain/chord.dart';
import 'package:chord_master_app/domain/utils/chord_transposer.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CifraClubPage extends StatefulWidget {
  final Chord? initialChord;
  const CifraClubPage({super.key, this.initialChord});

  @override
  State<CifraClubPage> createState() => _CifraClubPageState();
}

class _CifraClubPageState extends State<CifraClubPage> {
  final scraper = CifraClubScraper();

  final TextEditingController artistController = TextEditingController();
  final TextEditingController songController = TextEditingController();

  bool isLoading = false;
  Chord? fetchedChord;
  String error = "";

  double fontSize = 16.0;
  int currentToneShift = 0;

  @override
  void initState() {
    super.initState();
    if (widget.initialChord != null) {
      fetchedChord = widget.initialChord;
    }
  }

  @override
  void dispose() {
    artistController.dispose();
    songController.dispose();
    super.dispose();
  }

  void fetchChord() async {
    final artist =
        artistController.text.trim().toLowerCase().replaceAll(' ', '-');
    final song = songController.text.trim().toLowerCase().replaceAll(' ', '-');

    if (artist.isEmpty || song.isEmpty) {
      setState(() => error = "Preencha o Artista e a Música");
      return;
    }

    setState(() {
      isLoading = true;
      error = "";
      currentToneShift = 0;
    });

    final url = "https://www.cifraclub.com.br/$artist/$song/";

    try {
      final chord = await scraper.getChordFromUrl(url);
      setState(() {
        fetchedChord = chord;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = "Letra não encontrada. Verifique o nome.";
        isLoading = false;
      });
    }
  }

  void increaseTone() {
    setState(() {
      currentToneShift += 1;
    });
  }

  void decreaseTone() {
    setState(() {
      currentToneShift -= 1;
    });
  }

  void increaseFont() {
    setState(() {
      fontSize += 2.0;
    });
  }

  void decreaseFont() {
    setState(() {
      if (fontSize > 8.0) {
        fontSize -= 2.0;
      }
    });
  }

  void saveToTodayList() {
    if (fetchedChord == null) return;

    // Creates a copy with the transposed html applied
    final chordToSave = fetchedChord!.copyWith(
        chordContent: ChordTransposer.transposeHtml(
            fetchedChord!.chordContent ?? "", currentToneShift));

    // We navigate back returning the chord to be added by the previous screen
    // or we can just pop it and handle it on home page.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Acorde ${chordToSave.chordName} selecionado!')),
    );
    Navigator.pop(context, chordToSave);
  }

  // Parse HTML format: "text <b>chord</b> text"
  List<TextSpan> _buildHtmlTextSpans(
      BuildContext context, String htmlContent, double size) {
    if (htmlContent.isEmpty) return [];

    // Cifra Club uses some HTML entities
    htmlContent = htmlContent
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"');

    // Convert <br> to newlines just in case they use it instead of \n
    htmlContent = htmlContent.replaceAll(
        RegExp(r'<br\s*/?>', caseSensitive: false), '\n');

    // Strip all HTML tags EXCEPT <b> and </b>
    htmlContent =
        htmlContent.replaceAll(RegExp(r'</?(?!b\b)[a-zA-Z0-9]+[^>]*>'), '');

    final regex = RegExp(r'<b>(.*?)</b>');
    final matches = regex.allMatches(htmlContent);

    final defaultStyle = GoogleFonts.robotoMono(
      fontSize: size,
      color: Theme.of(context).colorScheme.onSurface,
      height: 1.5,
    );

    final chordStyle = GoogleFonts.robotoMono(
      fontSize: size,
      color: Colors.orange.shade700,
      fontWeight: FontWeight.bold,
      height: 1.5,
    );

    List<TextSpan> spans = [];
    int lastMatchEnd = 0;

    for (final match in matches) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(
          text: htmlContent.substring(lastMatchEnd, match.start),
          style: defaultStyle,
        ));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: chordStyle,
      ));
      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < htmlContent.length) {
      spans.add(TextSpan(
        text: htmlContent.substring(lastMatchEnd),
        style: defaultStyle,
      ));
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    String contentToDisplay = fetchedChord?.chordContent ?? "";
    if (currentToneShift != 0 && contentToDisplay.isNotEmpty) {
      contentToDisplay =
          ChordTransposer.transposeHtml(contentToDisplay, currentToneShift);
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              child: TextButton.icon(
                onPressed: () => Navigator.pop(context),
                label: const Text("Voltar"),
                icon: const Icon(Icons.arrow_back),
              ),
            ),
            if (widget.initialChord == null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: artistController,
                        decoration: const InputDecoration(
                            labelText: "Artista",
                            isDense: true,
                            border: OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: songController,
                        decoration: const InputDecoration(
                            labelText: "Música",
                            isDense: true,
                            border: OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: isLoading ? null : fetchChord,
                      child: isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text("Buscar"),
                    )
                  ],
                ),
              ),
            if (error.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(error,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error)),
              ),
            Expanded(
                child: fetchedChord == null
                    ? const Center(
                        child: Text("Busque uma cifra para visualizar"))
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(fetchedChord!.chordName ?? "Sem Título",
                                style: TextStyle(
                                    fontSize: fontSize + 6,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            RichText(
                              text: TextSpan(
                                children: _buildHtmlTextSpans(
                                    context, contentToDisplay, fontSize),
                              ),
                            ),
                          ],
                        ),
                      )),
          ],
        ),
      ),
      bottomNavigationBar: fetchedChord == null
          ? null
          : BottomAppBar(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: decreaseTone,
                      ),
                      Text(
                          'Tom\n${currentToneShift > 0 ? '+$currentToneShift' : currentToneShift}',
                          textAlign: TextAlign.center),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: increaseTone,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.text_decrease),
                        onPressed: decreaseFont,
                      ),
                      const Text('Tamanho'),
                      IconButton(
                        icon: const Icon(Icons.text_increase),
                        onPressed: increaseFont,
                      ),
                    ],
                  ),
                  IconButton(
                    tooltip: "Adicionar à Lista",
                    icon: Icon(Icons.save_alt,
                        color: Theme.of(context).colorScheme.primary),
                    onPressed: saveToTodayList,
                  )
                ],
              ),
            ),
    );
  }
}
