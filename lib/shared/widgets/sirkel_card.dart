import 'package:flutter/material.dart';

import '../../core/constants/app_sizes.dart';
import '../../data/models/sirkel.dart';
import '../../features/sirkel/sirkel_strings.dart';
import 'avatar_stack.dart';
import 'cover_image.dart';
import 'mode_badge.dart';
import 'user_avatar.dart';

/// Kartu ringkasan satu sirkel. Dipakai di Beranda, Jelajah, dan Sirkel Saya.
class SirkelCard extends StatelessWidget {
  const SirkelCard({
    super.key,
    required this.sirkel,
    this.onTap,
    this.compact = false,
  });

  final Sirkel sirkel;
  final VoidCallback? onTap;

  /// true = sampul lebih pendek (96 px), dipakai di grid layar lebar.
  final bool compact;

  /// Banyak avatar anggota yang ditampilkan di kanan bawah kartu.
  static const _maksAvatar = 3;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final namaDepanMentor = sirkel.mentor.nama.split(' ').first;

    // Sisa kursi ≤ 2 diberi warna peringatan agar pengguna cepat mendaftar.
    final kursiSedikit = sirkel.sisaKursi <= 2;
    final warnaKursi = kursiSedikit ? scheme.error : scheme.onSurface;

    // InkWell di dalam Card: efek ripple tergambar di permukaan Card dan ikut
    // terpotong sudut 16 karena Card memakai clipBehavior antiAlias (tema).
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // P6: Stack menumpuk ModeBadge di kiri atas sampul.
            Stack(
              children: [
                CoverImage(
                  path: sirkel.cover,
                  width: double.infinity,
                  height: compact ? AppSizes.coverCardCompact : AppSizes.coverCard,
                  radius: 0,
                ),
                Positioned(
                  left: AppSizes.sm,
                  top: AppSizes.sm,
                  child: ModeBadge(mode: sirkel.mode),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.m,
                AppSizes.sm,
                AppSizes.m,
                AppSizes.m,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    sirkel.mataKuliah.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.labelMedium?.copyWith(color: scheme.primary),
                  ),
                  const SizedBox(height: AppSizes.xs),
                  Text(
                    sirkel.judul,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.titleMedium,
                  ),
                  const SizedBox(height: AppSizes.s),
                  Row(
                    children: [
                      UserAvatar(
                        imagePath: sirkel.mentor.avatar,
                        size: AppSizes.avatarS,
                      ),
                      const SizedBox(width: AppSizes.s),
                      Expanded(
                        child: Text(
                          SirkelStrings.mentorSingkat(namaDepanMentor),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: text.bodyMedium
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.s),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: AppSizes.iconS,
                        color: scheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: AppSizes.xs),
                      Expanded(
                        child: Text(
                          SirkelStrings.jadwalSingkat(sirkel.hari, sirkel.jam),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: text.labelMedium,
                        ),
                      ),
                      AvatarStack(
                        images: sirkel.anggota
                            .take(_maksAvatar)
                            .map((a) => a.avatar)
                            .toList(),
                        size: AppSizes.avatarS,
                        extra: 0,
                      ),
                      const SizedBox(width: AppSizes.s),
                      Text(
                        SirkelStrings.kursi(sirkel.sisaKursi),
                        style: text.labelMedium?.copyWith(color: warnaKursi),
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
