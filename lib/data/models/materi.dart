import 'app_user.dart';

/// Materi belajar (catatan/rangkuman) yang dibagikan di sebuah sirkel.
class Materi {
  const Materi({
    required this.id,
    required this.judul,
    required this.format,
    required this.mataKuliah,
    required this.cover,
    required this.waktu,
    required this.halaman,
    required this.pengunggah,
    required this.isi,
  });

  final String id;
  final String judul;

  /// Jenis berkas, misalnya "PDF" atau "PNG".
  final String format;
  final String mataKuliah;
  final String cover;

  /// Waktu dibagikan dalam bentuk teks, misalnya "2 hari lalu".
  final String waktu;
  final int halaman;
  final AppUser pengunggah;

  /// Daftar pokok bahasan, ditampilkan bernomor di Detail Materi.
  final List<String> isi;
}
