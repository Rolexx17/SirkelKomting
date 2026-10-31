import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../data/models/sesi.dart';
import '../../../data/models/sirkel.dart';
import '../../../shared/widgets/avatar_stack.dart';
import '../../../shared/widgets/cover_image.dart';
import '../../sirkel_saya/jadwal_util.dart';
import '../beranda_strings.dart';

/// Kartu sesi berikutnya berlatar primary: label hari ("HARI INI", "BESOK",
/// "KAMIS, 5 NOV"), mata kuliah, jam sesi, anggota, dan tombol Masuk sesi.
class HariIniCard extends StatelessWidget {
  const HariIniCard({
    super.key,
    required this.sirkel,
    required this.sesi,
    required this.label,
    required this.onMasukSesi,
  });

  final Sirkel sirkel;

  /// Sesi yang ditampilkan; jamnya diambil dari [Sesi.waktu].
  final Sesi sesi;

  /// Label hari, dihitung Beranda lewat `BerandaScreen.labelSesi`.
  final String label;
  final VoidCallback onMasukSesi;

  static const _ukuranSampul = 104.0;
  static const _radiusSampul = 20.0;
  static const _ukuranAvatar = 28.0;
  static const _ukuranIkonJam = 18.0;
  static const _maksAvatar = 3;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final teksLembut = scheme.onPrimary.withValues(alpha: 0.8);

    final namaDepanMentor = sirkel.mentor.nama.split(' ').first;
    final mode = sirkel.mode == ModeBelajar.online
        ? BerandaStrings.online
        : BerandaStrings.offline;
    final avatar =
        sirkel.anggota.take(_maksAvatar).map((a) => a.avatar).toList();
    // Anggota yang tidak tampil fotonya ditulis sebagai "+N".
    final sisaAnggota = sirkel.anggota.length - avatar.length;

    // P5: Container berhias (warna primary, sudut 24) menjadi latar kartu.
    return Container(
      padding: const EdgeInsets.all(AppSizes.l),
      decoration: BoxDecoration(
        color: scheme.primary,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
      ),
      // P6: Stack menumpuk sampul di kanan atas, di atas susunan teks dan tombol.
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ruang kanan dikosongkan selebar sampul agar teks tidak tertimpa.
              Padding(
                padding: const EdgeInsets.only(right: _ukuranSampul + AppSizes.sm),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: _ukuranSampul),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.labelMedium?.copyWith(color: teksLembut),
                      ),
                      const SizedBox(height: AppSizes.xs),
                      Text(
                        sirkel.mataKuliah,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: text.titleLarge?.copyWith(color: scheme.onPrimary),
                      ),
                      const SizedBox(height: AppSizes.xs),
                      Text(
                        BerandaStrings.topikMentor(sirkel.judul, namaDepanMentor),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: text.bodyMedium?.copyWith(color: teksLembut),
                      ),
                      const SizedBox(height: AppSizes.sm),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: _ukuranIkonJam,
                            color: scheme.onPrimary,
                          ),
                          const SizedBox(width: AppSizes.s),
                          Flexible(
                            child: Text(
                              BerandaStrings.jamMode(jamDari(sesi.waktu), mode),
                              style: text.titleSmall
                                  ?.copyWith(color: scheme.onPrimary),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.m),
              Row(
                children: [
                  // Tombol diukur lebih dulu; avatar mengecil bila ruang sempit (layar 320 px).
                  Flexible(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: AvatarStack(
                          images: avatar,
                          size: _ukuranAvatar,
                          extra: sisaAnggota,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.sm),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: scheme.surface,
                      foregroundColor: scheme.primary,
                    ),
                    onPressed: onMasukSesi,
                    child: const Text(BerandaStrings.masukSesi),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            top: 0,
            right: 0,
            child: CoverImage(
              path: sirkel.cover,
              width: _ukuranSampul,
              height: _ukuranSampul,
              radius: _radiusSampul,
            ),
          ),
        ],
      ),
    );
  }
}
