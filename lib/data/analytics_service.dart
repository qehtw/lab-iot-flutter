import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

class AnalyticsService {
  static final AnalyticsService _i = AnalyticsService._();
  AnalyticsService._();
  factory AnalyticsService() => _i;

  final _fa = FirebaseAnalytics.instance;

  Future<void> _log(String name, [Map<String, Object>? params]) async {
    try {
      await _fa.logEvent(name: name, parameters: params);
      debugPrint('[Analytics] $name ${params ?? ''}');
    } catch (e) {
      debugPrint('[Analytics] $name failed: $e');
    }
  }

  Future<void> logTorchDelayStarted(int delaySeconds) =>
      _log('torch_delay_started', {'delay_seconds': delaySeconds});

  Future<void> logTorchToggled({
    required bool isOn,
    required int delaySeconds,
  }) => _log('torch_toggled', {
        'state': isOn ? 'on' : 'off',
        'delay_seconds': delaySeconds,
      });

  Future<void> logShakeDetected(String screen) =>
      _log('shake_detected', {'screen': screen});

  Future<void> logLoginSuccess() async {
    try {
      await _fa.logLogin(loginMethod: 'local');
      debugPrint('[Analytics] login success');
    } catch (e) {
      debugPrint('[Analytics] login_success failed: $e');
    }
  }

  Future<void> logLoginFailure(String reason) =>
      _log('login_failure', {'reason': reason});
}
