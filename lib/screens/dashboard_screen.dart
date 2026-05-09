import 'dart:async';

import 'package:flutter/material.dart';

import '../core/models/sensor_reading.dart';
import '../core/models/user.dart';
import '../data/connectivity_plus_repository.dart';
import '../data/local_auth_repository.dart';
import '../data/local_user_repository.dart';
import '../data/mqtt_client_repository.dart';
import '../widgets/connectivity_banner.dart';
import '../widgets/device_card.dart';

const _mqttTopics = [
  'smartnest/demo/temperature',
  'smartnest/demo/humidity',
  'smartnest/demo/motion',
];

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _authRepo = LocalAuthRepository(LocalUserRepository());
  final _connRepo = ConnectivityPlusRepository();
  final _mqttRepo = MqttClientRepository();

  User? _user;
  bool _isOnline = true;
  final Map<String, SensorReading> _sensorReadings = {};
  bool _mqttConnected = false;

  StreamSubscription<bool>? _connSub;
  StreamSubscription<SensorReading>? _mqttSub;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _monitorConnectivity();
    _startMqtt();
  }

  @override
  void dispose() {
    _connSub?.cancel();
    _mqttSub?.cancel();
    super.dispose();
  }

  Future<void> _loadUser() async {
    final user = await _authRepo.getCurrentUser();
    if (mounted) setState(() => _user = user);
  }

  Future<void> _monitorConnectivity() async {
    _isOnline = await _connRepo.isOnline;
    if (mounted) setState(() {});
    _connSub = _connRepo.statusStream.listen((online) {
      if (!mounted) return;
      setState(() => _isOnline = online);
      if (!online) {
        setState(() => _mqttConnected = false);
        _mqttSub?.cancel();
      } else if (!_mqttConnected) {
        _startMqtt();
      }
    });
  }

  Future<void> _startMqtt() async {
    _mqttSub?.cancel();
    if (!_mqttRepo.isConnected) {
      final ok = await _mqttRepo.connect();
      if (!mounted || !ok) return;
      _mqttRepo.subscribe(_mqttTopics);
    }
    setState(() => _mqttConnected = _mqttRepo.isConnected);
    _mqttSub = _mqttRepo.readings.listen((r) {
      if (mounted) {
        setState(() {
          _sensorReadings[r.topic] = r;
          _mqttConnected = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          ConnectivityBanner(isOnline: _isOnline),
          Expanded(
            child: _DashboardBody(
              readings: _sensorReadings,
              mqttConnected: _mqttConnected,
            ),
          ),
        ],
      ),
      bottomNavigationBar: _BottomNav(
        currentIndex: 0,
        onTap: (i) {
          if (i == 1) Navigator.pushNamed(context, '/profile');
        },
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _user != null
                ? 'Hello, ${_user!.name.split(' ').first}'
                : 'SmartNest',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            _user?.homeName ?? '—',
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
      actions: [
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/profile'),
          child: Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                _user != null ? _user!.name[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.readings, required this.mqttConnected});

  final Map<String, SensorReading> readings;
  final bool mqttConnected;

  String _val(String topic, String unit) {
    final r = readings[topic];
    if (r == null) return mqttConnected ? '…' : '—';
    return '${r.value}$unit';
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'My Devices',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.15,
          children: [
            DeviceCard(
              name: 'Temperature',
              room: 'MQTT Sensor',
              icon: Icons.thermostat,
              isOn: mqttConnected,
              value: _val('smartnest/demo/temperature', '°C'),
            ),
            DeviceCard(
              name: 'Humidity',
              room: 'MQTT Sensor',
              icon: Icons.water_drop,
              isOn: mqttConnected,
              value: _val('smartnest/demo/humidity', '%'),
            ),
            DeviceCard(
              name: 'Motion',
              room: 'MQTT Sensor',
              icon: Icons.directions_run,
              isOn: mqttConnected,
              value: _val('smartnest/demo/motion', ''),
            ),
          ],
        ),
      ],
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      backgroundColor: const Color(0xFF1A1F2E),
      selectedItemColor: Theme.of(context).colorScheme.primary,
      unselectedItemColor: Colors.white38,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.grid_view_rounded),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profile',
        ),
      ],
    );
  }
}
