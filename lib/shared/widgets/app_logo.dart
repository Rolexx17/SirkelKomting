import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';

/// Logo Sirkel. [withBackground] memakai ikon aplikasi berlatar (Splash);
/// tanpa latar dipakai di Masuk dan NavigationRail.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 56, this.withBackground = false});

  final double size;
  final bool withBackground;

  // Sudut ikon ±27% dari ukuran, sehingga ikon 104 px bersudut 28 (spesifikasi Splash).
  static const _rasioSudut = 0.27;

  @override
  Widget build(BuildContext context) {
    if (!withBackground) {
      return Image.asset(
        AppAssets.logo,
        width: size,
        height: size,
        fit: BoxFit.contain,
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * _rasioSudut),
      child: Image.asset(
        AppAssets.logoAppIcon,
        width: size,
        height: size,
        fit: BoxFit.cover,
      ),
    );
  }
}
