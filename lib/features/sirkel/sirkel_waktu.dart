// Fungsi bantu waktu untuk data sirkel. Data contoh menyimpan hari ("Kamis")
// dan jam ("19.00") sebagai teks, jadi perlu diubah ke angka untuk dihitung.

import '../../data/models/sirkel.dart';

/// Lama satu sesi (menit). Data contoh tidak punya jam selesai; mockup memakai 19.00–20.30.
const durasiSesiMenit = 90;

/// Mengubah kode hari chip Filter ("Kam") atau satu nama hari ("Kamis") menjadi
/// nomor hari ISO (Senin = 1 … Minggu = 7). Untuk hari sebuah sirkel (bisa
/// "Senin & Rabu") pakai `Sirkel.daftarNomorHari` milik model.
int? nomorHari(String hari) {
  const kode = ['sen', 'sel', 'rab', 'kam', 'jum', 'sab', 'min'];
  final awal = hari.trim().toLowerCase();
  if (awal.length < 3) return null;
  final i = kode.indexOf(awal.substring(0, 3));
  return i == -1 ? null : i + 1;
}

/// Membaca jam "19.00" atau "19:00" menjadi menit sejak tengah malam.
int? bacaJam(String jam) {
  final bagian = jam.trim().split(RegExp('[.:]'));
  if (bagian.length != 2) return null;
  final j = int.tryParse(bagian[0]);
  final m = int.tryParse(bagian[1]);
  if (j == null || m == null) return null;
  return j * 60 + m;
}

/// Menulis menit sejak tengah malam sebagai "HH.mm".
String tulisJam(int menit) {
  final j = (menit ~/ 60) % 24;
  final m = menit % 60;
  return '${j.toString().padLeft(2, '0')}.${m.toString().padLeft(2, '0')}';
}

/// Jam selesai = jam mulai + [durasiSesiMenit]. Mengembalikan teks asli bila format tidak dikenal.
String jamSelesai(String jamMulai) {
  final mulai = bacaJam(jamMulai);
  return mulai == null ? jamMulai : tulisJam(mulai + durasiSesiMenit);
}

/// Mencari sirkel di [diikuti] yang jadwalnya bertabrakan dengan [target].
///
/// Dua sesi bentrok bila (1) ada hari yang sama, termasuk sirkel multi-hari
/// seperti "Senin & Rabu", dan (2) rentang jamnya tumpang tindih:
/// mulaiA < selesaiB dan mulaiB < selesaiA (selesai = mulai + [durasiSesiMenit]).
/// Sesi yang berurutan pas (selesai 20.30, berikutnya mulai 20.30) tidak dihitung bentrok.
/// Mengembalikan sirkel pertama yang bentrok, atau null bila aman.
Sirkel? cariBentrok(Sirkel target, Iterable<Sirkel> diikuti) {
  final mulaiTarget = bacaJam(target.jam);
  if (mulaiTarget == null) return null;
  final hariTarget = target.daftarNomorHari;

  for (final s in diikuti) {
    if (s.id == target.id) continue;
    final mulai = bacaJam(s.jam);
    if (mulai == null) continue;

    final hariSama = s.daftarNomorHari.any(hariTarget.contains);
    final tumpangTindih = mulaiTarget < mulai + durasiSesiMenit &&
        mulai < mulaiTarget + durasiSesiMenit;
    if (hariSama && tumpangTindih) return s;
  }
  return null;
}
