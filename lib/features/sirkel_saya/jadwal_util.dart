// Fungsi bantu tanggal untuk jadwal sesi (Sirkel Saya dan Beranda).
// Ditulis sendiri tanpa paket tambahan sesuai aturan brief.

import 'dart:math' as math;

import '../../data/models/sesi.dart';
import 'sirkel_saya_strings.dart';

/// Sesi terdekat: sesi pertama yang belum lewat dari [sekarang]. Bila semua sudah
/// lewat, dipakai sesi paling awal.
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

/// Selisih hari kalender dari [dari] ke [ke], jam diabaikan (0 = hari yang sama,
/// 1 = besok). Dihitung di UTC agar pergantian jam musim panas tidak membuatnya meleset.
int selisihHari(DateTime dari, DateTime ke) => DateTime.utc(ke.year, ke.month, ke.day)
    .difference(DateTime.utc(dari.year, dari.month, dari.day))
    .inDays;

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

/// Banyak minggu (dimulai Senin) yang tersentuh rentang [sekarang] sampai
/// [sekarang] + [rentangHari]. Contoh: rentang 14 hari dari hari Rabu menyentuh 3 minggu.
int jumlahMinggu(DateTime sekarang, int rentangHari) {
  final akhir = DateTime(sekarang.year, sekarang.month, sekarang.day + rentangHari);
  return selisihHari(seninDari(sekarang), seninDari(akhir)) ~/ 7 + 1;
}

/// "Kamis".
String namaHariDari(DateTime t) => SirkelSayaStrings.namaHari[t.weekday - 1];

/// "Kamis, 9 Oktober".
String tanggalPanjang(DateTime t) => SirkelSayaStrings.tanggal(
      namaHariDari(t),
      t.day,
      SirkelSayaStrings.namaBulan[t.month - 1],
    );

/// "5 Nov".
String tanggalSingkat(DateTime t) => SirkelSayaStrings.tanggalBulan(
      t.day,
      SirkelSayaStrings.namaBulanSingkat[t.month - 1],
    );

/// "19.00" (format jam Indonesia memakai titik).
String jamDari(DateTime t) =>
    '${t.hour.toString().padLeft(2, '0')}.${t.minute.toString().padLeft(2, '0')}';

/// Lama satu sesi; data contoh tidak punya jam selesai (mockup: 19.00–20.30).
const durasiSesi = Duration(minutes: 90);

/// Pengguna boleh masuk mulai 15 menit sebelum sesi dimulai.
const batasMasukAwal = Duration(minutes: 15);

/// true bila [sekarang] berada di rentang 15 menit sebelum mulai sampai sesi selesai.
bool bisaMasukSesi(DateTime waktu, DateTime sekarang) =>
    !sekarang.isBefore(waktu.subtract(batasMasukAwal)) &&
    sekarang.isBefore(waktu.add(durasiSesi));

/// Keterangan kapan sesi dimulai, dihitung dari selisih [waktu] dan [sekarang]:
/// < 60 menit → "Mulai dalam N menit"; < 24 jam → "Mulai dalam N jam";
/// besok → "Besok, 19.00"; ≥ 2 hari → "Mulai N hari lagi".
String teksMulai(DateTime waktu, DateTime sekarang) {
  final selisih = waktu.difference(sekarang);
  if (selisih.inMinutes < 60) {
    // Minimal 1 agar tidak tertulis "Mulai dalam 0 menit".
    return SirkelSayaStrings.mulaiMenit(math.max(1, selisih.inMinutes));
  }
  if (selisih.inHours < 24) return SirkelSayaStrings.mulaiJam(selisih.inHours);

  // Selebihnya dihitung per tanggal kalender, bukan per 24 jam.
  final hari = selisihHari(sekarang, waktu);
  if (hari <= 1) return SirkelSayaStrings.besokJam(jamDari(waktu));
  return SirkelSayaStrings.mulaiHari(hari);
}
