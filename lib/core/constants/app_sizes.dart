/// Konstanta ukuran (jarak, radius, tinggi, lebar) agar tampilan konsisten.
///
/// Nilai di bagian atas adalah kontrak Bagian 12.3 brief dan boleh dipakai
/// semua anggota. Nilai "tambahan" di bawahnya dipakai layar milik Justin.
class AppSizes {
  AppSizes._();

  // Jarak kelipatan 4/8 (Bagian 9).
  static const xs = 4.0, s = 8.0, sm = 12.0, m = 16.0, l = 20.0, xl = 24.0, xxl = 32.0;
  static const pagePadding = 20.0;

  // Radius: chip/input 8, kartu 16, kartu besar 24, sheet & dialog 28.
  static const radiusS = 8.0, radiusM = 16.0, radiusL = 24.0, radiusXL = 28.0;

  static const buttonHeight = 48.0;
  static const avatarS = 24.0, avatarM = 44.0, avatarL = 96.0;

  // P7: batas lebar konten layar formulir & detail di layar lebar.
  static const maxContentWidth = 560.0;

  // ---- Tambahan (di luar kontrak minimum) ----
  static const avatarAnggota = 48.0;
  static const iconS = 16.0;
  static const searchBarHeight = 56.0;
  static const circleButton = 44.0;
  static const coverCard = 120.0;
  static const coverCardCompact = 96.0;

  /// Tinggi bagian teks SirkelCard (tanpa sampul), dipakai menghitung tinggi sel grid.
  static const sirkelCardBody = 144.0;
  static const detailHeader = 220.0;
  static const sheetMaxWidth = 640.0;
  static const fabSpace = 88.0;
  static const gabungIlustrasiW = 180.0, gabungIlustrasiH = 146.0;
}
