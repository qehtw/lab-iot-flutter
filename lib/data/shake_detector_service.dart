import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';

class ShakeDetectorService {
  // userAccelerometer removes gravity — at rest values ≈ 0, shake adds force
  static const double _threshold = 8.0;
  static const _debounce = Duration(milliseconds: 800);

  StreamSubscription<UserAccelerometerEvent>? _sub;
  DateTime? _lastShake;

  void start(void Function() onShake) {
    _sub = userAccelerometerEventStream(
      samplingPeriod: SensorInterval.gameInterval,
    ).listen(
      (e) {
        final mag = sqrt(e.x * e.x + e.y * e.y + e.z * e.z);
        debugPrint('[Shake] mag=${mag.toStringAsFixed(2)}');
        if (mag < _threshold) return;
        final now = DateTime.now();
        if (_lastShake != null && now.difference(_lastShake!) < _debounce) {
          return;
        }
        _lastShake = now;
        onShake();
      },
      onError: (e) => debugPrint('[Shake] sensor error: $e'),
    );
  }

  void stop() {
    _sub?.cancel();
    _sub = null;
  }
}
