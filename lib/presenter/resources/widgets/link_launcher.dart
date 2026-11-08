import 'package:chord_master_app/presenter/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

bool isYoutubeLink(String link) => link.contains('youtube.com') || link.contains('youtu.be');

/// Abre um link (YouTube, Spotify etc.) fora do app.
Future<void> openExternalLink(BuildContext context, String link) async {
  final uri = Uri.tryParse(link.startsWith('http') ? link : 'https://$link');
  if (uri != null && await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
    return;
  }
  if (context.mounted) {
    showToast(context, 'Não foi possível abrir o link', tone: ToastTone.error);
  }
}
