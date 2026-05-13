import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/models/user.dart';
import '../cubits/connectivity_cubit.dart';
import '../cubits/sensor_cubit.dart';
import '../cubits/user_cubit.dart';
import '../widgets/connectivity_banner.dart';
import '../widgets/device_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isOnline = context.watch<ConnectivityCubit>().state;
    final sensorState = context.watch<SensorCubit>().state;
    final userState = context.watch<UserCubit>().state;
    final user = userState is UserAuthenticated ? userState.user : null;

    return Scaffold(
      appBar: _buildAppBar(context, user),
      body: Column(
        children: [
          ConnectivityBanner(isOnline: isOnline),
          Expanded(child: _DashboardBody(sensorState: sensorState)),
        ],
      ),
      bottomNavigationBar: _BottomNav(
        currentIndex: 0,
        onTap: (i) {
          if (i == 1) Navigator.pushNamed(context, '/automations');
          if (i == 2) Navigator.pushNamed(context, '/profile');
        },
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, User? user) {
    return AppBar(
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            user != null ? 'Hello, ${user.name.split(' ').first}' : 'SmartNest',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            user?.homeName ?? '—',
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
                user != null ? user.name[0].toUpperCase() : '?',
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
  const _DashboardBody({required this.sensorState});

  final SensorState sensorState;

  String _val(String topic, String unit) {
    if (sensorState is! SensorConnected) return '—';
    final r = (sensorState as SensorConnected).readings[topic];
    return r == null ? '…' : '${r.value}$unit';
  }

  bool get _connected => sensorState is SensorConnected;

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
              isOn: _connected,
              value: _val('smartnest/demo/temperature', '°C'),
            ),
            DeviceCard(
              name: 'Humidity',
              room: 'MQTT Sensor',
              icon: Icons.water_drop,
              isOn: _connected,
              value: _val('smartnest/demo/humidity', '%'),
            ),
            DeviceCard(
              name: 'Motion',
              room: 'MQTT Sensor',
              icon: Icons.directions_run,
              isOn: _connected,
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
          icon: Icon(Icons.auto_awesome_outlined),
          label: 'Автоматизації',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profile',
        ),
      ],
    );
  }
}
