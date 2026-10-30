import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_sizes.dart';
import '../../data/dummy/dummy_data.dart';
import '../../data/models/sirkel.dart';
import '../../routes/app_routes.dart';
import 'sirkel_strings.dart';
import 'sirkel_waktu.dart';

/// Menampilkan dialog "Kamu resmi gabung!" setelah pengguna bergabung ke [sirkel].
Future<void> showGabungDialog(BuildContext context, Sirkel sirkel) {
  return showDialog<void>(
    context: context,
    builder: (_) => _GabungDialog(sirkel: sirkel),
  );
}

/// Waktu sesi pertama: diambil dari `DummyData.jadwalSesi` bila ada; jika tidak,
/// dihitung hari [Sirkel.hari] terdekat mulai hari ini pada jam [Sirkel.jam].
DateTime _sesiPertama(Sirkel sirkel) {
  final jadwal = DummyData.jadwalSesi
      .where((sesi) => sesi.sirkelId == sirkel.id)
      .map((sesi) => sesi.waktu)
      .toList()
    ..sort();
  if (jadwal.isNotEmpty) return jadwal.first;

  final sekarang = DateTime.now();
  final targetHari = nomorHari(sirkel.hari) ?? sekarang.weekday;
  final selisihHari = (targetHari - sekarang.weekday + 7) % 7;
  final menit = bacaJam(sirkel.jam) ?? 0;
  final sesi = DateTime(
    sekarang.year,
    sekarang.month,
    sekarang.day + selisihHari,
    menit ~/ 60,
    menit % 60,
  );
  // Bila sesi hari ini sudah lewat jamnya, pakai minggu berikutnya.
  return sesi.isBefore(sekarang) ? sesi.add(const Duration(days: 7)) : sesi;
}

String _formatSesi(DateTime w) => SirkelStrings.waktuSesi(
      SirkelStrings.namaHari[w.weekday - 1],
      w.day,
      SirkelStrings.bulanSingkat[w.month - 1],
      tulisJam(w.hour * 60 + w.minute),
    );

class _GabungDialog extends StatelessWidget {
  const _GabungDialog({required this.sirkel});

  final Sirkel sirkel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final online = sirkel.mode == ModeBelajar.online;

    return Dialog(
      // Scroll agar isi dialog tidak overflow di landscape ponsel.
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              AppAssets.onboarding1,
              width: AppSizes.gabungIlustrasiW,
              height: AppSizes.gabungIlustrasiH,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: AppSizes.l),
            Text(
              SirkelStrings.gabungJudul,
              textAlign: TextAlign.center,
              style: text.headlineSmall,
            ),
            const SizedBox(height: AppSizes.s),
            // P3: Text.rich untuk menebalkan waktu sesi di tengah kalimat.
            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(text: SirkelStrings.sesiPertama),
                  TextSpan(
                    text: _formatSesi(_sesiPertama(sirkel)),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurface,
                    ),
                  ),
                  TextSpan(
                    text: online
                        ? SirkelStrings.infoOnline(sirkel.lokasi)
                        : SirkelStrings.infoOffline(sirkel.lokasi),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
              style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: AppSizes.xl),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(SirkelStrings.nanti),
                ),
                const SizedBox(width: AppSizes.s),
                FilledButton(
                  onPressed: () {
                    final nav = Navigator.of(context);
                    nav.pop();
                    nav.pushNamed(AppRoutes.sirkelSaya);
                  },
                  child: const Text(SirkelStrings.lihatJadwal),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
