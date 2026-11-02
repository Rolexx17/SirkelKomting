import 'auth_strings.dart';

/// Tingkat kekuatan kata sandi untuk indikator di layar Daftar.
enum KekuatanSandi { lemah, sedang, kuat }

/// Aturan validasi form Masuk dan Daftar. Mengembalikan pesan error, atau null bila valid.
class AuthValidator {
  AuthValidator._();

  static const panjangMinSandi = 6;

  // Email kampus: ada teks sebelum "@", ada nama domain, dan diakhiri ".ac.id".
  static final _polaEmailKampus = RegExp(
    r'^[^@\s]+@[^@\s]+\.ac\.id$',
    caseSensitive: false,
  );

  static String? email(String? nilai) {
    final teks = nilai?.trim() ?? '';
    if (teks.isEmpty) return AuthStrings.emailWajib;
    if (!_polaEmailKampus.hasMatch(teks)) return AuthStrings.emailTidakValid;
    return null;
  }

  static String? kataSandi(String? nilai) {
    final teks = nilai ?? '';
    if (teks.isEmpty) return AuthStrings.sandiWajib;
    if (teks.length < panjangMinSandi) return AuthStrings.sandiMinimal;
    return null;
  }

  /// Menilai kekuatan kata sandi dari 4 kriteria: panjang ≥ 8, huruf besar dan
  /// kecil, angka, dan simbol. Sandi kurang dari [panjangMinSandi] selalu lemah.
  /// Skor 0–1 → lemah, 2–3 → sedang, 4 → kuat.
  static KekuatanSandi kekuatanSandi(String sandi) {
    if (sandi.length < panjangMinSandi) return KekuatanSandi.lemah;
    final skor = [
      sandi.length >= 8,
      sandi.contains(RegExp('[a-z]')) && sandi.contains(RegExp('[A-Z]')),
      sandi.contains(RegExp('[0-9]')),
      sandi.contains(RegExp(r'[^A-Za-z0-9]')),
    ].where((terpenuhi) => terpenuhi).length;
    if (skor <= 1) return KekuatanSandi.lemah;
    return skor == 4 ? KekuatanSandi.kuat : KekuatanSandi.sedang;
  }

  static String? nama(String? nilai) {
    final teks = nilai?.trim() ?? '';
    return teks.isEmpty ? AuthStrings.namaWajib : null;
  }
}
