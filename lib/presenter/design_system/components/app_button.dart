import 'package:chord_master_app/presenter/design_system/components/pressable.dart';
import 'package:chord_master_app/presenter/design_system/tokens.dart';
import 'package:flutter/material.dart';

enum AppButtonVariant { primary, secondary, ghost, danger }

enum AppButtonSize { sm, md, lg }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.md,
    this.loading = false,
    this.expand = false,
  });

  const AppButton.secondary({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.size = AppButtonSize.md,
    this.loading = false,
    this.expand = false,
  }) : variant = AppButtonVariant.secondary;

  const AppButton.ghost({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.size = AppButtonSize.md,
    this.loading = false,
    this.expand = false,
  }) : variant = AppButtonVariant.ghost;

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool loading;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    final (Color bg, Color fg, Color? border) = switch (variant) {
      AppButtonVariant.primary => (c.accent, c.onAccent, null),
      AppButtonVariant.secondary => (c.surfaceAlt, c.text, c.border),
      AppButtonVariant.ghost => (Colors.transparent, c.text, null),
      AppButtonVariant.danger => (c.dangerSoft, c.danger, null),
    };

    final (double height, double hPad, double fontSize, double iconSize) = switch (size) {
      AppButtonSize.sm => (36.0, 12.0, 13.0, 16.0),
      AppButtonSize.md => (46.0, 18.0, 15.0, 18.0),
      AppButtonSize.lg => (54.0, 22.0, 16.0, 20.0),
    };

    final radius = BorderRadius.circular(size == AppButtonSize.sm ? AppRadius.sm : AppRadius.md);

    final content = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (loading)
          SizedBox(
            width: iconSize,
            height: iconSize,
            child: CircularProgressIndicator(strokeWidth: 2, color: fg),
          )
        else if (icon != null)
          Icon(icon, size: iconSize, color: fg),
        if (loading || icon != null) const SizedBox(width: AppSpace.xs),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.text.button.copyWith(color: fg, fontSize: fontSize),
          ),
        ),
      ],
    );

    return Pressable(
      onTap: loading ? null : onPressed,
      borderRadius: radius,
      child: AnimatedContainer(
        duration: AppDurations.normal,
        height: height,
        padding: EdgeInsets.symmetric(horizontal: hPad),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: radius,
          border: border != null ? Border.all(color: border) : null,
        ),
        child: content,
      ),
    );
  }
}

enum AppIconButtonVariant { ghost, soft, filled }

class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.variant = AppIconButtonVariant.ghost,
    this.size = 40,
    this.color,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final AppIconButtonVariant variant;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (Color bg, Color fg) = switch (variant) {
      AppIconButtonVariant.ghost => (Colors.transparent, color ?? c.text),
      AppIconButtonVariant.soft => (c.surfaceAlt, color ?? c.text),
      AppIconButtonVariant.filled => (c.accent, c.onAccent),
    };
    final radius = BorderRadius.circular(AppRadius.sm + 2);

    Widget button = Pressable(
      onTap: onPressed,
      pressedScale: 0.9,
      borderRadius: radius,
      semanticLabel: tooltip,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: bg, borderRadius: radius),
        alignment: Alignment.center,
        child: Icon(icon, size: size * 0.5, color: fg),
      ),
    );

    if (tooltip != null) button = Tooltip(message: tooltip!, child: button);
    return button;
  }
}
