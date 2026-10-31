import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/responsive.dart';
import '../../../data/dummy/dummy_data.dart';
import '../profil_strings.dart';
import 'lencana_item.dart';

/// Membuka bottom sheet berisi semua lencana pengguna dalam GridView.
Future<void> showSemuaLencanaSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    constraints: const BoxConstraints(maxWidth: AppSizes.sheetMaxWidth),
    builder: (_) => const _SemuaLencanaSheet(),
  );
}

class _SemuaLencanaSheet extends StatelessWidget {
  const _SemuaLencanaSheet();

  // Tinggi tetap satu sel: kotak 56 + jarak 8 + dua baris nama.
  static const _tinggiSel = 112.0;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final daftar = DummyData.semuaLencana;
    // P7: 4 kolom di ponsel, 5 kolom di layar lebar.
    final kolom = Responsive.columns(context, compact: 4, medium: 5, expanded: 5);

    // Scroll sebagai pengaman di HP landscape yang tingginya hanya ±360.
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.pagePadding,
        0,
        AppSizes.pagePadding,
        AppSizes.pagePadding,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(ProfilStrings.semuaLencanaJudul, style: text.titleLarge),
          const SizedBox(height: AppSizes.xs),
          Text(
            ProfilStrings.lencanaTerkumpul(daftar.length),
            style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: AppSizes.l),
          // P6: GridView di dalam scroll lain → shrinkWrap + scroll grid dimatikan.
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: daftar.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: kolom,
              mainAxisExtent: _tinggiSel,
              crossAxisSpacing: AppSizes.s,
              mainAxisSpacing: AppSizes.m,
            ),
            itemBuilder: (context, i) {
              final (latar, ikon) = LencanaItem.warnaKe(scheme, i);
              return LencanaItem(
                lencana: daftar[i],
                latar: latar,
                warnaIkon: ikon,
              );
            },
          ),
        ],
      ),
    );
  }
}
