import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_sizes.dart';
import '../../data/dummy/dummy_data.dart';
import '../../data/models/sirkel.dart';
import '../../routes/app_routes.dart';
import 'sirkel_layout.dart';
import 'sirkel_strings.dart';
import 'sirkel_waktu.dart';

/// Menampilkan dialog "Kamu resmi gabung!" setelah pengguna bergabung ke [sirkel].
Future<void> showGabungDialog(BuildContext context, Sirkel sirkel) {
  return showDialog<void>(
    context: context,
    builder: (_) => _GabungDialog(sirkel: sirkel),
  );
}

/// Waktu sesi pertama: diambil dari `DummyData.jadwalSesi` (sudah relatif ke
/// waktu sekarang dan terurut). Cadangan bila tidak ada: hari sesi terdekat dari
/// `daftarNomorHari` mulai sekarang pada jam [Sirkel.jam].
DateTime _sesiPertama(Sirkel sirkel) {
  for (final sesi in DummyData.jadwalSesi) {
    if (sesi.sirkelId == sirkel.id) return sesi.waktu;
  }

  final sekarang = DateTime.now();
  final menit = bacaJam(sirkel.jam) ?? 0;
  // Coba hari ini sampai 7 hari ke depan; ambil tanggal pertama yang harinya cocok
  // dan jamnya belum lewat.
  for (var i = 0; i <= DateTime.daysPerWeek; i++) {
    final calon = DateTime(
      sekarang.year,
      sekarang.month,
      sekarang.day + i,
      menit ~/ 60,
      menit % 60,
    );
    if (sirkel.daftarNomorHari.contains(calon.weekday) &&
        !calon.isBefore(sekarang)) {
      return calon;
    }
  }
  return sekarang;
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
    // P7: di HP landscape tinggi layar kecil, jadi ilustrasi disembunyikan supaya
    // dialog muat tanpa digulir. Desktop/tablet tetap menampilkan ilustrasi.
    final sembunyikanIlustrasi = landscapeHp(context);

    return Dialog(
      // Scroll hanya sebagai pengaman bila ukuran huruf diperbesar.
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!sembunyikanIlustrasi) ...[
              Image.asset(
                AppAssets.onboarding1,
                width: AppSizes.gabungIlustrasiW,
                height: AppSizes.gabungIlustrasiH,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: AppSizes.l),
            ],
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
            // OverflowBar: tombol berdampingan bila muat, dan otomatis turun
            // bertumpuk di layar sempit atau saat ukuran huruf diperbesar.
            OverflowBar(
              alignment: MainAxisAlignment.end,
              overflowAlignment: OverflowBarAlignment.end,
              spacing: AppSizes.s,
              overflowSpacing: AppSizes.s,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(SirkelStrings.nanti),
                ),
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
