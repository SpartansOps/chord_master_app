import 'package:chord_master_app/domain/utils/chord_transposer.dart';
import 'package:chord_master_app/presenter/design_system/design_system.dart';
import 'package:chord_master_app/presenter/state/settings_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Barra inferior das telas de leitura (tom + ações).
class ReaderBottomBar extends StatelessWidget {
  const ReaderBottomBar({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        border: Border(top: BorderSide(color: c.border)),
      ),
      child: SafeArea(
        top: false,
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpace.sm, vertical: 10),
              child: Row(children: children),
            ),
          ),
        ),
      ),
    );
  }
}

/// Controle de transposição: − Tom +
class ToneControl extends StatelessWidget {
  const ToneControl({
    super.key,
    required this.shift,
    required this.onChanged,
    this.originalRoot,
  });

  final int shift;
  final ValueChanged<int> onChanged;

  /// Nota do primeiro acorde, para mostrar o tom resultante.
  final String? originalRoot;

  String get _valueLabel {
    final key = originalRoot == null ? null : ChordTransposer.transposeNote(originalRoot!, shift);
    if (shift == 0) return key == null ? 'Original' : 'Original · $key';
    final sign = shift > 0 ? '+' : '';
    return key == null ? '$sign$shift' : '$sign$shift · $key';
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppIconButton(
          icon: AppIcons.remove,
          tooltip: 'Meio tom abaixo',
          variant: AppIconButtonVariant.soft,
          size: 44,
          onPressed: () => onChanged(shift - 1),
        ),
        SizedBox(
          width: 104,
          child: Pressable(
            onTap: shift == 0 ? null : () => onChanged(0),
            semanticLabel: 'Voltar ao tom original',
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('TOM', style: context.text.label.copyWith(fontSize: 10)),
                const SizedBox(height: 2),
                Text(
                  _valueLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.number.copyWith(
                    fontSize: 14,
                    color: shift == 0 ? c.text : c.accent,
                  ),
                ),
              ],
            ),
          ),
        ),
        AppIconButton(
          icon: AppIcons.add,
          tooltip: 'Meio tom acima',
          variant: AppIconButtonVariant.soft,
          size: 44,
          onPressed: () => onChanged(shift + 1),
        ),
      ],
    );
  }
}

/// Ajustes de leitura (fonte e margem), salvos no aparelho.
Future<void> showReaderSettingsSheet(BuildContext context) {
  return showAppSheet<void>(
    context,
    title: 'Ajustes de leitura',
    builder: (_) => Consumer(
      builder: (context, ref, _) {
        final settings = ref.watch(settingsProvider);
        final notifier = ref.read(settingsProvider.notifier);
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppStepper(
              icon: AppIcons.fontSize,
              label: 'Tamanho da letra',
              value: settings.readerFontSize.toStringAsFixed(0),
              onDecrease: settings.readerFontSize > SettingsNotifier.minFontSize
                  ? () => notifier.changeFontSize(-1)
                  : null,
              onIncrease: settings.readerFontSize < SettingsNotifier.maxFontSize
                  ? () => notifier.changeFontSize(1)
                  : null,
            ),
            const SizedBox(height: AppSpace.md),
            AppStepper(
              icon: AppIcons.margin,
              label: 'Margem lateral',
              value: settings.readerMargin.toStringAsFixed(0),
              onDecrease: settings.readerMargin > 0
                  ? () => notifier.changeMargin(-SettingsNotifier.marginStep)
                  : null,
              onIncrease: settings.readerMargin < SettingsNotifier.maxMargin
                  ? () => notifier.changeMargin(SettingsNotifier.marginStep)
                  : null,
            ),
          ],
        );
      },
    ),
  );
}
