import 'package:chord_master_app/presenter/design_system/components/app_button.dart';
import 'package:chord_master_app/presenter/design_system/components/pressable.dart';
import 'package:chord_master_app/presenter/design_system/tokens.dart';
import 'package:flutter/material.dart';
import 'package:chord_master_app/presenter/design_system/app_icons.dart';

enum ToastTone { success, error, info }

/// Aviso curto flutuante (substitui o SnackBar padrão).
void showToast(
  BuildContext context,
  String message, {
  ToastTone tone = ToastTone.success,
  String? actionLabel,
  VoidCallback? onAction,
}) {
  final c = context.colors;
  final (IconData icon, Color color) = switch (tone) {
    ToastTone.success => (AppIcons.success, c.success),
    ToastTone.error => (AppIcons.error, c.danger),
    ToastTone.info => (AppIcons.info, c.accent),
  };
  final width = MediaQuery.sizeOf(context).width;
  final messenger = ScaffoldMessenger.of(context);

  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        padding: EdgeInsets.zero,
        behavior: SnackBarBehavior.floating,
        width: width > 520 ? 440 : null,
        duration: Duration(seconds: actionLabel != null ? 5 : 2),
        content: Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
          decoration: BoxDecoration(
            color: c.text,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: context.text.body.copyWith(color: c.background, fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
              if (actionLabel != null)
                Pressable(
                  onTap: () {
                    messenger.hideCurrentSnackBar();
                    onAction?.call();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: Text(actionLabel, style: context.text.button.copyWith(color: c.accent, fontSize: 14)),
                  ),
                )
              else
                const SizedBox(width: 6),
            ],
          ),
        ),
      ),
    );
}

/// Diálogo central com o visual do app.
Future<T?> showAppDialog<T>(BuildContext context, {required WidgetBuilder builder}) {
  final c = context.colors;
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Fechar',
    barrierColor: c.scrim,
    transitionDuration: AppDurations.normal,
    pageBuilder: (context, _, __) => SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.lg),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Material(
              color: c.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                side: BorderSide(color: c.border),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpace.lg),
                child: builder(context),
              ),
            ),
          ),
        ),
      ),
    ),
    transitionBuilder: (context, animation, _, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(scale: Tween(begin: 0.96, end: 1.0).animate(curved), child: child),
      );
    },
  );
}

/// Confirmação simples. Retorna true se o usuário confirmar.
Future<bool> confirmAction(
  BuildContext context, {
  required String title,
  String? message,
  String confirmLabel = 'Confirmar',
  bool destructive = false,
}) async {
  final result = await showAppDialog<bool>(
    context,
    builder: (context) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: context.text.title),
        if (message != null) ...[
          const SizedBox(height: AppSpace.xs),
          Text(message, style: context.text.bodyMuted),
        ],
        const SizedBox(height: AppSpace.lg),
        Row(
          children: [
            Expanded(
              child: AppButton.secondary(
                label: 'Cancelar',
                expand: true,
                onPressed: () => Navigator.pop(context, false),
              ),
            ),
            const SizedBox(width: AppSpace.sm),
            Expanded(
              child: AppButton(
                label: confirmLabel,
                expand: true,
                variant: destructive ? AppButtonVariant.danger : AppButtonVariant.primary,
                onPressed: () => Navigator.pop(context, true),
              ),
            ),
          ],
        ),
      ],
    ),
  );
  return result ?? false;
}

/// Painel que sobe da parte de baixo.
Future<T?> showAppSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  String? title,
}) {
  final c = context.colors;
  return showModalBottomSheet<T>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: c.scrim,
    elevation: 0,
    constraints: const BoxConstraints(maxWidth: 560),
    builder: (context) => Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.lg + 4)),
        border: Border(top: BorderSide(color: c.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpace.lg,
            AppSpace.sm,
            AppSpace.lg,
            AppSpace.lg + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: c.borderStrong,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                ),
              ),
              const SizedBox(height: AppSpace.md),
              if (title != null) ...[
                Text(title, style: context.text.subtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: AppSpace.md),
              ],
              builder(context),
            ],
          ),
        ),
      ),
    ),
  );
}

class SheetAction {
  const SheetAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;
}

/// Lista de ações num painel inferior (substitui PopupMenu).
Future<void> showActionSheet(
  BuildContext context, {
  String? title,
  required List<SheetAction> actions,
}) {
  return showAppSheet<void>(
    context,
    title: title,
    builder: (sheetContext) {
      final c = sheetContext.colors;
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final action in actions)
            Pressable(
              pressedScale: 0.98,
              onTap: () {
                Navigator.pop(sheetContext);
                action.onTap();
              },
              child: Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: AppSpace.xs),
                child: Row(
                  children: [
                    Icon(action.icon, size: 20, color: action.destructive ? c.danger : c.textMuted),
                    const SizedBox(width: AppSpace.md),
                    Text(
                      action.label,
                      style: sheetContext.text.body.copyWith(
                        fontWeight: FontWeight.w600,
                        color: action.destructive ? c.danger : c.text,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      );
    },
  );
}
