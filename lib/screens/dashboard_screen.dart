import 'package:flutter/material.dart';

import '../core/models/user.dart';
import '../data/local_auth_repository.dart';
import '../data/local_user_repository.dart';
import '../widgets/device_card.dart';
import '../widgets/stat_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _authRepo = LocalAuthRepository(LocalUserRepository());
  User? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await _authRepo.getCurrentUser();
    if (mounted) setState(() => _user = user);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: const _DashboardBody(),
      bottomNavigationBar: _BottomNav(
        currentIndex: 0,
        onTap: (i) {
          if (i == 2) Navigator.pushNamed(context, '/profile');
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
  const _DashboardBody();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: const [
        StatCard(
          label: 'Active Devices',
          value: '4 / 6',
          icon: Icons.devices,
          subtitle: 'Online now',
        ),
        SizedBox(height: 12),
        StatCard(
          label: 'Energy Today',
          value: '3.8 kWh',
          icon: Icons.bolt,
          subtitle: '↓ 12% vs yesterday',
        ),
        SizedBox(height: 24),
        Text(
          'My Devices',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 16),
        _DevicesGrid(),
      ],
    );
  }
}

class _DevicesGrid extends StatelessWidget {
  const _DevicesGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.15,
      children: const [
        DeviceCard(
          name: 'Living Room',
          room: 'Light',
          icon: Icons.lightbulb_outline,
          isOn: true,
        ),
        DeviceCard(
          name: 'Thermostat',
          room: 'Hallway',
          icon: Icons.thermostat,
          isOn: true,
          value: '22°C',
        ),
        DeviceCard(
          name: 'Door Lock',
          room: 'Entrance',
          icon: Icons.lock_outline,
          isOn: false,
        ),
        DeviceCard(
          name: 'Camera',
          room: 'Backyard',
          icon: Icons.videocam,
          isOn: true,
        ),
        DeviceCard(
          name: 'Air Purifier',
          room: 'Bedroom',
          icon: Icons.air,
          isOn: false,
        ),
        DeviceCard(
          name: 'Smart Plug',
          room: 'Kitchen',
          icon: Icons.power,
          isOn: true,
          value: '1.2 kW',
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
          icon: Icon(Icons.bar_chart),
          label: 'Analytics',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profile',
        ),
      ],
    );
  }
}
