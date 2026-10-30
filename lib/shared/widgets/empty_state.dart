import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_sizes.dart';

/// Tampilan "kosong" rata tengah: ilustrasi, judul, dan pesan. Dipakai Jelajah dan Ruang Materi.
class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.title, required this.message});

  final String title;
  final String message;

  static const _tinggiIlustrasi = 120.0;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            AppAssets.emptyState,
            height: _tinggiIlustrasi,
            errorBuilder: (context, error, stackTrace) => Icon(
              Icons.inbox_outlined,
              size: AppSizes.xxl * 2,
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSizes.m),
          Text(title, textAlign: TextAlign.center, style: text.titleMedium),
          const SizedBox(height: AppSizes.xs),
          Text(
            message,
            textAlign: TextAlign.center,
            style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
