import 'package:flutter/material.dart';

/// Foto profil bulat dari aset. [withRing] menambah cincin 2 px berwarna surface
/// agar avatar yang bertumpuk (AvatarStack) tetap terlihat terpisah.
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.imagePath,
    this.size = 44,
    this.withRing = false,
  });

  /// Path aset dari `AppAssets`.
  final String imagePath;

  /// Diameter total avatar (termasuk cincin bila ada).
  final double size;
  final bool withRing;

  /// Tebal cincin; juga dipakai lingkaran "+N" di AvatarStack.
  static const tebalCincin = 2.0;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    // Ukuran total tetap [size]: cincin mengambil 2 px dari tepi, bukan menambah ukuran.
    final diameterFoto = withRing ? size - tebalCincin * 2 : size;

    // P3: CircleAvatar memotong gambar menjadi lingkaran.
    final avatar = CircleAvatar(
      radius: diameterFoto / 2,
      backgroundColor: scheme.surfaceContainerHighest,
      backgroundImage: AssetImage(imagePath),
      // Bila aset gagal dimuat, cukup tampil lingkaran polos tanpa layar error.
      onBackgroundImageError: (error, stackTrace) {},
    );

    if (!withRing) return avatar;

    // P5: Container bulat berwarna surface menjadi cincin di sekeliling foto.
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(tebalCincin),
      decoration: BoxDecoration(color: scheme.surface, shape: BoxShape.circle),
      child: avatar,
    );
  }
}
