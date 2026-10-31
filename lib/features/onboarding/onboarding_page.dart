import 'package:flutter/material.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/utils/responsive.dart';

/// Data satu slide Onboarding: path ilustrasi, judul, dan deskripsi.
class OnboardingItem {
  const OnboardingItem({
    required this.gambar,
    required this.judul,
    required this.deskripsi,
  });

  final String gambar;
  final String judul;
  final String deskripsi;
}

/// Isi satu slide Onboarding (ilustrasi + teks).
class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key, required this.item});

  final OnboardingItem item;

  @override
  Widget build(BuildContext context) {
    // P7: LayoutBuilder membaca lebar yang benar-benar tersedia untuk slide ini.
    return LayoutBuilder(
      builder: (context, constraints) {
        final gambar = Image.asset(item.gambar, fit: BoxFit.contain);

        // P7: orientasi dibaca langsung dari layar. Row (ilustrasi kiri, teks kanan)
        // dipakai saat landscape, karena tinggi layar terlalu pendek untuk Column,
        // atau saat lebar ≥ 840 (desktop). Tablet portrait (mis. 768×1024) tetap
        // Column: lebarnya ≥ 600, tetapi layarnya tinggi sehingga Column lebih lega.
        final landscape =
            MediaQuery.orientationOf(context) == Orientation.landscape;
        final pakaiRow = landscape ||
            constraints.maxWidth >= Responsive.expandedBreakpoint;

        if (pakaiRow) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.xxl),
            child: Row(
              children: [
                Expanded(child: gambar),
                const SizedBox(width: AppSizes.xxl),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: _teks(context, TextAlign.start),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // Ponsel: Column. Expanded membuat ilustrasi mengecil, bukan terpotong, di layar pendek.
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.pagePadding),
          child: Column(
            children: [
              Expanded(child: Center(child: gambar)),
              const SizedBox(height: AppSizes.xl),
              _teks(context, TextAlign.center),
              const SizedBox(height: AppSizes.xl),
            ],
          ),
        );
      },
    );
  }

  Widget _teks(BuildContext context, TextAlign rata) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: rata == TextAlign.center
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Text(item.judul, textAlign: rata, style: text.headlineSmall),
        const SizedBox(height: AppSizes.sm),
        Text(
          item.deskripsi,
          textAlign: rata,
          style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }
}
