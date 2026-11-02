import 'package:flutter/material.dart';

/// Foto profil bulat dari aset. Bila [imagePath] kosong (akun baru tanpa foto),
/// tampil inisial dari [nama], atau ikon orang bila nama juga tidak ada.
/// [withRing] menambah cincin 2 px berwarna surface untuk avatar bertumpuk.
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.imagePath,
    this.size = 44,
    this.withRing = false,
    this.nama,
  });

  /// Path aset dari `AppAssets`; string kosong berarti belum ada foto.
  final String imagePath;

  /// Diameter total avatar (termasuk cincin bila ada).
  final double size;
  final bool withRing;

  /// Nama pemilik avatar, dipakai untuk inisial saat tidak ada foto.
  final String? nama;

  /// Tebal cincin; juga dipakai lingkaran "+N" di AvatarStack.
  static const tebalCincin = 2.0;

  /// Perbandingan ukuran huruf inisial / ikon terhadap diameter avatar.
  static const _rasioIsi = 0.42;

  /// Maksimal dua huruf kapital dari kata pertama dan kedua:
  /// "Budi Santoso" → "BS", "nadia" → "N", "  " → "".
  static String inisial(String nama) {
    final kata = nama.trim().split(RegExp(r'\s+')).where((k) => k.isNotEmpty);
    return kata.take(2).map((k) => k[0].toUpperCase()).join();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    // Ukuran total tetap [size]: cincin mengambil 2 px dari tepi, bukan menambah ukuran.
    final diameterFoto = withRing ? size - tebalCincin * 2 : size;

    final avatar = imagePath.isEmpty
        ? _tanpaFoto(scheme, diameterFoto)
        // P3: CircleAvatar memotong gambar menjadi lingkaran.
        : CircleAvatar(
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

  Widget _tanpaFoto(ColorScheme scheme, double diameter) {
    final huruf = nama == null ? '' : inisial(nama!);
    final ukuranIsi = diameter * _rasioIsi;

    return CircleAvatar(
      radius: diameter / 2,
      backgroundColor: scheme.primaryContainer,
      foregroundColor: scheme.onPrimaryContainer,
      child: huruf.isEmpty
          ? Icon(Icons.person, size: ukuranIsi * 1.4)
          : Text(
              huruf,
              maxLines: 1,
              style: TextStyle(fontSize: ukuranIsi, fontWeight: FontWeight.w600),
            ),
    );
  }
}
