import 'dart:async';

import 'package:flutter/material.dart';

import '../core/models/sensor_reading.dart';
import '../data/analytics_service.dart';
import '../data/connectivity_plus_repository.dart';
import '../data/mqtt_client_repository.dart';
import '../data/shake_detector_service.dart';
import '../widgets/sensor_tile.dart';

const _topics = [
  'smartnest/demo/temperature',
  'smartnest/demo/humidity',
  'smartnest/demo/motion',
];

class SensorsScreen extends StatefulWidget {
  const SensorsScreen({super.key});

  @override
  State<SensorsScreen> createState() => _SensorsScreenState();
}

class _SensorsScreenState extends State<SensorsScreen> {
  final _mqttRepo = MqttClientRepository();
  final _connRepo = ConnectivityPlusRepository();
  final _shakeDetector = ShakeDetectorService();
  final _analytics = AnalyticsService();

  final Map<String, SensorReading> _readings = {};
  bool _connected = false;
  bool _connecting = true;
  int _shakeCount = 0;

  StreamSubscription<SensorReading>? _sub;
  StreamSubscription<bool>? _connSub;

  @override
  void initState() {
    super.initState();
    _connect();
    _monitorConnectivity();
    _shakeDetector.start(_onShake);
    debugPrint('[SensorsScreen] initState — shake detector started');
  }

  void _onShake() {
    if (!mounted) return;
    setState(() => _shakeCount++);
    _analytics.logShakeDetected('sensors');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.vibration, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Text('Shake detected! (#$_shakeCount)'),
          ],
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xFF1A2540),
      ),
    );
  }

  void _monitorConnectivity() {
    _connSub = _connRepo.statusStream.listen((online) {
      if (!mounted) return;
      if (!online) {
        setState(() {
          _connected = false;
          _connecting = false;
        });
        _sub?.cancel();
      } else if (!_connected && !_connecting) {
        _connect();
      }
    });
  }

  Future<void> _connect() async {
    setState(() {
      _connecting = true;
      _connected = false;
      _readings.clear();
    });
    await _sub?.cancel();

    if (_mqttRepo.isConnected) {
      if (!mounted) return;
      setState(() {
        _connected = true;
        _connecting = false;
      });
      _mqttRepo.subscribe(_topics);
      _sub = _mqttRepo.readings.listen((r) {
        if (mounted) setState(() => _readings[r.topic] = r);
      });
      return;
    }

    final ok = await _mqttRepo.connect();
    if (!mounted) return;
    setState(() {
      _connected = ok;
      _connecting = false;
    });
    if (ok) {
      _mqttRepo.subscribe(_topics);
      _sub = _mqttRepo.readings.listen((r) {
        if (mounted) setState(() => _readings[r.topic] = r);
      });
    }
  }

  @override
  void dispose() {
    _shakeDetector.stop();
    _connSub?.cancel();
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text(
          'Live Sensors',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          if (_shakeCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _ShakeBadge(count: _shakeCount),
            ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _StatusDot(connected: _connected, connecting: _connecting),
          ),
        ],
      ),
      body: _connecting
          ? const Center(child: CircularProgressIndicator())
          : !_connected
          ? _ErrorView(onRetry: _connect)
          : _readings.isEmpty
          ? const _WaitingView()
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _readings.length,
              itemBuilder: (_, i) =>
                  SensorTile(reading: _readings.values.elementAt(i)),
            ),
    );
  }
}

class _ShakeBadge extends StatelessWidget {
  const _ShakeBadge({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.vibration, size: 16, color: Colors.white54),
        const SizedBox(width: 4),
        Text('$count', style: const TextStyle(color: Colors.white54, fontSize: 13)),
      ],
    );
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.connected, required this.connecting});

  final bool connected;
  final bool connecting;

  @override
  Widget build(BuildContext context) {
    final color = connecting
        ? Colors.orange
        : connected
        ? Theme.of(context).colorScheme.primary
        : Colors.redAccent;
    final label = connecting
        ? 'Connecting'
        : connected
        ? 'Live'
        : 'Offline';
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(color: color, fontSize: 13)),
      ],
    );
  }
}

class _WaitingView extends StatelessWidget {
  const _WaitingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sensors, color: Colors.white24, size: 64),
          const SizedBox(height: 16),
          const Text(
            'Waiting for sensor data…',
            style: TextStyle(color: Colors.white54),
          ),
          const SizedBox(height: 8),
          const Text(
            'Run mqtt_simulator.py to publish data',
            style: TextStyle(color: Colors.white38, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off, color: Colors.redAccent, size: 64),
          const SizedBox(height: 16),
          const Text(
            'Could not connect to MQTT broker',
            style: TextStyle(color: Colors.white54),
          ),
          const SizedBox(height: 8),
          const Text(
            'Check internet and try again',
            style: TextStyle(color: Colors.white38, fontSize: 12),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
              side: BorderSide(color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}
