import 'package:chord_master_app/app/di.dart';
import 'package:chord_master_app/domain/chord.dart';
import 'package:chord_master_app/presenter/pages/chord/chord_viewmodel.dart';
import 'package:chord_master_app/presenter/resources/field_validator.dart';
import 'package:chord_master_app/presenter/resources/widgets/custom_text_field.dart';
import 'package:chord_master_app/presenter/resources/widgets/snack_bar.dart';
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
  final _formKey = GlobalKey<FormState>();

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
              showSnackBar(context, content: _viewModel.getEventMessage);
              break;
            case ChordEvent.successCreateOrUpdate:
              if (!mounted) return;
              showSnackBar(context, content: _viewModel.getEventMessage);
              break;
          }
        },
      );
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
          title: Text(
            _viewModel.chord.id == null ? "Criar nova cifra" : "Editar cifra",
          ),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              CustomTextField(
                controller: _ctrlChordName,
                hint: 'Digite o nome da música',
                label: 'Nome',
                validator: TextValidators.required,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _ctrlChordNumber,
                hint: 'Digite o número da música',
                label: 'Número',
                textInputType: TextInputType.number,
                validator: (value) => TextValidators.combine(
                  value,
                  [
                    TextValidators.required,
                    TextValidators.onlyNumbers,
                  ],
                ),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _ctrlChordIntro,
                hint: 'Digite a introdução da música',
                label: 'INTRO (Opcional)',
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _ctrlChordLink,
                hint: 'Insira o link da música',
                label: 'Link (YouTube, Spotify, Deezer...)',
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _ctrlChordContent,
                label: 'Cifra',
                hint: 'Digite a cifra da música',
                maxLines: 20,
                validator: TextValidators.required,
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () async {
                  final formState = _formKey.currentState;

                  if (formState != null && !formState.validate()) {
                    return;
                  }

                  // Unfocus keyboard before saving to clear focus tree context
                  FocusScope.of(context).unfocus();

                  _viewModel.saveChord(
                    _ctrlChordNumber,
                    _ctrlChordName,
                    _ctrlChordIntro,
                    _ctrlChordContent,
                    _ctrlChordLink,
                  );
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.save_outlined),
                    Text('Gravar'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
