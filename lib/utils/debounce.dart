import 'dart:async';

import 'package:flutter/material.dart';

class Debounce {
  final int millisecond;

  Debounce({
    this.millisecond = 500,
  });

  Timer? _timer;

  void run(VoidCallback action) {
    dispose();
    _timer = Timer(Duration(milliseconds: millisecond), action);
  }

  void dispose() {
    if (_timer != null) {
      _timer!.cancel();
    }
  }
}
