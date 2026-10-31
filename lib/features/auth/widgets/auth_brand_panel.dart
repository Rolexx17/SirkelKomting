import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../shared/widgets/app_logo.dart';

/// Panel kiri berlatar primary di layar lebar (≥ 840): logo, nama aplikasi,
/// tagline, dan ilustrasi. Dipakai AuthFormLayout untuk Masuk dan Daftar.
class AuthBrandPanel extends StatelessWidget {
  const AuthBrandPanel({super.key});

  static const _ukuranLogo = 72.0;
  static const _ukuranNama = 40.0;
  static const _jarakHurufNama = -1.2;
  static const _lebarMaksIlustrasi = 400.0;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return ColoredBox(
      color: scheme.primary,
      child: SafeArea(
        right: false,
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const AppLogo(size: _ukuranLogo, withBackground: true),
              const SizedBox(height: AppSizes.m),
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
              const SizedBox(height: AppSizes.xl),
              // Flexible: ilustrasi mengecil bila layar pendek (misalnya HP landscape 932×430),
              // sehingga logo dan teks tidak terdorong keluar layar.
              Flexible(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: _lebarMaksIlustrasi,
                  ),
                  child: Image.asset(
                    AppAssets.onboarding1,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
