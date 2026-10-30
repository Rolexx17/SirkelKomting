/// Teks statis layar Sirkel Saya, termasuk nama hari dan bulan untuk format tanggal.
class SirkelSayaStrings {
  SirkelSayaStrings._();

  static const judul = 'Sirkel saya';
  static const jadwal = 'Jadwal';
  static String sirkel(int jumlah) => 'Sirkel ($jumlah)';

  static const mulaiSatuJam = 'Mulai dalam 1 jam';
  static const masukSesi = 'Masuk sesi';
  static String masukSesiInfo(String mataKuliah) =>
      'Membuka sesi $mataKuliah (simulasi).';

  static const jadwalKosongJudul = 'Belum ada jadwal';
  static const jadwalKosongPesan = 'Gabung sirkel untuk melihat jadwal sesimu.';
  static const sirkelKosongJudul = 'Belum ikut sirkel';
  static const sirkelKosongPesan = 'Temukan sirkel di tab Jelajah.';

  // Format tanggal Indonesia tanpa paket intl. Urutan mengikuti DateTime.weekday
  // (Senin = 1) dan DateTime.month (Januari = 1), jadi indeksnya dikurangi 1.
  static const namaHari = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];
  static const namaHariSingkat = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
  static const namaBulan = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  /// Contoh: "Kamis, 9 Oktober".
  static String tanggal(String hari, int tanggal, String bulan) =>
      '$hari, $tanggal $bulan';
}
