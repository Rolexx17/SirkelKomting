/// Teks statis layar Sirkel Saya, termasuk nama hari dan bulan untuk format tanggal.
class SirkelSayaStrings {
  SirkelSayaStrings._();

  static const judul = 'Sirkel saya';
  static const jadwal = 'Jadwal';
  static String sirkel(int jumlah) => 'Sirkel ($jumlah)';

  // Navigasi minggu pada strip hari
  static const mingguSebelumnya = 'Minggu sebelumnya';
  static const mingguBerikutnya = 'Minggu berikutnya';
  static String rentangMinggu(String awal, String akhir) => '$awal – $akhir';

  // Penyaring tanggal
  static const tampilkanSemua = 'Tampilkan semua';
  static const tidakAdaSesiJudul = 'Tidak ada sesi di hari ini';
  static const tidakAdaSesiPesan =
      'Pilih tanggal lain atau tampilkan semua jadwal.';

  // Keterangan waktu mulai sesi terdekat
  static String mulaiMenit(int menit) => 'Mulai dalam $menit menit';
  static String mulaiJam(int jam) => 'Mulai dalam $jam jam';
  static String besokJam(String jam) => 'Besok, $jam';
  static String hariJam(String hari, String jam) => '$hari, $jam';

  static const masukSesi = 'Masuk sesi';
  static String masukSesiInfo(String mataKuliah, String lokasi) =>
      'Membuka $lokasi untuk sesi $mataKuliah (simulasi, tanpa server).';

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
  static const namaBulanSingkat = [
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

  /// Contoh: "Kamis, 9 Oktober".
  static String tanggal(String hari, int tanggal, String bulan) =>
      '$hari, $tanggal $bulan';

  /// Contoh: "5 Nov".
  static String tanggalBulan(int tanggal, String bulan) => '$tanggal $bulan';
}
