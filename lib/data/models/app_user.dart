/// Data seorang pengguna Sirkel (peserta atau mentor).
class AppUser {
  const AppUser({
    required this.id,
    required this.nama,
    required this.prodi,
    required this.angkatan,
    required this.avatar,
    this.isMentor = false,
    this.rating,
  });

  final String id;
  final String nama;
  final String prodi;
  final String angkatan;

  /// Path gambar avatar dari `AppAssets`.
  final String avatar;
  final bool isMentor;

  /// Hanya mentor yang punya rating, karena itu nullable.
  final double? rating;
}
