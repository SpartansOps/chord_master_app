import 'package:chord_master_app/app/providers.dart';
import 'package:chord_master_app/presenter/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Retorna true se o usuário já é admin ou digitou a senha correta.
/// Senha errada é tratada dentro do diálogo; cancelar apenas retorna false.
Future<bool> ensureAdmin(BuildContext context) async {
  final auth = ProviderScope.containerOf(context, listen: false).read(adminAuthProvider);
  if (auth.isAdmin) return true;

  return await showAppDialog<bool>(context, builder: (_) => const _AdminPasswordForm()) ?? false;
}

class _AdminPasswordForm extends ConsumerStatefulWidget {
  const _AdminPasswordForm();

  @override
  ConsumerState<_AdminPasswordForm> createState() => _AdminPasswordFormState();
}

class _AdminPasswordFormState extends ConsumerState<_AdminPasswordForm> {
  final _ctrlPassword = TextEditingController();
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _ctrlPassword.dispose();
    super.dispose();
  }

  void _submit() {
    if (ref.read(adminAuthProvider).login(_ctrlPassword.text)) {
      Navigator.pop(context, true);
    } else {
      setState(() => _error = 'Senha incorreta');
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(color: c.accentSoft, borderRadius: BorderRadius.circular(AppRadius.md)),
          child: Icon(AppIcons.lock, color: c.accent, size: 22),
        ),
        const SizedBox(height: AppSpace.md),
        Text('Acesso de administrador', style: context.text.title),
        const SizedBox(height: AppSpace.xxs),
        Text('Criar e editar cifras exige a senha admin.', style: context.text.bodyMuted),
        const SizedBox(height: AppSpace.lg),
        AppTextField(
          controller: _ctrlPassword,
          hint: 'Senha',
          autofocus: true,
          obscureText: _obscure,
          errorText: _error,
          onSubmitted: (_) => _submit(),
          suffix: AppIconButton(
            icon: _obscure ? AppIcons.show : AppIcons.hide,
            tooltip: _obscure ? 'Mostrar senha' : 'Esconder senha',
            color: c.textMuted,
            onPressed: () => setState(() => _obscure = !_obscure),
          ),
        ),
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
            Expanded(child: AppButton(label: 'Entrar', expand: true, onPressed: _submit)),
          ],
        ),
      ],
    );
  }
}
