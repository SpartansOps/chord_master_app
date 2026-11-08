import 'package:chord_master_app/presenter/design_system/components/pressable.dart';
import 'package:chord_master_app/presenter/design_system/tokens.dart';
import 'package:flutter/material.dart';
import 'package:chord_master_app/presenter/design_system/app_icons.dart';

/// Superfície padrão (lista, blocos). Vira clicável se receber onTap.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.padding = const EdgeInsets.all(AppSpace.md),
    this.color,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsetsGeometry padding;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final radius = BorderRadius.circular(AppRadius.lg - 4);
    final box = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? c.surface,
        borderRadius: radius,
        border: Border.all(color: c.border),
      ),
      child: child,
    );
    if (onTap == null && onLongPress == null) return box;
    return Pressable(
      onTap: onTap,
      onLongPress: onLongPress,
      pressedScale: 0.985,
      borderRadius: radius,
      child: box,
    );
  }
}

/// Quadradinho com o número da música.
class NumberBadge extends StatelessWidget {
  const NumberBadge(this.value, {super.key, this.highlighted = false});

  final String value;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      constraints: const BoxConstraints(minWidth: 44),
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: highlighted ? c.accentSoft : c.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadius.sm + 2),
      ),
      child: Text(
        value,
        style: context.text.number.copyWith(color: highlighted ? c.accent : c.text),
      ),
    );
  }
}

/// Etiqueta pequena (ex.: "Cifra Club", "Vídeo").
class AppTag extends StatelessWidget {
  const AppTag(this.label, {super.key, this.icon, this.accent = false});

  final String label;
  final IconData? icon;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final fg = accent ? c.accent : c.textMuted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: accent ? c.accentSoft : c.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: fg),
            const SizedBox(width: 4),
          ],
          Text(label, style: context.text.caption.copyWith(fontSize: 11.5, color: fg)),
        ],
      ),
    );
  }
}

/// Botão em forma de "pílula" para ações rápidas (ex.: atalhos na home).
class AppChipButton extends StatelessWidget {
  const AppChipButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final radius = BorderRadius.circular(AppRadius.pill);
    return Pressable(
      onTap: onPressed,
      borderRadius: radius,
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: radius,
          border: Border.all(color: c.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: c.accent),
            const SizedBox(width: 6),
            Text(label, style: context.text.caption.copyWith(color: c.text)),
          ],
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpace.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: c.accentSoft,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Icon(icon, size: 30, color: c.accent),
            ),
            const SizedBox(height: AppSpace.md),
            Text(title, style: context.text.subtitle, textAlign: TextAlign.center),
            if (message != null) ...[
              const SizedBox(height: AppSpace.xs),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 320),
                child: Text(message!, style: context.text.bodyMuted, textAlign: TextAlign.center),
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: AppSpace.lg),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Controle "− valor +" usado nos ajustes de leitura.
class AppStepper extends StatelessWidget {
  const AppStepper({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.onDecrease,
    required this.onIncrease,
    this.highlighted = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onDecrease;
  final VoidCallback? onIncrease;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      children: [
        Icon(icon, size: 20, color: c.textMuted),
        const SizedBox(width: AppSpace.sm),
        Expanded(child: Text(label, style: context.text.subtitle)),
        _StepButton(icon: AppIcons.remove, onTap: onDecrease),
        SizedBox(
          width: 92,
          child: Text(
            value,
            textAlign: TextAlign.center,
            style: context.text.number.copyWith(
              fontSize: 14,
              color: highlighted ? c.accent : c.text,
            ),
          ),
        ),
        _StepButton(icon: AppIcons.add, onTap: onIncrease),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final radius = BorderRadius.circular(AppRadius.sm + 2);
    return Pressable(
      onTap: onTap,
      pressedScale: 0.9,
      borderRadius: radius,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(color: c.surfaceAlt, borderRadius: radius),
        child: Icon(icon, size: 20, color: c.text),
      ),
    );
  }
}

/// Alternador de duas ou mais opções (ex.: Editar | Visualizar).
class AppSegmented<T> extends StatelessWidget {
  const AppSegmented({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final T value;
  final Map<T, String> options;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: c.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          for (final entry in options.entries)
            Expanded(
              child: Pressable(
                onTap: () => onChanged(entry.key),
                pressedScale: 0.98,
                child: AnimatedContainer(
                  duration: AppDurations.normal,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: entry.key == value ? c.surface : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: entry.key == value ? Border.all(color: c.border) : null,
                  ),
                  child: Text(
                    entry.value,
                    style: context.text.caption.copyWith(
                      color: entry.key == value ? c.text : c.textMuted,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
