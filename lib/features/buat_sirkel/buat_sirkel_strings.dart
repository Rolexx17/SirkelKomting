/// Teks statis layar Buat Sirkel dan bottom sheet pemilih sampul.
class BuatSirkelStrings {
  BuatSirkelStrings._();

  static const judulHalaman = 'Buat sirkel';
  static const pilihSampul = 'Pilih sampul sirkel';
  static const gantiSampul = 'Ketuk untuk mengganti sampul';

  static const mataKuliah = 'Mata kuliah';
  static const mataKuliahWajib = 'Pilih mata kuliah terlebih dahulu';

  static const judulSirkel = 'Judul sirkel';
  static const judulWajib = 'Judul sirkel wajib diisi';

  static const modeBelajar = 'Mode belajar';
  static const online = 'Online';
  static const offline = 'Offline';

  static const hari = 'Hari';
  static const hariWajib = 'Pilih minimal satu hari';

  /// Kode hari pada chip dan nama lengkapnya (urutannya harus sama).
  static const kodeHari = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum'];
  static const namaHari = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat'];

  static const jam = 'Jam';
  static const jamWajib = 'Jam wajib diisi';
  static const jamFormat = 'Format HH.MM, misalnya 16.00';
  static const pilihJam = 'Pilih jam sesi';

  static const kuota = 'Kuota';
  static const kurangiKuota = 'Kurangi kuota';
  static const tambahKuota = 'Tambah kuota';

  static const terbitkan = 'Terbitkan sirkel';
  static const berhasil = 'Sirkel berhasil diterbitkan';

  // Pintu masuk Buat Sirkel (hanya untuk mentor yang sudah disetujui)
  static const khususMentorJudul = 'Khusus mentor';
  static const khususMentorPesan =
      'Hanya mentor yang bisa membuat sirkel. Ajukan diri jadi mentor; '
      'setelah disetujui, kamu bisa langsung membuat sirkel.';
  static const nanti = 'Nanti';
  static const ajukanMentor = 'Ajukan jadi mentor';
  static const pengajuanTerkirim = 'Pengajuan mentor dikirim. Tunggu persetujuan, ya.';
  static const ditinjauJudul = 'Pengajuan sedang ditinjau';
  static const ditinjauPesan =
      'Kamu bisa membuat sirkel setelah pengajuan mentor disetujui. '
      'Kabarnya akan muncul di Notifikasi.';
  static const mengerti = 'Mengerti';

  // Bottom sheet pemilih sampul
  static const sheetJudul = 'Pilih sampul';
}
