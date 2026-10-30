import 'package:flutter/material.dart';

import '../../core/constants/app_sizes.dart';

/// Baris informasi: ikon primary di kiri, lalu label, nilai, dan keterangan opsional.
class InfoRow extends StatelessWidget {
  const InfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.subtitle,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Row(
      children: [
        Icon(icon, color: scheme.primary),
        const SizedBox(width: AppSizes.m),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: text.labelMedium?.copyWith(color: scheme.onSurfaceVariant),
              ),
              Text(value, style: text.bodyLarge),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
