import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/utils/responsive.dart';
import '../../shared/widgets/cover_image.dart';
import 'buat_sirkel_strings.dart';

/// Membuka bottom sheet berisi 6 sampul. Mengembalikan path sampul yang diketuk,
/// atau null bila sheet ditutup tanpa memilih.
Future<String?> showSampulPickerSheet(BuildContext context, {String? terpilih}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _SampulPickerSheet(terpilih: terpilih),
  );
}

class _SampulPickerSheet extends StatelessWidget {
  const _SampulPickerSheet({this.terpilih});

  final String? terpilih;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    // P7: 3 kolom di ponsel; di layar lebar/landscape 6 kolom agar muat satu baris.
    final kolom = Responsive.columns(context, compact: 3, medium: 6, expanded: 6);

    // P6: scroll agar sheet tidak overflow di landscape yang pendek.
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.pagePadding,
        0,
        AppSizes.pagePadding,
        AppSizes.pagePadding,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            BuatSirkelStrings.sheetJudul,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSizes.m),
          GridView.count(
            crossAxisCount: kolom,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppSizes.s,
            crossAxisSpacing: AppSizes.s,
            childAspectRatio: 4 / 3,
            children: [
              for (final sampul in AppAssets.covers)
                InkWell(
                  borderRadius: BorderRadius.circular(AppSizes.radiusS),
                  onTap: () => Navigator.pop(context, sampul),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CoverImage(path: sampul, radius: AppSizes.radiusS),
                      // Penanda sampul yang sedang dipakai: bingkai + ikon centang.
                      if (sampul == terpilih) ...[
                        DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(AppSizes.radiusS),
                            border: Border.all(color: scheme.primary, width: 3),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: const EdgeInsets.all(AppSizes.xs),
                            child: Icon(Icons.check_circle, color: scheme.primary),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
