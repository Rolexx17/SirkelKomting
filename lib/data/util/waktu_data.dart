// Parser hari & jam untuk data sirkel. Data menyimpan hari ("Senin & Rabu") dan
// jam ("19.00") sebagai teks, jadi perlu diubah ke angka agar bisa dihitung.
// Sengaja ditulis di folder data/ supaya model tidak bergantung pada file fitur.

/// Kode 3 huruf pertama nama hari, urut Senin (1) … Minggu (7) seperti `DateTime.weekday`.
const _kodeHari = ['sen', 'sel', 'rab', 'kam', 'jum', 'sab', 'min'];

/// Mengubah teks hari menjadi daftar nomor hari ISO, terurut dan tanpa duplikat.
///
/// Contoh: "Kamis" → [4], "Senin & Rabu" → [1, 3], "Senin, Rabu & Jumat" → [1, 3, 5].
/// Pemisah yang dikenali: koma dan "&". Nama yang tidak dikenal dilewati.
List<int> nomorHariDariTeks(String hari) {
  final hasil = <int>{};
  for (final bagian in hari.split(RegExp(r'[,&]'))) {
    final kata = bagian.trim().toLowerCase();
    if (kata.length < 3) continue;
    final i = _kodeHari.indexOf(kata.substring(0, 3));
    if (i != -1) hasil.add(i + 1);
  }
  return hasil.toList()..sort();
}

/// Membaca jam "19.00" (atau "19:00") menjadi menit sejak tengah malam; null bila format salah.
int? menitDariJam(String jam) {
  final bagian = jam.trim().split(RegExp('[.:]'));
  if (bagian.length != 2) return null;
  final j = int.tryParse(bagian[0]);
  final m = int.tryParse(bagian[1]);
  if (j == null || m == null || j < 0 || j > 23 || m < 0 || m > 59) return null;
  return j * 60 + m;
}
