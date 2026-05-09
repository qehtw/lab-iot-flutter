import 'package:flutter/material.dart';

import '../widgets/app_button.dart';
import '../widgets/stat_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const _UserHeader(),
          const SizedBox(height: 28),
          const Text(
            'MY HOME',
            style: TextStyle(
              color: Colors.white38,
              fontSize: 12,
              letterSpacing: 1.4,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          const StatCard(label: 'Devices', value: '6', icon: Icons.devices),
          const SizedBox(height: 10),
          const StatCard(label: 'Rooms', value: '4', icon: Icons.home),
          const SizedBox(height: 10),
          const StatCard(
            label: 'Automations',
            value: '3',
            icon: Icons.autorenew,
          ),
          const SizedBox(height: 28),
          const Text(
            'SETTINGS',
            style: TextStyle(
              color: Colors.white38,
              fontSize: 12,
              letterSpacing: 1.4,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          const _SettingsTile(
            icon: Icons.notifications,
            label: 'Notifications',
          ),
          const _SettingsTile(icon: Icons.security, label: 'Security'),
          const _SettingsTile(icon: Icons.wifi, label: 'Network'),
          const _SettingsTile(icon: Icons.info_outline, label: 'About'),
          const SizedBox(height: 24),
          AppButton(
            label: 'Sign Out',
            outlined: true,
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _UserHeader extends StatelessWidget {
  const _UserHeader();

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Row(
      children: [
        CircleAvatar(
          radius: 36,
          backgroundColor: primary.withValues(alpha: 0.2),
          child: Text(
            'A',
            style: TextStyle(
              color: primary,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Alex Johnson',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'alex@smartnest.io',
                style: TextStyle(color: Colors.white54),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: primary.withValues(alpha: 0.4)),
                ),
                child: Text(
                  'Premium',
                  style: TextStyle(color: primary, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A3040)),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white54),
        title: Text(label, style: const TextStyle(color: Colors.white)),
        trailing: const Icon(Icons.chevron_right, color: Colors.white38),
        onTap: () {},
      ),
    );
  }
}
