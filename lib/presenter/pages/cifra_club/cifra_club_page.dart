import 'package:chord_master_app/app/providers.dart';
import 'package:chord_master_app/domain/chord.dart';
import 'package:chord_master_app/domain/utils/chord_markup.dart';
import 'package:chord_master_app/presenter/design_system/design_system.dart';
import 'package:chord_master_app/presenter/pages/chord/reader_widgets.dart';
import 'package:chord_master_app/presenter/resources/routes/app_router.dart';
import 'package:chord_master_app/presenter/resources/widgets/admin_password_dialog.dart';
import 'package:chord_master_app/presenter/resources/widgets/chord_content_viewer.dart';
import 'package:chord_master_app/presenter/state/setlist_state.dart';
import 'package:chord_master_app/presenter/state/settings_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Busca uma cifra no Cifra Club para pôr no repertório ou salvar na biblioteca.
class CifraClubPage extends ConsumerStatefulWidget {
  const CifraClubPage({super.key});

  @override
  ConsumerState<CifraClubPage> createState() => _CifraClubPageState();
}

class _CifraClubPageState extends ConsumerState<CifraClubPage> {
  final _artist = TextEditingController();
  final _song = TextEditingController();

  bool _loading = false;
  Chord? _fetched;
  String? _error;
  int _shift = 0;

  @override
  void dispose() {
    _artist.dispose();
    _song.dispose();
    super.dispose();
  }

  String _slug(String value) => value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '-');

  Future<void> _fetch() async {
    final artistInput = _artist.text.trim();
    String url;
    if (artistInput.contains('cifraclub.com.br')) {
      // Aceita colar o link direto
      url = artistInput.startsWith('http') ? artistInput : 'https://$artistInput';
    } else {
      final artist = _slug(artistInput);
      final song = _slug(_song.text);
      if (artist.isEmpty || song.isEmpty) {
        setState(() => _error = 'Preencha o artista e a música.');
        return;
      }
      url = 'https://www.cifraclub.com.br/$artist/$song/';
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _error = null;
      _shift = 0;
    });
    try {
      final chord = await ref.read(cifraClubScraperProvider).getChordFromUrl(url);
      if (mounted) setState(() => _fetched = chord);
    } catch (_) {
      if (mounted) setState(() => _error = 'Cifra não encontrada. Confira os nomes como aparecem no site.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _addToSetlist() {
    ref.read(setlistProvider.notifier).add(ChordMarkup.transpose(_fetched!, _shift));
    showToast(
      context,
      '${_fetched!.chordName} no repertório',
      actionLabel: 'Ver',
      onAction: () => context.go(AppRoutes.setlist),
    );
  }

  Future<void> _saveToLibrary() async {
    if (!await ensureAdmin(context) || !mounted) return;
    final transposed = ChordMarkup.transpose(_fetched!, _shift);
    context.push(
      AppRoutes.newChord,
      extra: Chord(
        chordName: transposed.chordName,
        chordLink: transposed.chordLink,
        chordContent: ChordMarkup.toPlainText(transposed.chordContent ?? ''),
        chordIntro: '',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fontSize = ref.watch(settingsProvider.select((s) => s.readerFontSize));
    final fetched = _fetched;

    return AppPage(
      maxWidth: 900,
      topBar: AppTopBar(
        showBack: true,
        maxWidth: 900 + 2 * AppSpace.gutter,
        title: 'Cifra Club',
        subtitle: 'Busque uma cifra para usar no app',
        actions: [
          if (fetched != null)
            AppIconButton(
              icon: AppIcons.readerSettings,
              tooltip: 'Ajustes de leitura',
              onPressed: () => showReaderSettingsSheet(context),
            ),
        ],
      ),
      bottomBar: fetched == null
          ? null
          : ReaderBottomBar(
              children: [
                ToneControl(
                  shift: _shift,
                  originalRoot: ChordMarkup.firstChordRoot(fetched),
                  onChanged: (v) => setState(() => _shift = v),
                ),
                const Spacer(),
                AppIconButton(
                  icon: AppIcons.save,
                  tooltip: 'Salvar na biblioteca (admin)',
                  variant: AppIconButtonVariant.soft,
                  size: 40,
                  onPressed: _saveToLibrary,
                ),
                const SizedBox(width: AppSpace.xs),
                AppButton(
                  label: 'Repertório',
                  icon: AppIcons.addToSetlist,
                  size: AppButtonSize.sm,
                  onPressed: _addToSetlist,
                ),
              ],
            ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _searchForm()),
          if (fetched == null)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                icon: AppIcons.search,
                title: 'Busque uma cifra',
                message: 'Digite o artista e a música como aparecem no site, ou cole o link no campo Artista.',
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.only(top: AppSpace.lg, bottom: AppSpace.xxl),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(fetched.chordName ?? 'Sem título', style: context.text.title),
                    const SizedBox(height: AppSpace.md),
                    ChordContentViewer(
                      content: ChordMarkup.transposeContent(fetched.chordContent ?? '', _shift),
                      fontSize: fontSize,
                      cifraClub: true,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _searchForm() {
    final c = context.colors;
    final fields = [
      AppTextField(
        controller: _artist,
        label: 'Artista',
        hint: 'Ex.: Aline Barros',
        textInputAction: TextInputAction.next,
      ),
      AppTextField(
        controller: _song,
        label: 'Música',
        hint: 'Ex.: Ressuscita-me',
        textInputAction: TextInputAction.search,
        onSubmitted: (_) => _fetch(),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.only(top: AppSpace.xxs),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (context.isWide)
              Row(
                children: [
                  Expanded(child: fields[0]),
                  const SizedBox(width: AppSpace.sm),
                  Expanded(child: fields[1]),
                ],
              )
            else ...[
              fields[0],
              const SizedBox(height: AppSpace.sm),
              fields[1],
            ],
            if (_error != null) ...[
              const SizedBox(height: AppSpace.sm),
              Row(
                children: [
                  Icon(AppIcons.error, size: 18, color: c.danger),
                  const SizedBox(width: AppSpace.xs),
                  Expanded(child: Text(_error!, style: context.text.caption.copyWith(color: c.danger))),
                ],
              ),
            ],
            const SizedBox(height: AppSpace.md),
            AppButton(
              label: 'Buscar',
              icon: AppIcons.search,
              loading: _loading,
              expand: true,
              onPressed: _fetch,
            ),
          ],
        ),
      ),
    );
  }
}
