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
    this.catatan = const [],
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

  /// Satu kalimat penjelasan untuk setiap poin [isi] (indeks yang sama).
  /// Ditampilkan di Pembaca Materi; boleh lebih pendek dari [isi].
  final List<String> catatan;

  /// Banyak bagian di Pembaca Materi = banyak poin isi (minimal 1).
  int get jumlahBagian => isi.isEmpty ? 1 : isi.length;

  /// Rentang halaman asli untuk bagian ke-[bagian] (mulai 0). Halaman dibagi rata,
  /// misalnya 12 halaman / 4 bagian → 1–3, 4–6, 7–9, 10–12. Bila halaman lebih
  /// sedikit dari bagian, beberapa bagian berbagi halaman yang sama.
  ({int awal, int akhir}) rentangHalaman(int bagian) {
    final awal = (bagian * halaman) ~/ jumlahBagian + 1;
    final akhir = ((bagian + 1) * halaman) ~/ jumlahBagian;
    return (awal: awal, akhir: akhir < awal ? awal : akhir);
  }
}
