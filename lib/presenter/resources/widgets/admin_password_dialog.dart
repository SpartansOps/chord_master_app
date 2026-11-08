import 'package:chord_master_app/app/di.dart';
import 'package:chord_master_app/app/services/admin_auth.dart';
import 'package:chord_master_app/presenter/resources/widgets/snack_bar.dart';
import 'package:flutter/material.dart';

/// Retorna true se o usuário já é admin ou digitou a senha correta.
Future<bool> ensureAdmin(BuildContext context) async {
  final auth = instance<AdminAuth>();
  if (auth.isAdmin) return true;

  final success = await showDialog<bool>(
        context: context,
        builder: (_) => const _AdminPasswordDialog(),
      ) ??
      false;

  if (!success && context.mounted) {
    showSnackBar(context,
        content: "Apenas o administrador pode fazer isso", isError: true);
  }
  return success;
}

class _AdminPasswordDialog extends StatefulWidget {
  const _AdminPasswordDialog();

  @override
  State<_AdminPasswordDialog> createState() => _AdminPasswordDialogState();
}

class _AdminPasswordDialogState extends State<_AdminPasswordDialog> {
  final TextEditingController _ctrlPassword = TextEditingController();
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _ctrlPassword.dispose();
    super.dispose();
  }

  void _submit() {
    if (instance<AdminAuth>().login(_ctrlPassword.text)) {
      Navigator.pop(context, true);
    } else {
      setState(() => _error = "Senha incorreta");
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Icon(Icons.lock_outline),
      title: const Text("Acesso de administrador"),
      content: TextField(
        controller: _ctrlPassword,
        autofocus: true,
        obscureText: _obscure,
        onSubmitted: (_) => _submit(),
        decoration: InputDecoration(
          labelText: "Senha admin",
          errorText: _error,
          suffixIcon: IconButton(
            icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
            onPressed: () => setState(() => _obscure = !_obscure),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text("Cancelar"),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text("Entrar"),
        ),
      ],
    );
  }
}
