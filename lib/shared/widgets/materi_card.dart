import 'package:flutter/material.dart';

import '../../core/constants/app_sizes.dart';
import '../../data/dummy/dummy_data.dart';
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
            // P6: Stack menumpuk penanda "tersimpan" di pojok kanan atas sampul.
            Stack(
              children: [
                CoverImage(
                  path: materi.cover,
                  width: double.infinity,
                  height: tinggiSampul,
                  radius: 0,
                ),
                // Status dibaca langsung dari DummyData, jadi selalu sama dengan Detail Materi.
                if (DummyData.materiDisimpan(materi.id))
                  Positioned(
                    top: AppSizes.s,
                    right: AppSizes.s,
                    child: Tooltip(
                      message: MateriStrings.tersimpan,
                      // P5: gaya sama seperti ModeBadge (latar surface 92%, sudut 8).
                      child: Container(
                        padding: const EdgeInsets.all(AppSizes.xs),
                        decoration: BoxDecoration(
                          color: scheme.surface.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(AppSizes.radiusS),
                        ),
                        child: Icon(
                          Icons.bookmark,
                          size: AppSizes.iconS,
                          color: scheme.primary,
                        ),
                      ),
                    ),
                  ),
              ],
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
                    // Satu baris saja agar tinggi kartu tetap sesuai tinggiIsi.
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
