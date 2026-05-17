import 'package:torch_light/torch_light.dart';

class FlashlightService {
  static final FlashlightService _i = FlashlightService._();
  FlashlightService._();
  factory FlashlightService() => _i;

  bool _isOn = false;
  bool get isOn => _isOn;

  Future<bool> isAvailable() async {
    try {
      return await TorchLight.isTorchAvailable();
    } catch (_) {
      return false;
    }
  }

  /// Counts down [delaySeconds] seconds, calling [onCountdown] each second
  /// with the remaining count (3→2→1→0), then toggles the torch.
  /// Returns true if the torch was successfully toggled.
  Future<bool> toggleWithDelay({
    int delaySeconds = 3,
    void Function(int remaining)? onCountdown,
  }) async {
    for (int i = delaySeconds; i > 0; i--) {
      onCountdown?.call(i);
      await Future.delayed(const Duration(seconds: 1));
    }
    onCountdown?.call(0);
    return _doToggle();
  }

  Future<bool> _doToggle() async {
    try {
      if (_isOn) {
        await TorchLight.disableTorch();
        _isOn = false;
      } else {
        await TorchLight.enableTorch();
        _isOn = true;
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> ensureOff() async {
    if (_isOn) await _doToggle();
  }
}
