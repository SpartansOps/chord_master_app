import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;
import 'package:chord_master_app/domain/chord.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class CifraClubScraper {
  Future<Chord> getChordFromUrl(String url) async {
    try {
      String requestUrl = url;
      if (kIsWeb) {
        // corsproxy.io blocks some domains like netlify. We use allorigins instead.
        requestUrl = 'https://api.allorigins.win/raw?url=${Uri.encodeComponent(url)}';
      }
      final response = await http.get(Uri.parse(requestUrl));

      if (response.statusCode == 200) {
        final document = html_parser.parse(response.body);

        // Extract Title from h1
        final titleElement = document.querySelector('h1');
        String title = titleElement?.text.trim() ?? "Unknown Title";

        // Extract the chords pre wrapper
        // Usually Cifra club puts the chords inside a <pre> element
        final preElement = document.querySelector('pre');
        String content = "";

        if (preElement != null) {
          // We will extract the INNER HTML to preserve <b> tags.
          content = preElement.innerHtml;
        }

        return Chord(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          chordName: title,
          chordIntro:
              '', // Can be extracted if necessary but skipping for simplicity
          chordContent: content,
          chordLink: url,
          sync: false,
        );
      } else {
        throw Exception(
            "Failed to load Cifra Club page: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Scraping error: $e");
    }
  }
}
