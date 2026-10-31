import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/responsive.dart';
import 'auth_brand_panel.dart';

/// Kerangka layar Masuk dan Daftar: [isi] di atas, [bawah] menempel di dasar layar,
/// bisa di-scroll, dan berubah menjadi dua panel di layar lebar.
class AuthFormLayout extends StatelessWidget {
  const AuthFormLayout({super.key, required this.isi, required this.bawah});

  final Widget isi;
  final Widget bawah;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // P7: ≥ 840 (desktop/tablet besar) ruang kosong di kiri-kanan form diisi
        // panel identitas aplikasi. Di bawah 840 tetap satu kolom seperti di ponsel.
        if (constraints.maxWidth >= Responsive.expandedBreakpoint) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Expanded(child: AuthBrandPanel()),
              Expanded(
                child: SafeArea(
                  left: false,
                  child: _AreaForm(isi: isi, bawah: bawah),
                ),
              ),
            ],
          );
        }
        return SafeArea(child: _AreaForm(isi: isi, bawah: bawah));
      },
    );
  }
}

class _AreaForm extends StatelessWidget {
  const _AreaForm({required this.isi, required this.bawah});

  final Widget isi;
  final Widget bawah;

  @override
  Widget build(BuildContext context) {
    // P7: LayoutBuilder memberi tinggi yang tersedia (berkurang saat keyboard muncul).
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.pagePadding),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              // P7: lebar maksimal 560 dan ditengahkan. minHeight = tinggi layar agar
              // [bawah] tetap di dasar; jika konten lebih tinggi (landscape 800×360
              // atau keyboard terbuka), cukup di-scroll.
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
