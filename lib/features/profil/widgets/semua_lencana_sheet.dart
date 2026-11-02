import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../lencana_progres.dart';
import '../profil_strings.dart';
import 'lencana_item.dart';

/// Membuka bottom sheet berisi semua lencana beserta syarat dan progresnya.
Future<void> showSemuaLencanaSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    constraints: const BoxConstraints(maxWidth: AppSizes.sheetMaxWidth),
    builder: (_) => const _SemuaLencanaSheet(),
  );
}

/// Membuka bottom sheet detail satu lencana: syarat, progres, dan sisa langkahnya.
Future<void> showDetailLencanaSheet(
  BuildContext context, {
  required ProgresLencana progres,
  required Color latar,
  required Color warnaIkon,
}) {
  return showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    showDragHandle: true,
    constraints: const BoxConstraints(maxWidth: AppSizes.sheetMaxWidth),
    builder: (_) => _DetailLencana(
      progres: progres,
      latar: latar,
      warnaIkon: warnaIkon,
    ),
  );
}

class _SemuaLencanaSheet extends StatelessWidget {
  const _SemuaLencanaSheet();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final daftar = progresLencanaSaatIni();
    final jumlahDidapat = daftar.where((p) => p.didapat).length;

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
            ProfilStrings.lencanaTerkumpul(jumlahDidapat, daftar.length),
            style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: AppSizes.m),
          // P6: daftar lencana memakai Column di dalam scroll (jumlahnya sedikit).
          for (final (i, progres) in daftar.indexed) ...[
            if (i > 0) const SizedBox(height: AppSizes.m),
            _BarisLencana(progres: progres, indeksWarna: i),
          ],
        ],
      ),
    );
  }
}

/// Satu baris lencana: kotak ikon, nama, syarat, dan bilah progres.
class _BarisLencana extends StatelessWidget {
  const _BarisLencana({required this.progres, required this.indeksWarna});

  final ProgresLencana progres;
  final int indeksWarna;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final (latar, warnaIkon) = LencanaItem.warnaKe(scheme, indeksWarna);
    final didapat = progres.didapat;

    return Row(
      children: [
        KotakLencana(
          ikon: progres.lencana.ikon,
          latar: didapat ? latar : scheme.surfaceContainerHigh,
          warnaIkon: didapat ? warnaIkon : scheme.outline,
          ukuran: _ukuranKotak,
        ),
        const SizedBox(width: AppSizes.m),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(progres.lencana.nama, style: text.titleSmall),
              Text(
                progres.syarat,
                style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: AppSizes.s),
              // P4: LinearProgressIndicator M3 sebagai bilah progres lencana.
              LinearProgressIndicator(value: progres.rasio),
            ],
          ),
        ),
        const SizedBox(width: AppSizes.m),
        didapat
            ? Icon(Icons.check_circle, color: scheme.primary)
            : Text(
                ProfilStrings.progres(progres.nilaiTampil, progres.target),
                style: text.labelLarge,
              ),
      ],
    );
  }

  static const _ukuranKotak = 48.0;
}

class _DetailLencana extends StatelessWidget {
  const _DetailLencana({
    required this.progres,
    required this.latar,
    required this.warnaIkon,
  });

  final ProgresLencana progres;
  final Color latar;
  final Color warnaIkon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final didapat = progres.didapat;
    final sisa = progres.target - progres.nilaiTampil;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.pagePadding,
        0,
        AppSizes.pagePadding,
        AppSizes.pagePadding,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          KotakLencana(
            ikon: progres.lencana.ikon,
            latar: didapat ? latar : scheme.surfaceContainerHigh,
            warnaIkon: didapat ? warnaIkon : scheme.outline,
          ),
          const SizedBox(height: AppSizes.m),
          Text(progres.lencana.nama, style: text.titleLarge),
          const SizedBox(height: AppSizes.xs),
          Text(
            didapat ? ProfilStrings.didapat : ProfilStrings.belumDidapat,
            style: text.labelLarge?.copyWith(
              color: didapat ? scheme.primary : scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSizes.l),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.m),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    ProfilStrings.syaratLabel,
                    style: text.labelMedium
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                  Text(progres.syarat, style: text.bodyLarge),
                  const SizedBox(height: AppSizes.sm),
                  LinearProgressIndicator(value: progres.rasio),
                  const SizedBox(height: AppSizes.s),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          ProfilStrings.progres(
                            progres.nilaiTampil,
                            progres.target,
                          ),
                          style: text.labelLarge,
                        ),
                      ),
                      if (!didapat)
                        Text(
                          ProfilStrings.sisaMenujuLencana(sisa),
                          style: text.bodySmall
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
