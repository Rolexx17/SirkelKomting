/// Teks statis Ruang Materi, Detail Materi, Pembaca Materi, dan MateriCard.
class MateriStrings {
  MateriStrings._();

  // Ruang Materi
  static const judul = 'Ruang materi';
  static const subjudul = 'Catatan & rangkuman dari sirkel yang kamu ikuti.';
  static const semua = 'Semua';
  static const kosongJudul = 'Belum ada materi';
  static const kosongPesan = 'Materi untuk mata kuliah ini belum dibagikan.';

  // MateriCard & Detail Materi
  static String formatHalaman(String format, int halaman) =>
      '$format · $halaman hlm';

  // Detail Materi
  static const simpan = 'Simpan';
  static const tersimpan = 'Tersimpan';
  static const tooltipSimpan = 'Simpan materi';
  static const tooltipBatalSimpan = 'Hapus dari simpanan';
  static const disimpan = 'Materi disimpan';
  static const dihapusDariSimpanan = 'Materi dihapus dari simpanan';
  static const bukaMateri = 'Buka materi';
  static const isiMateri = 'Isi materi';
  static String infoPengunggah(bool isMentor, String waktu) =>
      '${isMentor ? 'Mentor' : 'Peserta'} · dibagikan $waktu';
  static const tidakDitemukan = 'Materi tidak ditemukan';
  static const tidakDitemukanPesan =
      'Materi ini mungkin sudah dihapus. Silakan kembali dan pilih materi lain.';

  // Pembaca Materi
  static String indikatorHalaman(int ke, int total) => 'Halaman $ke dari $total';
  static String judulHalaman(int ke) => 'Halaman $ke';
  static String labelThumbnail(int ke) => '$ke';
  static const sebelumnya = 'Sebelumnya';
  static const berikutnya = 'Berikutnya';
  static const selesai = 'Selesai';
}
