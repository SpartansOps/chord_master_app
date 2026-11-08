import 'package:chord_master_app/domain/chord.dart';
import 'package:chord_master_app/presenter/design_system/design_system.dart';
import 'package:chord_master_app/presenter/resources/routes/app_router.dart';
import 'package:chord_master_app/presenter/resources/widgets/link_launcher.dart';
import 'package:chord_master_app/presenter/state/setlist_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Repertório do culto: ordem das músicas, com arrastar para reordenar.
class SetlistPage extends ConsumerWidget {
  const SetlistPage({super.key});

  Future<void> _clear(BuildContext context, WidgetRef ref) async {
    final ok = await confirmAction(
      context,
      title: 'Limpar repertório?',
      message: 'Todas as músicas saem da lista. As cifras continuam na biblioteca.',
      confirmLabel: 'Limpar',
      destructive: true,
    );
    if (ok) ref.read(setlistProvider.notifier).clear();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(setlistProvider);

    return AppPage(
      topBar: AppTopBar(
        title: 'Repertório',
        subtitle: switch (list.length) {
          0 => 'Nenhuma música',
          1 => '1 música',
          final n => '$n músicas',
        },
        actions: [
          if (list.isNotEmpty)
            AppIconButton(
              icon: AppIcons.trash,
              tooltip: 'Limpar repertório',
              onPressed: () => _clear(context, ref),
            ),
        ],
      ),
      body: list.isEmpty
          ? EmptyState(
              icon: AppIcons.setlist,
              title: 'Repertório vazio',
              message: 'Monte a lista do culto adicionando músicas da biblioteca ou do Cifra Club.',
              action: AppButton(
                label: 'Ver músicas',
                icon: AppIcons.music,
                onPressed: () => context.go(AppRoutes.library),
              ),
            )
          : ReorderableListView.builder(
              buildDefaultDragHandles: false,
              padding: const EdgeInsets.only(top: AppSpace.xxs, bottom: AppSpace.lg),
              itemCount: list.length,
              onReorderItem: ref.read(setlistProvider.notifier).move,
              proxyDecorator: (child, _, __) => Material(type: MaterialType.transparency, child: child),
              itemBuilder: (_, i) => Padding(
                key: ObjectKey(list[i]),
                padding: const EdgeInsets.only(bottom: AppSpace.xs),
                child: _SetlistTile(index: i, chord: list[i]),
              ),
            ),
    );
  }
}

class _SetlistTile extends ConsumerWidget {
  const _SetlistTile({required this.index, required this.chord});

  final int index;
  final Chord chord;

  void _remove(BuildContext context, WidgetRef ref) {
    final setlist = ref.read(setlistProvider.notifier);
    setlist.removeAt(index);
    showToast(
      context,
      'Removida do repertório',
      actionLabel: 'Desfazer',
      onAction: () => setlist.insertAt(index, chord),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final link = chord.chordLink ?? '';

    return AppCard(
      padding: const EdgeInsets.fromLTRB(AppSpace.xxs, AppSpace.sm, AppSpace.xxs, AppSpace.sm),
      onTap: () => context.push(AppRoutes.setlistItem(index)),
      child: Row(
        children: [
          ReorderableDragStartListener(
            index: index,
            child: MouseRegion(
              cursor: SystemMouseCursors.grab,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpace.xs, vertical: AppSpace.sm),
                child: Icon(AppIcons.dragHandle, size: 20, color: c.textFaint),
              ),
            ),
          ),
          NumberBadge('${index + 1}', highlighted: true),
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
                if (chord.chordNumber != null) ...[
                  const SizedBox(height: 2),
                  Text('Nº ${chord.chordNumber}', style: context.text.caption),
                ],
              ],
            ),
          ),
          if (link.isNotEmpty)
            AppIconButton(
              icon: isYoutubeLink(link) ? AppIcons.video : AppIcons.externalLink,
              tooltip: 'Abrir link',
              color: c.textMuted,
              onPressed: () => openExternalLink(context, link),
            ),
          AppIconButton(
            icon: AppIcons.close,
            tooltip: 'Remover do repertório',
            color: c.textMuted,
            onPressed: () => _remove(context, ref),
          ),
        ],
      ),
    );
  }
}
