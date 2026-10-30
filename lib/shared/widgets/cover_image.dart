import 'package:flutter/material.dart';

import '../../core/constants/app_sizes.dart';

/// Gambar sampul dari aset dengan sudut membulat. Dipakai hampir di semua kartu dan header.
class CoverImage extends StatelessWidget {
  const CoverImage({
    super.key,
    required this.path,
    this.width,
    this.height,
    this.radius = AppSizes.radiusM,
  });

  /// Path aset dari `AppAssets`.
  final String path;
  final double? width;
  final double? height;

  /// Radius sudut; isi 0 bila sudut sudah dipotong oleh induknya (misalnya Card).
  final double radius;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    // P5: ClipRRect memotong gambar persegi menjadi bersudut bulat.
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.asset(
        path,
        width: width,
        height: height,
        fit: BoxFit.cover,
        // Bila path salah/aset belum dipasang, tampilkan kotak abu berikon gambar
        // agar layout tidak rusak dan aplikasi tidak menampilkan layar error.
        errorBuilder: (context, error, stackTrace) => Container(
          width: width,
          height: height,
          color: scheme.surfaceContainerHighest,
          alignment: Alignment.center,
          child: Icon(Icons.image_outlined, color: scheme.onSurfaceVariant),
        ),
      ),
    );
  }
}
