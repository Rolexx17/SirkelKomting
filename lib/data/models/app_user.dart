/// Status pengguna sebagai mentor: peserta biasa, sedang mengajukan, atau sudah mentor.
enum StatusMentor { peserta, menunggu, mentor }

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

  /// Path gambar avatar dari `AppAssets`; string kosong berarti belum punya foto
  /// (UserAvatar lalu menampilkan inisial nama).
  final String avatar;
  final bool isMentor;

  /// Hanya mentor yang punya rating, karena itu nullable.
  final double? rating;

  /// Salinan dengan nama, prodi, peran, atau avatar baru (dipakai Daftar dan Ubah profil).
  /// Id, angkatan, dan rating tetap sama.
  AppUser copyWith({
    String? nama,
    String? prodi,
    bool? isMentor,
    String? avatar,
  }) {
    return AppUser(
      id: id,
      nama: nama ?? this.nama,
      prodi: prodi ?? this.prodi,
      angkatan: angkatan,
      avatar: avatar ?? this.avatar,
      isMentor: isMentor ?? this.isMentor,
      rating: rating,
    );
  }
}
