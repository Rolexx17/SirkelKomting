/// Teks statis layar Jelajah dan bottom sheet Filter.
class JelajahStrings {
  JelajahStrings._();

  // Jelajah
  static const judul = 'Jelajah sirkel';
  static const cariHint = 'Cari mata kuliah atau topik';
  static const tooltipFilter = 'Filter';
  static const chipSemua = 'Semua';
  static const chipMingguIni = 'Minggu ini';
  static const kosongJudul = 'Sirkel tidak ditemukan';
  static const kosongPesan = 'Coba kata kunci atau filter lain.';
  static const buatSirkel = 'Buat sirkel';

  // Filter
  static const filterJudul = 'Filter sirkel';
  static const mataKuliah = 'Mata kuliah';
  static const modeBelajar = 'Mode belajar';
  static const modeSemua = 'Semua';
  static const hari = 'Hari';

  /// Kode hari pada chip filter. Dicocokkan dengan 3 huruf pertama `Sirkel.hari`.
  static const daftarHari = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];
  static const hanyaAdaKursi = 'Hanya yang masih ada kursi';
  static const hanyaAdaKursiSub = 'Sembunyikan sirkel yang penuh';
  static const reset = 'Reset';
  static String tampilkan(int n) => 'Tampilkan $n sirkel';
}
