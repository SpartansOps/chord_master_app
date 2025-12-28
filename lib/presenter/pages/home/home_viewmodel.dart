import 'dart:async';
import 'package:chord_master_app/app/services/app_preferences.dart';
import 'package:chord_master_app/data/mapper/chord_mapper.dart';
import 'package:chord_master_app/data/models/chord_data.dart';
import 'package:chord_master_app/data/repository/chord_repository.dart';
import 'package:chord_master_app/domain/chord.dart';
import 'package:chord_master_app/presenter/base/base_viewmodel.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart';
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
}

class HomeViewModel extends BaseViewModel {
  final ChordRepository _repository;
  final AppPreferences _appPreferences;

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
    this._appPreferences,
  );

  Future<void> refreshChords() async {
    chords = _appPreferences.getDownloadListChords();
    filteredChordList = chords;
    _chordsController.sink.add(chords);
  }

  Future<void> downloadChords({bool isDownload = false}) async {
    try {
      setEvent = HomeEvent.downloadingChords;
      final connectionResult = await Connectivity().checkConnectivity();
      bool hasConnection =
          connectionResult.contains(ConnectivityResult.ethernet) ||
              connectionResult.contains(ConnectivityResult.wifi) ||
              connectionResult.contains(ConnectivityResult.mobile);

      if (isDownload && hasConnection) {
        chords = await _repository.getAllChords();
        await _appPreferences.saveDownloadListChords(chords);
        filteredChordList = chords;
      } else {
        chords = _appPreferences.getDownloadListChords();
        filteredChordList = chords;
      }

      if (chords.isEmpty) {
        setEventMessage = "As cifras não puderam ser carregadas!";
        setEvent = HomeEvent.errorLoadChords;
        return;
      }
      _chordsController.sink.add(chords);
      setEventMessage = "Cifras carregadas com sucesso!";
      setEvent = HomeEvent.successDownload;
    } on ClientException catch (e) {
      setEventMessage = e.message;
      setEvent = HomeEvent.errorDownloadChords;
    } catch (e) {
      setEventMessage =
          "Não foi possível carregar as cifra, ocorreu um problema no sistema!";
      setEvent = HomeEvent.errorDownloadChords;
    }
  }

  Future<void> addChordList(Chord chord) async {
    await _appPreferences.saveOneAsListOfMap(
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
    chordsPref = (await _appPreferences.getAsListOfMap())
        .map((e) => ChordData.fromJson(e).toDomain())
        .toList();
    _chordListController.sink.add(chordsPref);
  }

  Future<void> deleteChordOfList(Chord chord) async {
    chordsPref.remove(chord);
    _chordListController.sink.add(chordsPref);
    await _appPreferences.saveAsListOfMap(
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

  @override
  void dispose() {
    _chordsController.close();
    _chordListController.close();
    super.dispose();
  }
}
