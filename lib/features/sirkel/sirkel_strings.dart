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
  static const tandaDisimpan = 'Disimpan';

  // Detail Sirkel
  static const kembali = 'Kembali';
  static const simpan = 'Simpan';
  static const hapusSimpanan = 'Hapus dari simpanan';
  static const disimpan = 'Sirkel disimpan.';
  static const dihapusDariSimpanan = 'Sirkel dihapus dari simpanan.';
  static String mentorProdi(String prodi, String angkatan) =>
      'Mentor · $prodi $angkatan';
  static const tentang = 'Tentang sirkel';
  static const jadwal = 'Jadwal';
  static const lokasi = 'Lokasi';
  static String jadwalLengkap(String hari, String mulai, String selesai) =>
      'Setiap $hari, $mulai–$selesai';
  static const tautanSetelahGabung = 'Tautan muncul setelah kamu bergabung';
  static const tautanDariMentor = 'Tautan dibagikan mentor sebelum sesi dimulai';
  static const tautanUntukMentor = 'Bagikan tautan ke anggota sebelum sesi dimulai';
  static String anggota(int jumlah, int kuota) => 'Anggota ($jumlah/$kuota)';
  static const lihat = 'Lihat';

  // Sheet daftar anggota
  static const labelMentor = 'Mentor';
  static String prodiAngkatan(String prodi, String angkatan) =>
      '$prodi · $angkatan';
  static const belumAdaAnggota = 'Belum ada anggota';
  static const belumAdaAnggotaPesan =
      'Anggota yang bergabung akan muncul di sini.';

  static const kuota = 'Kuota';
  static String kursiTersisa(int n) => '$n kursi tersisa';
  static const kursiPenuh = 'Kursi penuh';
  static const gabung = 'Gabung sirkel';
  static const sudahGabung = 'Sudah bergabung';
  static const kamuMentor = 'Kamu mentor sirkel ini';
  static const kamuAnggota = 'Kamu anggota sirkel ini';
  static const keluarSirkel = 'Keluar sirkel';
  static const keluarBerhasil = 'Kamu keluar dari sirkel';

  // Dialog konfirmasi keluar
  static String keluarJudul(String judul) => 'Keluar dari $judul?';
  static const keluarPesan = 'Jadwal sirkel ini akan dihapus dari Sirkel saya.';
  static const batal = 'Batal';
  static const keluar = 'Keluar';
  static const tidakDitemukan = 'Sirkel tidak ditemukan.';
  static const tidakDitemukanPesan =
      'Sirkel ini mungkin sudah dihapus. Silakan kembali dan pilih sirkel lain.';

  // Dialog Gabung Berhasil
  static const gabungJudul = 'Kamu resmi gabung!';
  static const sesiPertama = 'Sesi pertama ';
  static String infoOnline(String lokasi) =>
      '. Tautan $lokasi dibagikan mentor sebelum sesi, jadwalnya sudah ada di Sirkel saya.';
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
