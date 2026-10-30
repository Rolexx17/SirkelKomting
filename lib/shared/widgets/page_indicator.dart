import 'package:flutter/material.dart';

import '../../core/constants/app_sizes.dart';

/// Titik penanda halaman. Titik aktif melebar 24 px (primary), lainnya 8 px (outlineVariant).
class PageIndicator extends StatelessWidget {
  const PageIndicator({
    super.key,
    required this.count,
    required this.currentIndex,
  });

  final int count;
  final int currentIndex;

  static const _durasi = Duration(milliseconds: 250);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (i) {
        final aktif = i == currentIndex;
        // AnimatedContainer menganimasikan lebar & warna setiap kali currentIndex berubah.
        return AnimatedContainer(
          duration: _durasi,
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: AppSizes.xs),
          width: aktif ? AppSizes.xl : AppSizes.s,
          height: AppSizes.s,
          decoration: BoxDecoration(
            color: aktif ? scheme.primary : scheme.outlineVariant,
            borderRadius: const BorderRadius.all(Radius.circular(AppSizes.xs)),
          ),
        );
      }),
    );
  }
}
