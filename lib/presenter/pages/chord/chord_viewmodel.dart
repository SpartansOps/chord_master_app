import 'dart:async';

import 'package:chord_master_app/data/models/chord_data.dart';
import 'package:chord_master_app/data/repository/chord_repository.dart';
import 'package:chord_master_app/domain/chord.dart';
import 'package:chord_master_app/presenter/base/base_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:rxdart/rxdart.dart';

enum ChordEvent {
  creatingOrUpdating,
  errorCreateOrUpdate,
  successCreateOrUpdate,
}

class ChordViewModel extends BaseViewModel {
  final StreamController<double> _fontSizecontroller = BehaviorSubject();
  Stream<double> get fontSizeStream => _fontSizecontroller.stream;

  double defaultFontSize = 16.0;
  Chord chord = Chord.empty();

  final ChordRepository _repository;

  ChordViewModel(this._repository);

  void populateForm(
    TextEditingController ctrlNumber,
    TextEditingController ctrlTitle,
    TextEditingController ctrlIntro,
    TextEditingController ctrlContent,
    TextEditingController ctrlLink,
  ) {
    if (chord.id != null) {
      ctrlNumber.text = chord.chordNumber.toString();
      ctrlTitle.text = chord.chordName ?? "";
      ctrlIntro.text = chord.chordIntro ?? "";
      ctrlContent.text = chord.chordContent ?? "";
      ctrlLink.text = chord.chordLink ?? "";
    }
  }

  Future<void> saveChord(
    TextEditingController ctrlNumber,
    TextEditingController ctrlTitle,
    TextEditingController ctrlIntro,
    TextEditingController ctrlContent,
    TextEditingController ctrlLink,
  ) async {
    setEvent = ChordEvent.creatingOrUpdating;
    try {
      ChordData chordData = ChordData(
        id: chord.id,
        chordNumber: int.parse(ctrlNumber.text),
        chordName: ctrlTitle.text,
        chordIntro: ctrlIntro.text,
        chordContent: ctrlContent.text,
        chordLink: ctrlLink.text,
      );

      Chord? response = await _repository.saveChord(chordData);

      if (response == null) {
        setEventMessage = "A cifra não pode ser gravada!";
        setEvent = ChordEvent.errorCreateOrUpdate;
        return;
      }

      setEventMessage = "Cifra gravada com sucesso!";
      setEvent = ChordEvent.successCreateOrUpdate;

      ctrlNumber.clear();
      ctrlTitle.clear();
      ctrlIntro.clear();
      ctrlContent.clear();
      ctrlLink.clear();
      chord = Chord.empty();
    } on ClientException catch (e) {
      setEventMessage = e.message;
      setEvent = ChordEvent.errorCreateOrUpdate;
    } catch (e) {
      setEventMessage =
          "Não foi possível gravar a cifra, ocorreu um problema no sistema!";
      setEvent = ChordEvent.errorCreateOrUpdate;
    }
  }

  void increaseFont() {
    _fontSizecontroller.sink.add(defaultFontSize += 0.5);
  }

  void decreaseFont() {
    _fontSizecontroller.sink.add(defaultFontSize -= 0.5);
  }
}
