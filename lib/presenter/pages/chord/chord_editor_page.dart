import 'dart:async';

import 'package:chord_master_app/app/providers.dart';
import 'package:chord_master_app/app/services/app_preferences.dart';
import 'package:chord_master_app/domain/chord.dart';
import 'package:chord_master_app/domain/utils/chord_markup.dart';
import 'package:chord_master_app/presenter/design_system/design_system.dart';
import 'package:chord_master_app/presenter/resources/field_validator.dart';
import 'package:chord_master_app/presenter/resources/routes/app_router.dart';
import 'package:chord_master_app/presenter/resources/widgets/admin_password_dialog.dart';
import 'package:chord_master_app/presenter/resources/widgets/chord_content_viewer.dart';
import 'package:chord_master_app/presenter/state/library_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';

enum _EditorTab { edit, preview }

/// Criar ou editar uma cifra numa tela só, com prévia ao vivo.
/// Cifra nova é salva como rascunho no aparelho enquanto você digita.
class ChordEditorPage extends ConsumerStatefulWidget {
  const ChordEditorPage({super.key, this.chordId, this.prefill});

  /// Editar uma cifra existente da biblioteca.
  final String? chordId;

  /// Começar uma cifra nova já preenchida (ex.: importada do Cifra Club).
  final Chord? prefill;

  @override
  ConsumerState<ChordEditorPage> createState() => _ChordEditorPageState();
}

class _ChordEditorPageState extends ConsumerState<ChordEditorPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _number = TextEditingController();
  final _intro = TextEditingController();
  final _link = TextEditingController();
  final _content = TextEditingController();

  Chord? _original;
  bool _notFound = false;
  bool _restoredDraft = false;
  bool _dirty = false;
  bool _saving = false;
  _EditorTab _tab = _EditorTab.edit;
  Timer? _draftTimer;
  late final AppPreferences _prefs;

  bool get _isEditing => widget.chordId != null;

  @override
  void initState() {
    super.initState();
    _prefs = ref.read(appPreferencesProvider);
    Chord? initial;
    if (_isEditing) {
      _original = findChordById(ref.read(libraryProvider).chords, widget.chordId!);
      _notFound = _original == null;
      initial = _original;
    } else if (widget.prefill != null) {
      initial = widget.prefill;
    } else {
      initial = _prefs.getDraft();
      _restoredDraft = initial != null;
    }
    if (initial != null) _fill(initial);

    for (final ctrl in [_name, _number, _intro, _link, _content]) {
      ctrl.addListener(_onChanged);
    }
  }

  void _fill(Chord chord) {
    _name.text = chord.chordName ?? '';
    _number.text = chord.chordNumber?.toString() ?? '';
    _intro.text = chord.chordIntro ?? '';
    _link.text = chord.chordLink ?? '';
    _content.text = ChordMarkup.toPlainText(chord.chordContent ?? '');
  }

  @override
  void dispose() {
    if (_draftTimer?.isActive ?? false) {
      _draftTimer!.cancel();
      _saveDraft();
    }
    for (final ctrl in [_name, _number, _intro, _link, _content]) {
      ctrl.dispose();
    }
    super.dispose();
  }

  void _onChanged() {
    if (!_isEditing) {
      _draftTimer?.cancel();
      _draftTimer = Timer(const Duration(milliseconds: 600), _saveDraft);
    }
    // Marca alteração e atualiza a prévia
    setState(() => _dirty = true);
  }

  bool get _hasContent => [_name, _number, _intro, _link, _content].any((c) => c.text.trim().isNotEmpty);

  void _saveDraft() {
    if (_hasContent) {
      _prefs.saveDraft(_current());
    } else {
      _prefs.clearDraft();
    }
  }

  Chord _current() => Chord(
        id: _original?.id,
        chordNumber: int.tryParse(_number.text.trim()),
        chordName: _name.text.trim(),
        chordIntro: _intro.text.trim(),
        chordContent: _content.text,
        chordLink: _link.text.trim(),
        sync: _original?.sync,
      );

  Future<void> _discardDraft() async {
    final ok = await confirmAction(
      context,
      title: 'Descartar rascunho?',
      message: 'O que você digitou será apagado.',
      confirmLabel: 'Descartar',
      destructive: true,
    );
    if (!ok) return;
    _draftTimer?.cancel();
    await _prefs.clearDraft();
    for (final ctrl in [_name, _number, _intro, _link, _content]) {
      ctrl.clear();
    }
    setState(() {
      _restoredDraft = false;
      _dirty = false;
    });
  }

  Future<void> _save() async {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) {
      // Campos obrigatórios ficam na aba de edição
      setState(() => _tab = _EditorTab.edit);
      showToast(context, 'Preencha nome, número e cifra', tone: ToastTone.error);
      return;
    }
    FocusScope.of(context).unfocus();
    // A rota pode ser aberta direto pela URL na web, então valida o admin aqui
    if (!await ensureAdmin(context) || !mounted) return;

    setState(() => _saving = true);
    try {
      final saved = await ref.read(chordRepositoryProvider).saveChord(_current());
      if (!mounted) return;
      if (saved == null) {
        showToast(context, 'A cifra não pôde ser gravada', tone: ToastTone.error);
        return;
      }
      await ref.read(libraryProvider.notifier).upsert(saved);
      if (!_isEditing) {
        _draftTimer?.cancel();
        await _prefs.clearDraft();
      }
      if (!mounted) return;
      _dirty = false;
      showToast(context, 'Cifra salva');
      if (_isEditing && context.canPop()) {
        context.pop();
      } else if (saved.id != null) {
        context.pushReplacement(AppRoutes.chord(saved.id!));
      } else {
        context.go(AppRoutes.library);
      }
    } on ClientException catch (e) {
      if (mounted) showToast(context, e.message, tone: ToastTone.error);
    } catch (_) {
      if (mounted) {
        showToast(context, 'Não foi possível gravar a cifra. Tente novamente.', tone: ToastTone.error);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  bool get _needsLeaveConfirm => _isEditing && _dirty && !_saving;

  Future<void> _leave() async {
    if (_needsLeaveConfirm) {
      final ok = await confirmAction(
        context,
        title: 'Descartar alterações?',
        message: 'As mudanças nesta cifra não foram salvas.',
        confirmLabel: 'Descartar',
        destructive: true,
      );
      if (!ok || !mounted) return;
      _dirty = false;
    }
    if (!mounted) return;
    context.canPop() ? context.pop() : context.go(AppRoutes.library);
  }

  @override
  Widget build(BuildContext context) {
    if (_notFound) {
      return AppPage(
        topBar: const AppTopBar(showBack: true, title: 'Editar cifra'),
        body: EmptyState(
          icon: AppIcons.music,
          title: 'Cifra não encontrada',
          message: 'Sincronize a biblioteca e tente de novo.',
          action: AppButton.secondary(label: 'Voltar', onPressed: () => context.go(AppRoutes.library)),
        ),
      );
    }

    final wide = context.isWide;

    return PopScope(
      canPop: !_needsLeaveConfirm,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _leave();
      },
      child: AppPage(
        maxWidth: wide ? 1200 : AppSpace.maxContentWidth,
        topBar: AppTopBar(
          showBack: true,
          onBack: _leave,
          maxWidth: (wide ? 1200 : AppSpace.maxContentWidth) + 2 * AppSpace.gutter,
          title: _isEditing ? 'Editar cifra' : 'Nova cifra',
          subtitle: _restoredDraft
              ? 'Rascunho restaurado'
              : (!_isEditing && _hasContent ? 'Rascunho salvo no aparelho' : null),
          actions: [
            if (_restoredDraft)
              AppButton.ghost(label: 'Descartar', size: AppButtonSize.sm, onPressed: _discardDraft),
            const SizedBox(width: AppSpace.xxs),
            AppButton(
              label: 'Salvar',
              icon: AppIcons.check,
              size: AppButtonSize.sm,
              loading: _saving,
              onPressed: _save,
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: wide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _fields()),
                    const SizedBox(width: AppSpace.lg),
                    Expanded(child: _preview()),
                  ],
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpace.xxs, bottom: AppSpace.sm),
                      child: AppSegmented<_EditorTab>(
                        value: _tab,
                        options: const {_EditorTab.edit: 'Editar', _EditorTab.preview: 'Prévia'},
                        onChanged: (t) {
                          FocusScope.of(context).unfocus();
                          setState(() => _tab = t);
                        },
                      ),
                    ),
                    // Offstage mantém os campos montados para a validação funcionar
                    Expanded(
                      child: Stack(
                        children: [
                          Offstage(offstage: _tab != _EditorTab.edit, child: _fields()),
                          Offstage(offstage: _tab != _EditorTab.preview, child: _preview()),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  bool get _cifraClubStyle => _link.text.contains('cifraclub.com.br');

  Widget _fields() {
    final c = context.colors;
    // Mesma fonte usada na leitura, para o alinhamento bater com o resultado
    final contentStyle = _cifraClubStyle
        ? GoogleFonts.robotoMono(fontSize: 15, height: 1.5, color: c.text)
        : GoogleFonts.roboto(fontSize: 16, height: 1.6, color: c.text);

    return ListView(
      padding: const EdgeInsets.only(top: AppSpace.xs, bottom: AppSpace.xxl),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AppTextField(
                controller: _name,
                label: 'Nome da música',
                hint: 'Ex.: Grande é o Senhor',
                textInputAction: TextInputAction.next,
                validator: TextValidators.required,
              ),
            ),
            const SizedBox(width: AppSpace.sm),
            SizedBox(
              width: 104,
              child: AppTextField(
                controller: _number,
                label: 'Número',
                hint: '42',
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                validator: (v) => TextValidators.combine(v, [TextValidators.required, TextValidators.onlyNumbers]),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpace.md),
        AppTextField(
          controller: _intro,
          label: 'Intro (opcional)',
          hint: 'Ex.: Am  F  C  G',
          style: GoogleFonts.roboto(fontSize: 16, color: c.text),
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: AppSpace.md),
        AppTextField(
          controller: _link,
          label: 'Link (opcional)',
          hint: 'YouTube, Spotify ou Cifra Club',
          helper: 'Vídeos do YouTube tocam dentro do app. Link do Cifra Club usa o visual de lá.',
          keyboardType: TextInputType.url,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: AppSpace.md),
        AppTextField(
          controller: _content,
          label: 'Cifra',
          hint: 'G           D\nGrande é o Senhor...',
          helper: 'Escreva os acordes numa linha própria, acima da letra. Essas linhas ficam destacadas.',
          minLines: 14,
          maxLines: null,
          style: contentStyle,
          validator: TextValidators.required,
        ),
      ],
    );
  }

  Widget _preview() {
    final chord = _current();
    final empty = (chord.chordContent ?? '').trim().isEmpty && (chord.chordIntro ?? '').trim().isEmpty;

    return ListView(
      padding: const EdgeInsets.only(top: AppSpace.xs, bottom: AppSpace.xxl),
      children: [
        if (context.isWide) ...[
          Text('PRÉVIA', style: context.text.label),
          const SizedBox(height: AppSpace.xs),
        ],
        AppCard(
          padding: const EdgeInsets.all(AppSpace.md),
          child: empty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpace.xl),
                  child: Text(
                    'A prévia aparece aqui enquanto você digita.',
                    textAlign: TextAlign.center,
                    style: context.text.bodyMuted,
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      [
                        if (chord.chordNumber != null) '${chord.chordNumber}.',
                        (chord.chordName ?? '').isEmpty ? 'Sem nome' : chord.chordName!,
                      ].join(' '),
                      style: context.text.title,
                    ),
                    const SizedBox(height: AppSpace.md),
                    ChordContentViewer(
                      intro: _cifraClubStyle ? null : chord.chordIntro,
                      content: chord.chordContent,
                      fontSize: 15,
                      cifraClub: _cifraClubStyle,
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}
