import 'dart:async';
import 'dart:io';
import 'package:chord_master_app/app/services/app_preferences.dart';
import 'package:chord_master_app/app/services/file_picker.dart';
import 'package:chord_master_app/data/mapper/chord_mapper.dart';
import 'package:chord_master_app/data/models/chord_data.dart';
import 'package:chord_master_app/data/repository/chord_repository.dart';
import 'package:chord_master_app/app/services/file_service.dart';
import 'package:chord_master_app/app/services/permissions.dart';
import 'package:chord_master_app/domain/chord.dart';
import 'package:chord_master_app/presenter/base/base_viewmodel.dart';
import 'package:dio/dio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rxdart/rxdart.dart';

enum HomeEvent {
  idle,
  loadingChords,
  errorLoadChords,
  successLoad,
  downloadingChords,
  errorDownloadChords,
  successDownload,
  saving,
  showDialogPermissionStorage,
  invalidFileType,
  fileNotSelected,
}

class HomeViewModel extends BaseViewModel {
  final ChordRepository _repository;
  final PermissionService permissionService;
  final ServiceFile fileService;
  final AppPreferences _appPreferences;
  final FilePickerService _filePickerService;

  List<Chord> chords = [];
  List<Chord> filteredChordList = [];
  final StreamController<List<Chord>> _chordsController =
      BehaviorSubject<List<Chord>>();

  Stream<List<Chord>> get chordsStream => _chordsController.stream;

  List<Chord> chordsPref = [];
  final StreamController<List<Chord>> _chordListController =
      BehaviorSubject<List<Chord>>();

  Stream<List<Chord>> get listChordsStream => _chordListController.stream;

  HomeViewModel(
    this._repository,
    this.permissionService,
    this.fileService,
    this._appPreferences,
    this._filePickerService,
  );

  Future<void> getAllChords() async {
    try {
      if (await permissionService.permissionStorageStatus ==
              PermissionStatus.denied ||
          await permissionService.permissionStorageStatus ==
              PermissionStatus.permanentlyDenied) {
        setEvent = HomeEvent.showDialogPermissionStorage;
        return;
      }

      if ((await fileService.readAsListOfMap()).isNotEmpty) {
        chords = (await fileService.readAsListOfMap())
            .map((e) => ChordData.fromJson(e).toDomain())
            .toList();

        // _repository.getAllChords();
        /* await fileService.writeListOfMap(
          chords
              .map(
                (e) => ChordData(
                  id: e.id,
                  chordNumber: e.chordNumber,
                  chordName: e.chordName,
                  chordContent: e.chordContent,
                  sync: e.sync,
                  chordIntro: e.chordIntro,
                  chordLink: e.chordLink,
                ).toJson(),
              )
              .toList(),
        ); */
      } else {
        chords = [];
      }

      filteredChordList = chords;

      if (chords.isEmpty) {
        setEventMessage = "As cifras não puderam ser carregadas!";
        setEvent = HomeEvent.errorLoadChords;
        _chordsController.sink.add(chords);
        return;
      }
      _chordsController.sink.add(chords);
      setEventMessage = "Cifras carregadas com sucesso!";
      setEvent = HomeEvent.successLoad;
    } on DioException catch (e) {
      setEventMessage = e.message ?? "Não foi possível carregar as cifras";
      setEvent = HomeEvent.errorLoadChords;
    } catch (e) {
      setEventMessage =
          "Não foi possível carregar as cifra, ocorreu um problema no sistema!";
      setEvent = HomeEvent.errorLoadChords;
    }
  }

  Future<void> addChordList(Chord chord) async {
    await _appPreferences.saveOneAsListOfMap(
      PrefKeys.prefChordList,
      ChordData(
        id: chord.id,
        chordNumber: chord.chordNumber,
        chordName: chord.chordName,
        chordContent: chord.chordContent,
        sync: chord.sync,
        chordIntro: chord.chordIntro,
        chordLink: chord.chordLink,
      ).toJson(),
    );
  }

  Future<void> getChordList() async {
    chordsPref = (await _appPreferences.getAsListOfMap(PrefKeys.prefChordList))
        .map((e) => ChordData.fromJson(e).toDomain())
        .toList();
    _chordListController.sink.add(chordsPref);
  }

  Future<void> deleteChordOfList(Chord chord) async {
    chordsPref.remove(chord);
    _chordListController.sink.add(chordsPref);
    await _appPreferences.saveAsListOfMap(
      PrefKeys.prefChordList,
      chordsPref
          .map((e) => ChordData(
                id: e.id,
                chordNumber: e.chordNumber,
                chordName: e.chordName,
                chordContent: e.chordContent,
                sync: e.sync,
                chordIntro: e.chordIntro,
                chordLink: e.chordLink,
              ).toJson())
          .toList(),
    );
  }

  void filterChords(String query) {
    filteredChordList = chords
        .where(
          (chord) =>
              (chord.chordName ?? "").toLowerCase().contains(
                    query.toLowerCase(),
                  ) ||
              (chord.chordNumber?.toString() ?? "").toLowerCase().contains(
                    query.toLowerCase(),
                  ),
        )
        .toList();
    if (query.isEmpty) {
      _chordsController.sink.add(chords);
      return;
    }

    _chordsController.sink.add(filteredChordList);
  }

  Future<void> pickFile() async {
    setEvent = HomeEvent.loadingChords;
    try {
      File? file = await _filePickerService.pickFile();
      if (file == null) {
        setEvent = HomeEvent.fileNotSelected;
        setEventMessage = "O arquivo não foi cselecionado";
        return;
      }

      if (!file.path.endsWith('.json')) {
        setEvent = HomeEvent.invalidFileType;
        setEventMessage =
            "Não foi possível fazer a leitura do arquivo selecionado";
        return;
      }

      chords = (await _filePickerService.convertFileToMap(file))
          .map((e) => ChordData.fromJson(e).toDomain())
          .toList();
      filteredChordList = chords;
      _chordsController.sink.add(chords);
      setEventMessage = "Cifras carregadas com sucesso!";
      await fileService.writeListOfMap(chords
          .map(
            (e) => ChordData(
              id: e.id,
              chordNumber: e.chordNumber,
              chordName: e.chordName,
              chordContent: e.chordContent,
              sync: e.sync,
              chordIntro: e.chordIntro,
              chordLink: e.chordLink,
            ).toJson(),
          )
          .toList());
      setEvent = HomeEvent.successLoad;
    } catch (e) {
      setEventMessage =
          "Não foi possível carregar as cifra, ocorreu um problema no sistema!";
      setEvent = HomeEvent.errorLoadChords;
    }
  }

  @override
  void dispose() {
    _chordsController.close();
    _chordListController.close();
    super.dispose();
  }
}
