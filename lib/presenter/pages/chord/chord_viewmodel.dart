import 'dart:async';

import 'package:chord_master_app/presenter/base/base_viewmodel.dart';
import 'package:rxdart/rxdart.dart';

class ChordViewModel extends BaseViewModel {
  final StreamController<double> _fontSizecontroller = BehaviorSubject();
  Stream<double> get fontSizeStream => _fontSizecontroller.stream;

  double defaultFontSize = 16.0;

  void increaseFont() {
    _fontSizecontroller.sink.add(defaultFontSize += 0.5);
  }

  void decreaseFont() {
    _fontSizecontroller.sink.add(defaultFontSize -= 0.5);
  }

  @override
  void dispose() {
    _fontSizecontroller.close();
    super.dispose();
  }
}
