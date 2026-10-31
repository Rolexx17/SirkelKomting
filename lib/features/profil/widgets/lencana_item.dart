import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../data/models/lencana.dart';

/// Satu lencana di Profil: kotak berwarna berisi ikon, dengan nama di bawahnya.
class LencanaItem extends StatelessWidget {
  const LencanaItem({
    super.key,
    required this.lencana,
    required this.latar,
    required this.warnaIkon,
  });

  final Lencana lencana;

  /// Warna dari colorScheme (misalnya tertiaryContainer), lihat [warnaKe].
  final Color latar;
  final Color warnaIkon;

  // Ukuran kotak lencana dari spesifikasi 15 (kotak 56, sudut 18).
  static const _ukuranKotak = 56.0;
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: _ukuranKotak,
          height: _ukuranKotak,
          decoration: BoxDecoration(
            color: latar,
            borderRadius: const BorderRadius.all(
              Radius.circular(_radiusKotak),
            ),
          ),
          child: Icon(lencana.ikon, color: warnaIkon),
        ),
        const SizedBox(height: AppSizes.s),
        Text(
          lencana.nama,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
