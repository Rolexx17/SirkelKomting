/// Teks statis halaman Profil.
class ProfilStrings {
  ProfilStrings._();

  static const ubahProfil = 'Ubah profil';
  static const ubahProfilInfo = 'Fitur ubah profil masih simulasi.';

  static const statSirkel = 'Sirkel';
  static const statJamBelajar = 'Jam belajar';
  static const statLencana = 'Lencana';

  // Angka statistik Nadia dari Bagian 11 brief (belum ada field-nya di model data).
  static const jumlahJamBelajar = '24';
  static const jumlahLencana = '5';

  static const lencanaTerbaru = 'Lencana terbaru';
  static const semua = 'Semua';
  static const semuaLencanaInfo = 'Daftar semua lencana segera hadir (simulasi).';

  static const menuSirkelSaya = 'Sirkel saya';
  static const menuDaftarMentor = 'Daftar jadi mentor';
  static const daftarMentorInfo = 'Pengajuan jadi mentor terkirim (simulasi).';
  static const keluar = 'Keluar';

  static String prodiAngkatan(String prodi, String angkatan) =>
      '$prodi · $angkatan';
}
