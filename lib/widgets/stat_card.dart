import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.subtitle,
  });

  final String label;
  final String value;
  final IconData icon;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A3040)),
      ),
      child: Row(
        children: [
          _IconBox(icon: icon, color: primary),
          const SizedBox(width: 16),
          Expanded(
            child: _StatText(
              value: value,
              label: label,
              subtitle: subtitle,
              primary: primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _IconBox extends StatelessWidget {
  const _IconBox({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
}

class _StatText extends StatelessWidget {
  const _StatText({
    required this.value,
    required this.label,
    required this.primary,
    this.subtitle,
  });

  final String value;
  final String label;
  final Color primary;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 13),
        ),
        if (subtitle != null)
          Text(subtitle!, style: TextStyle(color: primary, fontSize: 12)),
      ],
    );
  }
}
