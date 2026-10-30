import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_sizes.dart';
import '../../routes/app_routes.dart';
import '../../shared/widgets/page_indicator.dart';
import 'onboarding_page.dart';
import 'onboarding_strings.dart';

/// Tiga slide perkenalan aplikasi dengan PageView, lalu menuju halaman Masuk.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const _slides = [
    OnboardingItem(
      gambar: AppAssets.onboarding1,
      judul: OnboardingStrings.judul1,
      deskripsi: OnboardingStrings.deskripsi1,
    ),
    OnboardingItem(
      gambar: AppAssets.onboarding2,
      judul: OnboardingStrings.judul2,
      deskripsi: OnboardingStrings.deskripsi2,
    ),
    OnboardingItem(
      gambar: AppAssets.onboarding3,
      judul: OnboardingStrings.judul3,
      deskripsi: OnboardingStrings.deskripsi3,
    ),
  ];
  static const _durasiGeser = Duration(milliseconds: 300);

  final _controller = PageController();
  int _indeks = 0;

  bool get _slideTerakhir => _indeks == _slides.length - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // pushReplacement: Onboarding dibuang dari riwayat, jadi tombol kembali di Masuk tidak ke sini.
  void _keMasuk() {
    Navigator.of(context).pushReplacementNamed(AppRoutes.masuk);
  }

  void _lanjut() {
    if (_slideTerakhir) {
      _keMasuk();
      return;
    }
    // Indeks tidak diubah di sini; onPageChanged yang memperbaruinya (juga saat digeser).
    _controller.nextPage(duration: _durasiGeser, curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.s),
                child: TextButton(
                  onPressed: _keMasuk,
                  child: const Text(OnboardingStrings.lewati),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _indeks = i),
                itemBuilder: (context, i) => OnboardingPage(item: _slides[i]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.pagePadding,
                AppSizes.m,
                AppSizes.pagePadding,
                AppSizes.pagePadding,
              ),
              child: Center(
                // P7: di layar lebar tombol tidak melebar penuh, maksimal 560.
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppSizes.maxContentWidth,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PageIndicator(
                        count: _slides.length,
                        currentIndex: _indeks,
                      ),
                      const SizedBox(height: AppSizes.xl),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _lanjut,
                          child: Text(
                            _slideTerakhir
                                ? OnboardingStrings.mulaiSekarang
                                : OnboardingStrings.lanjut,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
