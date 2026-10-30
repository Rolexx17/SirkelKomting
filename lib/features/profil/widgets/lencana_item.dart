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

  /// Warna dari colorScheme (misalnya tertiaryContainer), dikirim oleh ProfilScreen.
  final Color latar;
  final Color warnaIkon;

  // Ukuran kotak lencana dari spesifikasi 15 (kotak 56, sudut 18).
  static const _ukuranKotak = 56.0;
  static const _radiusKotak = 18.0;

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
