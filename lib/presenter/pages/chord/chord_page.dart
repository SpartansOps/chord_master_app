import 'package:chord_master_app/domain/chord.dart';
import 'package:chord_master_app/domain/utils/chord_markup.dart';
import 'package:chord_master_app/presenter/design_system/design_system.dart';
import 'package:chord_master_app/presenter/pages/chord/reader_widgets.dart';
import 'package:chord_master_app/presenter/resources/routes/app_router.dart';
import 'package:chord_master_app/presenter/resources/widgets/chord_content_viewer.dart';
import 'package:chord_master_app/presenter/resources/widgets/link_launcher.dart';
import 'package:chord_master_app/presenter/state/library_state.dart';
import 'package:chord_master_app/presenter/state/setlist_state.dart';
import 'package:chord_master_app/presenter/state/settings_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

/// Leitura de uma cifra, vinda da biblioteca (por id) ou do repertório (por posição).
class ChordPage extends ConsumerStatefulWidget {
  const ChordPage.library({super.key, required String id})
      : chordId = id,
        setlistIndex = null;

  const ChordPage.setlist({super.key, required int index})
      : chordId = null,
        setlistIndex = index;

  final String? chordId;
  final int? setlistIndex;

  @override
  ConsumerState<ChordPage> createState() => _ChordPageState();
}

class _ChordPageState extends ConsumerState<ChordPage> {
  int _shift = 0;
  bool _showVideo = false;
  bool _videoChecked = false;
  YoutubePlayerController? _youtube;

  bool get _fromSetlist => widget.setlistIndex != null;

  @override
  void dispose() {
    _youtube?.close();
    super.dispose();
  }

  Chord? _resolveChord() {
    if (_fromSetlist) {
      final list = ref.watch(setlistProvider);
      final i = widget.setlistIndex!;
      return i >= 0 && i < list.length ? list[i] : null;
    }
    return findChordById(ref.watch(libraryProvider.select((s) => s.chords)), widget.chordId!);
  }

  void _setupVideo(Chord chord) {
    if (_videoChecked) return;
    _videoChecked = true;
    final link = chord.chordLink ?? '';
    if (!isYoutubeLink(link)) return;
    final videoId = YoutubePlayerController.convertUrlToId(link);
    if (videoId == null) return;
    _youtube = YoutubePlayerController.fromVideoId(
      videoId: videoId,
      autoPlay: false,
      params: const YoutubePlayerParams(showControls: true, showFullscreenButton: true),
    );
  }

  void _addToSetlist(Chord chord) {
    final setlist = ref.read(setlistProvider.notifier);
    setlist.add(ChordMarkup.transpose(chord, _shift));
    showToast(
      context,
      'Adicionada ao repertório',
      actionLabel: 'Ver',
      onAction: () => context.go(AppRoutes.setlist),
    );
  }

  void _saveToneInSetlist(Chord chord) {
    ref.read(setlistProvider.notifier).replaceAt(widget.setlistIndex!, ChordMarkup.transpose(chord, _shift));
    setState(() => _shift = 0);
    showToast(context, 'Tom salvo no repertório');
  }

  @override
  Widget build(BuildContext context) {
    final chord = _resolveChord();
    final settings = ref.watch(settingsProvider);

    if (chord == null) {
      return AppPage(
        topBar: AppTopBar(
          showBack: true,
          fallbackRoute: _fromSetlist ? AppRoutes.setlist : AppRoutes.library,
        ),
        body: EmptyState(
          icon: AppIcons.music,
          title: 'Cifra não encontrada',
          message: _fromSetlist
              ? 'Essa posição não existe mais no repertório.'
              : 'Ela pode ter sido removida, ou a biblioteca ainda não foi sincronizada.',
          action: AppButton.secondary(
            label: 'Voltar',
            onPressed: () => context.go(_fromSetlist ? AppRoutes.setlist : AppRoutes.library),
          ),
        ),
      );
    }

    _setupVideo(chord);
    final cifraClub = ChordMarkup.isCifraClub(chord);
    final shown = ChordMarkup.transpose(chord, _shift);
    final link = chord.chordLink ?? '';

    final subtitle = [
      if (chord.chordNumber != null) 'Nº ${chord.chordNumber}',
      if (_fromSetlist) 'Repertório · ${widget.setlistIndex! + 1}º',
    ].join(' · ');

    return AppPage(
      maxWidth: 900,
      padding: EdgeInsets.zero,
      topBar: AppTopBar(
        showBack: true,
        maxWidth: 900,
        fallbackRoute: _fromSetlist ? AppRoutes.setlist : AppRoutes.library,
        title: chord.chordName ?? 'Cifra',
        subtitle: subtitle.isEmpty ? null : subtitle,
        actions: [
          if (_youtube != null)
            AppIconButton(
              icon: _showVideo ? AppIcons.close : AppIcons.video,
              tooltip: _showVideo ? 'Fechar vídeo' : 'Ver vídeo',
              onPressed: () => setState(() => _showVideo = !_showVideo),
            )
          else if (link.isNotEmpty)
            AppIconButton(
              icon: AppIcons.externalLink,
              tooltip: 'Abrir link',
              onPressed: () => openExternalLink(context, link),
            ),
          AppIconButton(
            icon: AppIcons.readerSettings,
            tooltip: 'Ajustes de leitura',
            onPressed: () => showReaderSettingsSheet(context),
          ),
        ],
      ),
      bottomBar: ReaderBottomBar(
        children: [
          ToneControl(
            shift: _shift,
            originalRoot: ChordMarkup.firstChordRoot(chord),
            onChanged: (v) => setState(() => _shift = v),
          ),
          const Spacer(),
          if (!_fromSetlist)
            AppButton(
              label: 'Repertório',
              icon: AppIcons.addToSetlist,
              size: AppButtonSize.sm,
              onPressed: () => _addToSetlist(chord),
            )
          else if (_shift != 0)
            AppButton(
              label: 'Salvar tom',
              icon: AppIcons.check,
              size: AppButtonSize.sm,
              onPressed: () => _saveToneInSetlist(chord),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          AppSpace.xs + settings.readerMargin,
          AppSpace.xs,
          AppSpace.xs + settings.readerMargin,
          AppSpace.xxl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_showVideo && _youtube != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: YoutubePlayer(controller: _youtube!),
              ),
              const SizedBox(height: AppSpace.md),
            ],
            ChordContentViewer(
              intro: cifraClub ? null : shown.chordIntro,
              content: shown.chordContent,
              fontSize: settings.readerFontSize,
              cifraClub: cifraClub,
            ),
          ],
        ),
      ),
    );
  }
}
