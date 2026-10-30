import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';

/// Kerangka layar Masuk dan Daftar: [isi] di atas, [bawah] menempel di dasar layar,
/// bisa di-scroll, dan lebarnya dibatasi di layar lebar.
class AuthFormLayout extends StatelessWidget {
  const AuthFormLayout({super.key, required this.isi, required this.bawah});

  final Widget isi;
  final Widget bawah;

  @override
  Widget build(BuildContext context) {
    // P7: LayoutBuilder memberi tinggi layar yang tersedia (berkurang saat keyboard muncul).
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.pagePadding),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              // P7: lebar maksimal 560 dan ditengahkan di tablet.
              // minHeight = tinggi layar, sehingga [bawah] tetap di dasar; jika konten
              // lebih tinggi (landscape 800×360 atau keyboard terbuka), cukup di-scroll.
              constraints: BoxConstraints(
                maxWidth: AppSizes.maxContentWidth,
                minHeight: math.max(
                  0.0,
                  constraints.maxHeight - AppSizes.pagePadding * 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  isi,
                  Padding(
                    padding: const EdgeInsets.only(top: AppSizes.xl),
                    child: bawah,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
