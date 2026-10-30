// Fungsi bantu waktu untuk data sirkel. Data contoh menyimpan hari ("Kamis")
// dan jam ("19.00") sebagai teks, jadi perlu diubah ke angka untuk dihitung.

/// Lama satu sesi (menit). Data contoh tidak punya jam selesai; mockup memakai 19.00–20.30.
const durasiSesiMenit = 90;

/// Mengubah nama hari ("Kamis", "Kam") menjadi nomor hari ISO (Senin = 1 … Minggu = 7).
/// Dicocokkan dari 3 huruf pertama agar "Sen" dan "Senin" dianggap sama.
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
