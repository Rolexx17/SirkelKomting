import 'package:flutter/material.dart';

import '../../core/constants/app_sizes.dart';
import '../../data/models/materi.dart';
import '../../features/materi/materi_strings.dart';
import 'cover_image.dart';
import 'user_avatar.dart';

/// Kartu satu materi untuk grid Ruang Materi: sampul, judul, format, dan pengunggah.
class MateriCard extends StatelessWidget {
  const MateriCard({super.key, required this.materi, this.onTap});

  final Materi materi;
  final VoidCallback? onTap;

  static const tinggiSampul = 92.0;
  static const ukuranAvatar = 20.0;

  /// Perkiraan tinggi bagian teks (padding + judul 2 baris + format + baris pengunggah).
  /// Dipakai grid untuk menghitung tinggi sel agar kartu tidak terpotong.
  static const tinggiIsi = 124.0;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final namaDepan = materi.pengunggah.nama.split(' ').first;

    // P4: Card warna surfaceContainerLow, elevation 0, sudut 16 (dari cardTheme).
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CoverImage(
              path: materi.cover,
              width: double.infinity,
              height: tinggiSampul,
              radius: 0,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.m,
                AppSizes.sm,
                AppSizes.m,
                AppSizes.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    materi.judul,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: text.titleMedium,
                  ),
                  const SizedBox(height: AppSizes.xs),
                  Text(
                    MateriStrings.formatHalaman(materi.format, materi.halaman),
                    style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: AppSizes.s),
                  Row(
                    children: [
                      UserAvatar(
                        imagePath: materi.pengunggah.avatar,
                        size: ukuranAvatar,
                      ),
                      const SizedBox(width: AppSizes.s),
                      Expanded(
                        child: Text(
                          namaDepan,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: text.bodyMedium
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
