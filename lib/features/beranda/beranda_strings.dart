/// Teks statis layar Beranda, kartu sesi berikutnya, dan sheet Atur mata kuliah.
class BerandaStrings {
  BerandaStrings._();

  // Sapaan sesuai jam.
  static const pagi = 'Selamat pagi,';
  static const siang = 'Selamat siang,';
  static const sore = 'Selamat sore,';
  static const malam = 'Selamat malam,';

  static const tooltipNotifikasi = 'Notifikasi';

  // Label kartu sesi berikutnya: "HARI INI", "BESOK", atau "KAMIS, 5 NOV".
  static const hariIni = 'HARI INI';
  static const besok = 'BESOK';
  static String labelTanggal(String hari, String tanggal) =>
      '$hari, $tanggal'.toUpperCase();

  static String topikMentor(String judul, String mentor) => '$judul · $mentor';
  static String jamMode(String jam, String mode) => '$jam · $mode';
  static const online = 'Online';
  static const offline = 'Offline';
  static const masukSesi = 'Masuk sesi';
  static const detailSesi = 'Detail sesi';

  // Mata kuliah (carousel) dan sheet Atur
  static const mataKuliahmu = 'Mata kuliahmu';
  static const atur = 'Atur';
  static const aturJudul = 'Atur mata kuliah';
  static const aturPesan =
      'Pilih mata kuliah yang tampil di Beranda (minimal satu).';
  static const simpan = 'Simpan';
  static const aturTersimpan = 'Mata kuliahmu diperbarui.';

  // Jadwal terdekat (layar lebar ≥ 840)
  static const jadwalTerdekat = 'Jadwal terdekat';
  /// Contoh: "Kamis, 5 Nov · 19.00".
  static String jadwalRingkas(String hari, String tanggal, String jam) =>
      '$hari, $tanggal · $jam';

  // Rekomendasi
  static const rekomendasi = 'Rekomendasi untukmu';
  static const lihatSemua = 'Lihat semua';
}
