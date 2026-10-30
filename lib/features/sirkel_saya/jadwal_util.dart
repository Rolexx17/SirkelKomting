// Fungsi bantu tanggal untuk jadwal sesi (Sirkel Saya dan kartu Hari ini di Beranda).
// Ditulis sendiri tanpa paket tambahan sesuai aturan brief.

import '../../data/models/sesi.dart';
import 'sirkel_saya_strings.dart';

/// Sesi terdekat: sesi pertama yang belum lewat dari [sekarang]. Bila semua sudah
/// lewat (data contoh memakai Oktober 2025), dipakai sesi paling awal.
Sesi? sesiTerdekat(List<Sesi> daftar, DateTime sekarang) {
  if (daftar.isEmpty) return null;
  final urut = [...daftar]..sort((a, b) => a.waktu.compareTo(b.waktu));
  for (final sesi in urut) {
    if (!sesi.waktu.isBefore(sekarang)) return sesi;
  }
  return urut.first;
}

/// Tanggal tanpa jam, dipakai untuk membandingkan hari.
DateTime awalHari(DateTime t) => DateTime(t.year, t.month, t.day);

bool hariSama(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// Senin pada minggu yang memuat [t]. `weekday` bernilai Senin = 1 … Minggu = 7,
/// jadi mundur (weekday - 1) hari. DateTime otomatis menyesuaikan pergantian bulan.
DateTime seninDari(DateTime t) =>
    DateTime(t.year, t.month, t.day - (t.weekday - 1));

/// Tujuh tanggal Senin–Minggu pada minggu yang memuat [t].
List<DateTime> mingguDari(DateTime t) {
  final senin = seninDari(t);
  return List.generate(
    7,
    (i) => DateTime(senin.year, senin.month, senin.day + i),
  );
}

/// "Kamis, 9 Oktober".
String tanggalPanjang(DateTime t) => SirkelSayaStrings.tanggal(
      SirkelSayaStrings.namaHari[t.weekday - 1],
      t.day,
      SirkelSayaStrings.namaBulan[t.month - 1],
    );

/// "19.00" (format jam Indonesia memakai titik).
String jamDari(DateTime t) =>
    '${t.hour.toString().padLeft(2, '0')}.${t.minute.toString().padLeft(2, '0')}';

/// Nama hari lengkap ("Kamis") menjadi nomor weekday (4); null bila tidak dikenal.
int? nomorHariDariNama(String hari) {
  final i = SirkelSayaStrings.namaHari.indexOf(hari.trim());
  return i == -1 ? null : i + 1;
}
