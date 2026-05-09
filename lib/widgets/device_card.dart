import 'package:flutter/material.dart';

class DeviceCard extends StatelessWidget {
  const DeviceCard({
    super.key,
    required this.name,
    required this.room,
    required this.icon,
    required this.isOn,
    this.value,
  });

  final String name;
  final String room;
  final IconData icon;
  final bool isOn;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isOn ? primary.withValues(alpha: 0.12) : const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOn
              ? primary.withValues(alpha: 0.4)
              : const Color(0xFF2A3040),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: isOn ? primary : Colors.white38, size: 26),
              _StatusDot(isOn: isOn, color: primary),
            ],
          ),
          const Spacer(),
          if (value != null) ...[
            Text(
              value!,
              style: TextStyle(
                color: primary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
          ],
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          Text(
            room,
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.isOn, required this.color});

  final bool isOn;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 9,
      height: 9,
      decoration: BoxDecoration(
        color: isOn ? color : Colors.white24,
        shape: BoxShape.circle,
      ),
    );
  }
}
