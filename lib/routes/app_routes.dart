import 'package:flutter/widgets.dart';

import '../features/auth/daftar_screen.dart';
import '../features/auth/masuk_screen.dart';
import '../features/buat_sirkel/buat_sirkel_screen.dart';
import '../features/materi/detail_materi_screen.dart';
import '../features/notifikasi/notifikasi_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/shell/main_shell.dart';
import '../features/sirkel/detail_sirkel_screen.dart';
import '../features/sirkel_saya/sirkel_saya_screen.dart';
import '../features/splash/splash_screen.dart';

/// Nama route (path) semua layar dan tabel pemetaannya ke widget layar (Bagian 12.5).
class AppRoutes {
  AppRoutes._();

  static const splash = '/';
  static const onboarding = '/onboarding';
  static const masuk = '/masuk';
  static const daftar = '/daftar';
  static const home = '/home';
  static const notifikasi = '/notifikasi';
  static const sirkelSaya = '/sirkel-saya';
  static const detailSirkel = '/detail-sirkel';
  static const buatSirkel = '/buat-sirkel';
  static const detailMateri = '/detail-materi';

  // Navigasi dengan argumen: detailSirkel dan detailMateri dibuka dengan
  // `pushNamed(route, arguments: id)`. Id (String) tersimpan di RouteSettings,
  // lalu layar tujuan membacanya lewat `ModalRoute.of(context)?.settings.arguments`.
  // Karena itu cukup tabel `routes` biasa, tanpa onGenerateRoute.
  static final Map<String, WidgetBuilder> routes = {
    splash: (_) => const SplashScreen(),
    onboarding: (_) => const OnboardingScreen(),
    masuk: (_) => const MasukScreen(),
    daftar: (_) => const DaftarScreen(),
    home: (_) => const MainShell(),
    notifikasi: (_) => const NotifikasiScreen(),
    sirkelSaya: (_) => const SirkelSayaScreen(),
    detailSirkel: (_) => const DetailSirkelScreen(),
    buatSirkel: (_) => const BuatSirkelScreen(),
    detailMateri: (_) => const DetailMateriScreen(),
  };
}
