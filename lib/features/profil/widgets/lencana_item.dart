import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../lencana_progres.dart';
import '../profil_strings.dart';

/// Satu lencana di Profil: kotak berwarna berisi ikon, dengan nama di bawahnya.
/// Lencana yang belum didapat tampil abu-abu dengan angka progres ("3/4").
class LencanaItem extends StatelessWidget {
  const LencanaItem({
    super.key,
    required this.progres,
    required this.latar,
    required this.warnaIkon,
    this.onTap,
  });

  final ProgresLencana progres;

  /// Warna dari colorScheme (misalnya tertiaryContainer), lihat [warnaKe].
  /// Hanya dipakai bila lencana sudah didapat.
  final Color latar;
  final Color warnaIkon;
  final VoidCallback? onTap;

  // Ukuran kotak lencana dari spesifikasi 15 (kotak 56, sudut 18).
  static const ukuranKotak = 56.0;
  static const _radiusKotak = 18.0;

  /// Pasangan (latar, ikon) untuk lencana ke-[indeks], berulang setiap 4 lencana
  /// sesuai spesifikasi 15. Dipakai di Profil dan sheet Semua lencana agar warnanya sama.
  static (Color, Color) warnaKe(ColorScheme scheme, int indeks) {
    final pilihan = [
      (scheme.tertiaryContainer, scheme.onTertiaryContainer),
      (scheme.primaryContainer, scheme.onPrimaryContainer),
      (scheme.secondaryContainer, scheme.onSecondaryContainer),
      (scheme.surfaceContainerHighest, scheme.onSurface),
    ];
    return pilihan[indeks % pilihan.length];
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final didapat = progres.didapat;

    return InkWell(
      onTap: onTap,
      borderRadius: const BorderRadius.all(Radius.circular(AppSizes.radiusM)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.xs),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            KotakLencana(
              ikon: progres.lencana.ikon,
              // Belum didapat → warna netral agar beda jelas dengan yang sudah didapat.
              latar: didapat ? latar : scheme.surfaceContainerHigh,
              warnaIkon: didapat ? warnaIkon : scheme.outline,
            ),
            const SizedBox(height: AppSizes.s),
            Text(
              progres.lencana.nama,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: text.bodyMedium?.copyWith(
                color: didapat ? null : scheme.onSurfaceVariant,
              ),
            ),
            if (!didapat)
              Text(
                ProfilStrings.progres(progres.nilaiTampil, progres.target),
                style: text.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
          ],
        ),
      ),
    );
  }
}

/// Kotak ikon lencana (56 × 56, sudut 18). Dipakai di [LencanaItem] dan sheet lencana.
class KotakLencana extends StatelessWidget {
  const KotakLencana({
    super.key,
    required this.ikon,
    required this.latar,
    required this.warnaIkon,
    this.ukuran = LencanaItem.ukuranKotak,
  });

  final IconData ikon;
  final Color latar;
  final Color warnaIkon;
  final double ukuran;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ukuran,
      height: ukuran,
      decoration: BoxDecoration(
        color: latar,
        borderRadius: const BorderRadius.all(
          Radius.circular(LencanaItem._radiusKotak),
        ),
      ),
      child: Icon(ikon, color: warnaIkon),
    );
  }
}
