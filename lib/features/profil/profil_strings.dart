/// Teks statis halaman Profil.
class ProfilStrings {
  ProfilStrings._();

  static const peranPeserta = 'Peserta';
  static const peranMentor = 'Mentor';
  static const peranMenunggu = 'Menunggu tinjauan';
  static String prodiAngkatan(String prodi, String angkatan) =>
      '$prodi · $angkatan';

  // Statistik (angkanya dibaca dari DummyData)
  static const statSirkel = 'Sirkel';
  static const statJamBelajar = 'Jam belajar';
  static const statLencana = 'Lencana';

  // Lencana
  static const lencanaTerbaru = 'Lencana terbaru';
  static const semua = 'Semua';
  static const semuaLencanaJudul = 'Semua lencana';
  static String lencanaTerkumpul(int jumlah) => '$jumlah lencana terkumpul';

  // Ubah profil
  static const ubahProfil = 'Ubah profil';
  static const simpan = 'Simpan';
  static const profilDiperbarui = 'Profil diperbarui';

  // Menu
  static const menuSirkelSaya = 'Sirkel saya';
  static const menuSimpanan = 'Simpanan';
  static const menuDaftarMentor = 'Daftar jadi mentor';
  static const mentorDitinjau = 'Pengajuan mentor sedang ditinjau';
  static const mentorDitinjauSub = 'Hasilnya dikirim ke email kampusmu';
  static const sudahMentor = 'Kamu terdaftar sebagai mentor';
  static const keluar = 'Keluar';
  static const batal = 'Batal';

  // Dialog konfirmasi
  static const daftarMentorJudul = 'Daftar jadi mentor?';
  static const daftarMentorIsi =
      'Pengajuanmu akan ditinjau tim Sirkel, lalu hasilnya dikirim ke email kampusmu.';
  static const ajukan = 'Ajukan';
  static const pengajuanTerkirim = 'Pengajuan terkirim';
  static const keluarJudul = 'Keluar dari akun?';
  static const keluarIsi =
      'Kamu perlu masuk lagi untuk melihat sirkel dan jadwalmu.';

  // Halaman Simpanan
  static const simpananJudul = 'Simpanan';
  static String tabSirkel(int jumlah) => 'Sirkel ($jumlah)';
  static String tabMateri(int jumlah) => 'Materi ($jumlah)';
  static const sirkelKosongJudul = 'Belum ada sirkel tersimpan';
  static const sirkelKosongPesan = 'Ketuk ikon simpan di Detail Sirkel.';
  static const materiKosongJudul = 'Belum ada materi tersimpan';
  static const materiKosongPesan = 'Ketuk Simpan di Detail Materi.';
}
