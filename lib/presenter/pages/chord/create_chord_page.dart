import 'package:chord_master_app/app/di.dart';
import 'package:chord_master_app/domain/chord.dart';
import 'package:chord_master_app/presenter/pages/chord/chord_viewmodel.dart';
import 'package:chord_master_app/presenter/resources/field_validator.dart';
import 'package:chord_master_app/presenter/resources/widgets/admin_password_dialog.dart';
import 'package:chord_master_app/presenter/resources/widgets/custom_text_field.dart';
import 'package:chord_master_app/presenter/resources/widgets/snack_bar.dart';
import 'package:chord_master_app/presenter/resources/widgets/chord_content_viewer.dart';
import 'package:flutter/material.dart';

class CreateChordPage extends StatefulWidget {
  const CreateChordPage({super.key});

  @override
  State<CreateChordPage> createState() => _CreateChordPageState();
}

class _CreateChordPageState extends State<CreateChordPage> {
  final _viewModel = instance<ChordViewModel>();
  final TextEditingController _ctrlChordName = TextEditingController();
  final TextEditingController _ctrlChordNumber = TextEditingController();
  final TextEditingController _ctrlChordIntro = TextEditingController();
  final TextEditingController _ctrlChordLink = TextEditingController();
  final TextEditingController _ctrlChordContent = TextEditingController();
  final _formKeyStep1 = GlobalKey<FormState>();
  final _formKeyStep3 = GlobalKey<FormState>();

  int _currentStep = 0;

  @override
  void initState() {
    _viewModel.populateForm(
      _ctrlChordNumber,
      _ctrlChordName,
      _ctrlChordIntro,
      _ctrlChordContent,
      _ctrlChordLink,
    );
    if (!_viewModel.isInitialized) {
      _viewModel.isInitialized = true;
      _viewModel.getEvent.listen(
        (value) {
          switch (value) {
            case ChordEvent.creatingOrUpdating:
              break;
            case ChordEvent.errorCreateOrUpdate:
              if (!mounted) return;
              showSnackBar(context, content: _viewModel.getEventMessage, isError: true);
              break;
            case ChordEvent.successCreateOrUpdate:
              if (!mounted) return;
              showSnackBar(context, content: _viewModel.getEventMessage);
              Navigator.pop(context);
              break;
          }
        },
      );
    }

    super.initState();
  }

  @override
  void dispose() {
    _ctrlChordName.dispose();
    _ctrlChordNumber.dispose();
    _ctrlChordIntro.dispose();
    _ctrlChordLink.dispose();
    _ctrlChordContent.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (_formKeyStep1.currentState?.validate() ?? false) {
        setState(() => _currentStep = 1);
      }
    } else if (_currentStep == 1) {
      setState(() => _currentStep = 2);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _save() async {
    if (_formKeyStep3.currentState?.validate() ?? false) {
      FocusScope.of(context).unfocus();
      // A rota pode ser aberta direto pela URL na web, então valida de novo aqui
      if (!await ensureAdmin(context)) return;
      _viewModel.saveChord(
        _ctrlChordNumber,
        _ctrlChordName,
        _ctrlChordIntro,
        _ctrlChordContent,
        _ctrlChordLink,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = _viewModel.chord.id != null;

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        _ctrlChordName.clear();
        _ctrlChordNumber.clear();
        _ctrlChordIntro.clear();
        _ctrlChordLink.clear();
        _ctrlChordContent.clear();
        _viewModel.chord = Chord.empty();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(isEditing ? "Editar cifra" : "Nova cifra"),
        ),
        body: Column(
          children: [
            // Progress indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  _buildStepIndicator(0, 'Info', theme),
                  _buildStepLine(0, theme),
                  _buildStepIndicator(1, 'Link', theme),
                  _buildStepLine(1, theme),
                  _buildStepIndicator(2, 'Cifra', theme),
                ],
              ),
            ),

            // Step content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildCurrentStep(theme),
              ),
            ),

            // Navigation buttons
            Container(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _previousStep,
                        child: const Text('Voltar'),
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _currentStep == 2 ? _save : _nextStep,
                      child: Text(_currentStep == 2 ? 'Salvar' : 'Próximo'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label, ThemeData theme) {
    final isActive = _currentStep >= step;
    final isCurrent = _currentStep == step;

    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? theme.colorScheme.primary
                : theme.colorScheme.surfaceContainerHighest,
          ),
          child: Center(
            child: isActive
                ? Icon(
                    _currentStep > step ? Icons.check : Icons.circle,
                    size: 16,
                    color: Colors.white,
                  )
                : Text(
                    '${step + 1}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
            color: isActive
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(int step, ThemeData theme) {
    final isActive = _currentStep > step;

    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: isActive
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }

  Widget _buildCurrentStep(ThemeData theme) {
    switch (_currentStep) {
      case 0:
        return _buildStep1(theme);
      case 1:
        return _buildStep2(theme);
      case 2:
        return _buildStep3(theme);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStep1(ThemeData theme) {
    return Form(
      key: _formKeyStep1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informações da Música',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Comece pelo nome e número da música',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          CustomTextField(
            controller: _ctrlChordName,
            hint: 'Ex: Wonderwall',
            label: 'Nome da Música',
            validator: TextValidators.required,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _ctrlChordNumber,
            hint: 'Ex: 42',
            label: 'Número',
            textInputType: TextInputType.number,
            validator: (value) => TextValidators.combine(
              value,
              [TextValidators.required, TextValidators.onlyNumbers],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Introdução e Link',
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Esses campos são opcionais',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),
        CustomTextField(
          controller: _ctrlChordIntro,
          hint: 'Ex: Am F C G',
          label: 'Intro (Opcional)',
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _ctrlChordLink,
          hint: 'Ex: https://youtube.com/...',
          label: 'Link (YouTube, Spotify...)',
        ),
      ],
    );
  }

  Widget _buildStep3(ThemeData theme) {
    return Form(
      key: _formKeyStep3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Conteúdo da Cifra',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Digite a cifra da música abaixo',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          CustomTextField(
            controller: _ctrlChordContent,
            label: 'Cifra',
            hint: 'Am       F\nHello darkness my old friend...',
            maxLines: 15,
            validator: TextValidators.required,
          ),
          const SizedBox(height: 24),

          // Preview
          if (_ctrlChordContent.text.isNotEmpty) ...[
            Text(
              'Preview',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ChordContentViewer(
                intro: _ctrlChordIntro.text.isNotEmpty ? _ctrlChordIntro.text : null,
                content: _ctrlChordContent.text,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
