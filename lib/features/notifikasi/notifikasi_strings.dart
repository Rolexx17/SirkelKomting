import 'notifikasi_screen.dart';

/// Teks statis layar Notifikasi.
class NotifikasiStrings {
  NotifikasiStrings._();

  static const judul = 'Notifikasi';
  static const tandaiDibaca = 'Tandai dibaca';
  static const kosongJudul = 'Belum ada notifikasi';
  static const kosongPesan = 'Kabar dari sirkelmu akan muncul di sini.';

  static const geserDibaca = 'Tandai sudah dibaca';

  // Filter kategori
  static const kategoriKosongJudul = 'Tidak ada notifikasi';
  static const kategoriKosongPesan = 'Belum ada kabar di kategori ini.';

  /// Label chip, misalnya "Sesi · 1"; tanpa angka bila semua sudah dibaca.
  static String labelKategori(KategoriNotifikasi k, int belumDibaca) {
    final nama = switch (k) {
      KategoriNotifikasi.semua => 'Semua',
      KategoriNotifikasi.sesi => 'Sesi',
      KategoriNotifikasi.sirkel => 'Sirkel',
      KategoriNotifikasi.akun => 'Akun',
    };
    return belumDibaca > 0 ? '$nama · $belumDibaca' : nama;
  }

  /// Penanda bagian tebal di teks data notifikasi, misalnya "**Sinta** membagikan ...".
  static const penandaTebal = '**';
}
