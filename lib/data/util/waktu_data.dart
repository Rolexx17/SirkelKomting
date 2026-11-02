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

const _namaHari = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
const _namaBulan = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'Mei',
  'Jun',
  'Jul',
  'Agu',
  'Sep',
  'Okt',
  'Nov',
  'Des',
];

/// Label tanggal sesi relatif terhadap [sekarang]: "Hari ini", "Besok", atau
/// "Rabu, 4 Nov". Hanya tanggal yang dibandingkan, jam diabaikan.
String labelHariSesi(DateTime sesi, DateTime sekarang) {
  // Memakai tanggal UTC agar selisih hari tidak terganggu pergantian jam musim panas.
  final hariSesi = DateTime.utc(sesi.year, sesi.month, sesi.day);
  final hariIni = DateTime.utc(sekarang.year, sekarang.month, sekarang.day);
  final selisih = hariSesi.difference(hariIni).inDays;
  if (selisih == 0) return 'Hari ini';
  if (selisih == 1) return 'Besok';
  return '${_namaHari[sesi.weekday - 1]}, ${sesi.day} ${_namaBulan[sesi.month - 1]}';
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
