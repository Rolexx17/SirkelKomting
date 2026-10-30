import 'auth_strings.dart';

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

  static String? nama(String? nilai) {
    final teks = nilai?.trim() ?? '';
    return teks.isEmpty ? AuthStrings.namaWajib : null;
  }
}
