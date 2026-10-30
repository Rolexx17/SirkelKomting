/// Teks statis fitur sirkel: SirkelCard, ModeBadge, Detail Sirkel, dan dialog Gabung.
class SirkelStrings {
  SirkelStrings._();

  // Mode belajar (ModeBadge, chip, segmen filter).
  static const online = 'Online';
  static const offline = 'Offline';

  // SirkelCard
  static String mentorSingkat(String namaDepan) => 'Mentor · $namaDepan';
  static String jadwalSingkat(String hari, String jam) => '$hari, $jam';
  static String kursi(int n) => '$n kursi';

  // Detail Sirkel
  static const kembali = 'Kembali';
  static const simpan = 'Simpan';
  static const disimpan = 'Sirkel disimpan ke daftar simpanan.';
  static String mentorProdi(String prodi, String angkatan) =>
      'Mentor · $prodi $angkatan';
  static const tentang = 'Tentang sirkel';
  static const jadwal = 'Jadwal';
  static const lokasi = 'Lokasi';
  static String jadwalLengkap(String hari, String mulai, String selesai) =>
      'Setiap $hari, $mulai–$selesai';
  static const tautanSetelahGabung = 'Tautan muncul setelah kamu bergabung';
  static const tautanSudahAda = 'Tautan ada di Sirkel saya';
  static String anggota(int jumlah, int kuota) => 'Anggota ($jumlah/$kuota)';
  static const lihat = 'Lihat';
  static const lihatAnggota = 'Daftar lengkap anggota segera hadir.';
  static const kuota = 'Kuota';
  static String kursiTersisa(int n) => '$n kursi tersisa';
  static const kursiPenuh = 'Kursi penuh';
  static const gabung = 'Gabung sirkel';
  static const sudahGabung = 'Sudah bergabung';
  static const tidakDitemukan = 'Sirkel tidak ditemukan.';
  static const tidakDitemukanPesan =
      'Sirkel ini mungkin sudah dihapus. Silakan kembali dan pilih sirkel lain.';

  // Dialog Gabung Berhasil
  static const gabungJudul = 'Kamu resmi gabung!';
  static const sesiPertama = 'Sesi pertama ';
  static String infoOnline(String lokasi) =>
      '. Tautan $lokasi sudah ada di Sirkel saya.';
  static String infoOffline(String lokasi) =>
      '. Lokasinya di $lokasi, jadwalnya sudah ada di Sirkel saya.';
  static const nanti = 'Nanti';
  static const lihatJadwal = 'Lihat jadwal';

  // Format tanggal sesi, misalnya "Kamis, 9 Okt · 19.00".
  static const namaHari = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];
  static const bulanSingkat = [
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
  static String waktuSesi(String hari, int tanggal, String bulan, String jam) =>
      '$hari, $tanggal $bulan · $jam';
}
