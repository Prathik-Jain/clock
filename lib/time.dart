import 'dart:async';

import 'package:flutter/foundation.dart';

class Time with ChangeNotifier {
  int hour;
  int minute;
  int second;

  DateTime _date;
  Timer _updateTimer;

  Time() {
    _updateTime();
  }

  _updateTime() {
    _date = DateTime.now();
    hour = _date.hour >= 12 ? _date.hour - 12 : _date.hour;
    minute = _date.minute;
    second = _date.second;

    _updateTimer = Timer(
      Duration(seconds: 1) - Duration(milliseconds: _date.millisecond),
      _updateTime,
    );

    notifyListeners();
  }

  @override
  String toString() {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:${second.toString().padLeft(2, '0')} ${_date.hour >= 12 ? "PM" : "AM"}';
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }
}
