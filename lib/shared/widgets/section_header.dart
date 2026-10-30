import 'package:flutter/material.dart';

/// Judul bagian (titleMedium) di kiri dan tombol teks opsional di kanan,
/// misalnya "Rekomendasi untukmu" + "Lihat semua".
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;

  /// Teks tombol di kanan; tombol tidak tampil bila null.
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final label = actionLabel;

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        if (label != null) TextButton(onPressed: onAction, child: Text(label)),
      ],
    );
  }
}
