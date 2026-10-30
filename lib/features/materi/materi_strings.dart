/// Teks statis Ruang Materi, Detail Materi, dan MateriCard.
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
  static const bukaMateri = 'Buka materi';
  static const disimpan = 'Materi disimpan ke daftar simpanan.';
  static const isiMateri = 'Isi materi';
  static String infoPengunggah(bool isMentor, String waktu) =>
      '${isMentor ? 'Mentor' : 'Peserta'} · dibagikan $waktu';
  static const tidakDitemukan = 'Materi tidak ditemukan';
  static const tidakDitemukanPesan =
      'Materi ini mungkin sudah dihapus. Silakan kembali dan pilih materi lain.';
}
