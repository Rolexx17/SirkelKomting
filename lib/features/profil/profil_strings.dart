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
  static const lencanaJudul = 'Lencana';
  static const semua = 'Semua';
  static const semuaLencanaJudul = 'Semua lencana';
  static String lencanaTerkumpul(int didapat, int total) =>
      '$didapat dari $total lencana didapat';
  static String progres(int nilai, int target) => '$nilai/$target';
  static const didapat = 'Sudah didapat';
  static const belumDidapat = 'Belum didapat';
  static const syaratLabel = 'Syarat';
  static String sisaMenujuLencana(int sisa) => 'Kurang $sisa lagi';

  // Nama dan syarat lencana (target dihitung di lencana_progres.dart)
  static const lencanaSesiPertama = 'Sesi Pertama';
  static const syaratSesiPertama = 'Bergabung ke 1 sirkel';
  static const lencanaRajinHadir = 'Rajin Hadir';
  static String syaratRajinHadir(int jam) => 'Mengumpulkan $jam jam belajar';
  static const lencanaAnggotaAktif = 'Anggota Aktif';
  static String syaratAnggotaAktif(int n) => 'Mengikuti $n sirkel sekaligus';
  static const lencanaKolektorMateri = 'Kolektor Materi';
  static String syaratKolektorMateri(int n) => 'Menyimpan $n materi';
  static const lencanaPenjelajah = 'Penjelajah';
  static String syaratPenjelajah(int n) => 'Menyimpan $n sirkel';
  static const lencanaMentorSebaya = 'Mentor Sebaya';
  static const syaratMentorSebaya = 'Pengajuan mentor disetujui';

  // Ubah profil
  static const ubahProfil = 'Ubah profil';
  static const simpan = 'Simpan';
  static const profilDiperbarui = 'Profil diperbarui';

  // Menu
  static const menuSirkelSaya = 'Sirkel saya';
  static const menuSimpanan = 'Simpanan';
  static const menuDaftarMentor = 'Daftar jadi mentor';
  static const mentorDitinjau = 'Pengajuan mentor sedang ditinjau';
  static const mentorDitinjauSub = 'Kabar persetujuannya muncul di Notifikasi';
  static const sudahMentor = 'Kamu terdaftar sebagai mentor';
  static const keluar = 'Keluar';
  static const batal = 'Batal';

  // Dialog konfirmasi
  static const daftarMentorJudul = 'Daftar jadi mentor?';
  static const daftarMentorIsi =
      'Pengajuanmu akan ditinjau tim Sirkel. Setelah disetujui, kamu bisa membuat sirkel.';
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
  static const petunjukGeser = 'Geser kartu ke kiri untuk menghapus dari simpanan.';
  static const sirkelDihapus = 'Sirkel dihapus dari simpanan';
  static const materiDihapus = 'Materi dihapus dari simpanan';
  static const urungkan = 'Urungkan';
}
