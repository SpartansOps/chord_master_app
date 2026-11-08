import 'package:chord_master_app/domain/chord.dart';
import 'package:chord_master_app/domain/utils/chord_markup.dart';
import 'package:chord_master_app/presenter/design_system/design_system.dart';
import 'package:chord_master_app/presenter/resources/routes/app_router.dart';
import 'package:chord_master_app/presenter/resources/widgets/admin_password_dialog.dart';
import 'package:chord_master_app/presenter/resources/widgets/link_launcher.dart';
import 'package:chord_master_app/presenter/state/library_state.dart';
import 'package:chord_master_app/presenter/state/setlist_state.dart';
import 'package:chord_master_app/presenter/state/settings_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Tela inicial: todas as músicas, com busca.
class LibraryPage extends ConsumerStatefulWidget {
  const LibraryPage({super.key});

  @override
  ConsumerState<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends ConsumerState<LibraryPage> {
  late final TextEditingController _search =
      TextEditingController(text: ref.read(searchQueryProvider));

  @override
  void initState() {
    super.initState();
    // Primeira abertura (sem cópia local): baixa da API automaticamente.
    if (ref.read(libraryProvider).chords.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _sync());
    }
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _sync() async {
    final result = await ref.read(libraryProvider.notifier).sync();
    if (!mounted) return;
    showToast(context, result.message, tone: result.ok ? ToastTone.success : ToastTone.error);
  }

  Future<void> _newChord() async {
    if (!await ensureAdmin(context) || !mounted) return;
    context.push(AppRoutes.newChord);
  }

  void _clearSearch() {
    _search.clear();
    ref.read(searchQueryProvider.notifier).set('');
  }

  @override
  Widget build(BuildContext context) {
    final library = ref.watch(libraryProvider);
    final chords = ref.watch(filteredLibraryProvider);
    final query = ref.watch(searchQueryProvider);
    final darkMode = ref.watch(settingsProvider.select((s) => s.darkMode));
    final c = context.colors;

    return AppPage(
      topBar: AppTopBar(
        leading: const AppLogo(size: 36),
        title: 'Chord Master',
        subtitle: library.syncing ? 'Sincronizando…' : '${library.chords.length} músicas',
        actions: [
          AppIconButton(
            icon: darkMode ? AppIcons.sun : AppIcons.moon,
            tooltip: darkMode ? 'Tema claro' : 'Tema escuro',
            onPressed: ref.read(settingsProvider.notifier).toggleDarkMode,
          ),
          AppIconButton(
            icon: AppIcons.sync,
            tooltip: 'Sincronizar com o servidor',
            onPressed: library.syncing ? null : _sync,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpace.xxs),
          AppTextField(
            controller: _search,
            hint: 'Buscar por nome ou número',
            prefixIcon: AppIcons.search,
            textInputAction: TextInputAction.search,
            onChanged: ref.read(searchQueryProvider.notifier).set,
            suffix: query.isEmpty
                ? null
                : AppIconButton(
                    icon: AppIcons.close,
                    tooltip: 'Limpar busca',
                    size: 36,
                    color: c.textMuted,
                    onPressed: _clearSearch,
                  ),
          ),
          const SizedBox(height: AppSpace.sm),
          Wrap(
            spacing: AppSpace.xs,
            runSpacing: AppSpace.xs,
            children: [
              AppChipButton(label: 'Nova cifra', icon: AppIcons.add, onPressed: _newChord),
              AppChipButton(
                label: 'Importar do Cifra Club',
                icon: AppIcons.import,
                onPressed: () => context.push(AppRoutes.cifraClub),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.sm),
          AnimatedSwitcher(
            duration: AppDurations.normal,
            child: library.syncing
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    child: const LinearProgressIndicator(minHeight: 3),
                  )
                : const SizedBox(height: 3),
          ),
          const SizedBox(height: AppSpace.xs),
          Expanded(
            child: chords.isEmpty
                ? _empty(query, library)
                : ListView.separated(
                    padding: const EdgeInsets.only(bottom: AppSpace.lg),
                    itemCount: chords.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AppSpace.xs),
                    itemBuilder: (_, i) => _ChordTile(chord: chords[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _empty(String query, LibraryState library) {
    if (query.isNotEmpty) {
      return EmptyState(
        icon: AppIcons.search,
        title: 'Nada encontrado',
        message: 'Nenhuma música com "$query". Tente outro nome ou número.',
        action: AppButton.secondary(label: 'Limpar busca', onPressed: _clearSearch),
      );
    }
    if (library.syncing) return const SizedBox.shrink();
    return EmptyState(
      icon: AppIcons.music,
      title: 'Nenhuma música por aqui',
      message: 'Sincronize para baixar as cifras do servidor. Depois elas ficam disponíveis offline.',
      action: AppButton(
        label: 'Sincronizar',
        icon: AppIcons.sync,
        onPressed: _sync,
      ),
    );
  }
}

class _ChordTile extends ConsumerWidget {
  const _ChordTile({required this.chord});

  final Chord chord;

  void _addToSetlist(BuildContext context, WidgetRef ref) {
    final setlist = ref.read(setlistProvider.notifier);
    setlist.add(chord);
    final index = ref.read(setlistProvider).length - 1;
    showToast(
      context,
      '${chord.chordName ?? 'Música'} no repertório',
      actionLabel: 'Desfazer',
      onAction: () => setlist.removeAt(index),
    );
  }

  Future<void> _edit(BuildContext context) async {
    if (chord.id == null) return;
    if (!await ensureAdmin(context) || !context.mounted) return;
    context.push(AppRoutes.editChord(chord.id!));
  }

  void _copy(BuildContext context) {
    Clipboard.setData(ClipboardData(text: ChordMarkup.toPlainText(chord.chordContent ?? '')));
    showToast(context, 'Cifra copiada');
  }

  void _showActions(BuildContext context, WidgetRef ref) {
    showActionSheet(
      context,
      title: chord.chordName,
      actions: [
        SheetAction(
          icon: AppIcons.addToSetlist,
          label: 'Adicionar ao repertório',
          onTap: () => _addToSetlist(context, ref),
        ),
        SheetAction(icon: AppIcons.edit, label: 'Editar', onTap: () => _edit(context)),
        SheetAction(icon: AppIcons.copy, label: 'Copiar cifra', onTap: () => _copy(context)),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final link = chord.chordLink ?? '';
    final hasTags = ChordMarkup.isCifraClub(chord) || isYoutubeLink(link);

    return AppCard(
      padding: const EdgeInsets.fromLTRB(AppSpace.sm, AppSpace.sm, AppSpace.xxs, AppSpace.sm),
      onTap: chord.id == null ? null : () => context.push(AppRoutes.chord(chord.id!)),
      onLongPress: () => _showActions(context, ref),
      child: Row(
        children: [
          NumberBadge(chord.chordNumber?.toString() ?? '–'),
          const SizedBox(width: AppSpace.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chord.chordName ?? 'Música sem nome',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.subtitle.copyWith(fontSize: 15),
                ),
                if (hasTags) ...[
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    children: [
                      if (ChordMarkup.isCifraClub(chord)) const AppTag('Cifra Club'),
                      if (isYoutubeLink(link)) const AppTag('Vídeo', icon: AppIcons.video),
                    ],
                  ),
                ],
              ],
            ),
          ),
          AppIconButton(
            icon: AppIcons.addToSetlist,
            tooltip: 'Adicionar ao repertório',
            color: context.colors.textMuted,
            onPressed: () => _addToSetlist(context, ref),
          ),
          AppIconButton(
            icon: AppIcons.more,
            tooltip: 'Mais opções',
            color: context.colors.textMuted,
            onPressed: () => _showActions(context, ref),
          ),
        ],
      ),
    );
  }
}
