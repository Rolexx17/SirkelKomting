import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../routes/app_routes.dart';
import '../../shared/widgets/app_logo.dart';

/// Layar pembuka: logo, nama aplikasi, tagline, dan label SDG 4.
/// Setelah 2 detik otomatis pindah ke Onboarding.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // Nilai khusus Splash dari spesifikasi 01 (Bagian 10 brief).
  static const _durasi = Duration(seconds: 2);
  static const _ukuranLogo = 104.0;
  static const _ukuranNama = 40.0;
  static const _jarakHurufNama = -1.2;
  static const _ukuranKotakSdg = 28.0;
  static const _radiusKotakSdg = 6.0;
  static const _angkaSdg = '4';

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // P1 (lifecycle): Timer dibuat sekali saat layar pertama kali dibangun.
    _timer = Timer(_durasi, _keOnboarding);
  }

  void _keOnboarding() {
    // Cek mounted: saat Timer selesai, layar bisa saja sudah ditutup (misalnya hot restart).
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(AppRoutes.onboarding);
  }

  @override
  void dispose() {
    // Timer dibatalkan agar tidak memanggil navigasi dari layar yang sudah dibuang.
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final halo = scheme.onPrimary.withValues(alpha: 0.06);

    return Scaffold(
      backgroundColor: scheme.primary,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                // Scroll hanya sebagai pengaman di landscape pendek (800×360).
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSizes.pagePadding),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Dua lapis "halo" tipis di belakang ikon, sesuai mockup.
                      Container(
                        padding: const EdgeInsets.all(AppSizes.sm),
                        decoration: BoxDecoration(
                          color: halo,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(AppSizes.radiusXL + AppSizes.xl),
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(AppSizes.sm),
                          decoration: BoxDecoration(
                            color: halo,
                            borderRadius: const BorderRadius.all(
                              Radius.circular(AppSizes.radiusXL + AppSizes.sm),
                            ),
                          ),
                          child: const AppLogo(
                            size: _ukuranLogo,
                            withBackground: true,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSizes.m),
                      // Wordmark di mockup selalu huruf kecil: "sirkel".
                      Text(
                        AppStrings.appName.toLowerCase(),
                        style: text.headlineLarge?.copyWith(
                          fontSize: _ukuranNama,
                          fontWeight: FontWeight.w800,
                          letterSpacing: _jarakHurufNama,
                          color: scheme.onPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSizes.s),
                      Text(
                        AppStrings.tagline,
                        textAlign: TextAlign.center,
                        style: text.bodyLarge?.copyWith(
                          color: scheme.onPrimary.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSizes.pagePadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Satu-satunya warna non-colorScheme: warna resmi SDG 4.
                  Container(
                    width: _ukuranKotakSdg,
                    height: _ukuranKotakSdg,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: AppTheme.sdg4Red,
                      borderRadius: BorderRadius.all(
                        Radius.circular(_radiusKotakSdg),
                      ),
                    ),
                    child: Text(
                      _angkaSdg,
                      style: text.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: scheme.onPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.sm),
                  Flexible(
                    child: Text(
                      AppStrings.sdgLabel,
                      style: text.labelLarge?.copyWith(
                        color: scheme.onPrimary.withValues(alpha: 0.9),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
