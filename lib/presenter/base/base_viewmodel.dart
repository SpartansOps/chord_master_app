import 'dart:async';
import 'package:rxdart/rxdart.dart';

abstract class BaseViewModel<TEvent> {
  final StreamController<TEvent> _eventController = BehaviorSubject<TEvent>();
  String _eventMessage = '';

  void dispose() {
    _eventController.close();
  }
  
  set setEvent(TEvent event) => _eventController.sink.add(event);
  Stream<TEvent> get getEvent => _eventController.stream;

  set setEventMessage(String message) => _eventMessage = message;
  String get getEventMessage => _eventMessage;
}