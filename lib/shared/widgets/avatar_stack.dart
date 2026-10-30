import 'package:flutter/material.dart';

import '../../core/constants/app_sizes.dart';
import 'user_avatar.dart';

/// Deretan avatar yang saling menimpa, ditutup lingkaran "+N" bila [extra] > 0.
/// Dipakai di kartu Hari ini (Beranda) dan SirkelCard.
class AvatarStack extends StatelessWidget {
  const AvatarStack({
    super.key,
    required this.images,
    this.size = 28,
    this.extra = 0,
  });

  /// Path aset avatar dari `AppAssets`, urut dari kiri.
  final List<String> images;
  final double size;

  /// Jumlah orang lain yang tidak ditampilkan fotonya.
  final int extra;

  /// Lebar bagian avatar yang tertimpa avatar berikutnya.
  static const _tumpuk = AppSizes.s;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final jumlah = images.length + (extra > 0 ? 1 : 0);
    if (jumlah == 0) return const SizedBox.shrink();

    // Setiap avatar bergeser (size - 8) dari sebelumnya. Lebar total dihitung
    // persis agar Stack tidak memotong avatar terakhir dan tidak overflow.
    final langkah = size - _tumpuk;
    final lebar = size + langkah * (jumlah - 1);

    return SizedBox(
      width: lebar,
      height: size,
      // P6: Stack + Positioned menumpuk avatar dari kiri ke kanan.
      child: Stack(
        children: [
          for (var i = 0; i < images.length; i++)
            Positioned(
              left: langkah * i,
              child: UserAvatar(imagePath: images[i], size: size, withRing: true),
            ),
          if (extra > 0)
            Positioned(
              left: langkah * images.length,
              child: Container(
                width: size,
                height: size,
                padding: const EdgeInsets.all(UserAvatar.tebalCincin),
                decoration: BoxDecoration(
                  color: scheme.surface,
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  backgroundColor: scheme.secondaryContainer,
                  foregroundColor: scheme.onSecondaryContainer,
                  // FittedBox mengecilkan "+N" bila avatar kecil atau angkanya panjang.
                  child: Padding(
                    padding: const EdgeInsets.all(UserAvatar.tebalCincin),
                    child: FittedBox(
                      child: Text(
                        '+$extra',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
