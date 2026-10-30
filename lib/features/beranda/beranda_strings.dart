/// Teks statis layar Beranda dan kartu Hari ini.
class BerandaStrings {
  BerandaStrings._();

  // Sapaan sesuai jam.
  static const pagi = 'Selamat pagi,';
  static const siang = 'Selamat siang,';
  static const sore = 'Selamat sore,';
  static const malam = 'Selamat malam,';

  static const tooltipNotifikasi = 'Notifikasi';

  // Kartu Hari ini
  static const hariIni = 'HARI INI';
  static String topikMentor(String judul, String mentor) => '$judul · $mentor';
  static String jamMode(String jam, String mode) => '$jam · $mode';
  static const online = 'Online';
  static const offline = 'Offline';
  static const masukSesi = 'Masuk sesi';

  // Bagian mata kuliah dan rekomendasi
  static const mataKuliahmu = 'Mata kuliahmu';
  static const atur = 'Atur';
  static const aturInfo = 'Pengaturan mata kuliah segera hadir.';
  static const rekomendasi = 'Rekomendasi untukmu';
  static const lihatSemua = 'Lihat semua';
}
