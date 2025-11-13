import 'dart:async';
import 'package:flutter/material.dart';

class SplashProvider extends ChangeNotifier {
  double _progress = 0.0;
  bool _completed = false;

  double get progress => _progress;
  bool get completed => _completed;

  Timer? _timer;

  /// Start simulated loading. Optionally call start(tasks: ...) to replace simulation.
  void start({Duration tick = const Duration(milliseconds: 50)}) {
    _progress = 0.0;
    _completed = false;
    _timer?.cancel();

    _timer = Timer.periodic(tick, (timer) {
      _progress += 0.01; // increment - adjust speed here
      if (_progress >= 1.0) {
        _progress = 1.0;
        _completed = true;
        timer.cancel();
      }
      notifyListeners();
    });
  }

  /// Stop/cancel loading (call on dispose/navigation)
  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
