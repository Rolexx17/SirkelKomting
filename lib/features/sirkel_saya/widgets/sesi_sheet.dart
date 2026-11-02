import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../data/models/sesi.dart';
import '../../../data/models/sirkel.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/widgets/cover_image.dart';
import '../../../shared/widgets/info_row.dart';
import '../jadwal_util.dart';
import '../sirkel_saya_strings.dart';

/// Membuka bottom sheet detail satu sesi (dipakai Beranda dan Sirkel Saya).
/// Future selesai setelah sheet ditutup, atau setelah Detail Sirkel yang dibuka
/// dari sheet ditutup, sehingga pemanggil bisa langsung membangun ulang datanya.
Future<void> showSesiSheet(
  BuildContext context, {
  required Sirkel sirkel,
  required Sesi sesi,
}) async {
  final bukaDetail = await showModalBottomSheet<bool>(
    context: context,
    // Tinggi mengikuti isi dan bisa digulir (aman di landscape 932×430).
    isScrollControlled: true,
    builder: (_) => _SesiSheet(sirkel: sirkel, sesi: sesi),
  );
  // Detail Sirkel dibuka dari context pemanggil setelah sheet tertutup.
  if (bukaDetail == true && context.mounted) {
    await Navigator.of(context)
        .pushNamed(AppRoutes.detailSirkel, arguments: sirkel.id);
  }
}

class _SesiSheet extends StatefulWidget {
  const _SesiSheet({required this.sirkel, required this.sesi});

  final Sirkel sirkel;
  final Sesi sesi;

  @override
  State<_SesiSheet> createState() => _SesiSheetState();
}

class _SesiSheetState extends State<_SesiSheet> {
  bool _disalin = false;

  static const _ukuranSampul = 56.0;

  /// Indentasi tombol "Salin tautan" agar sejajar dengan teks InfoRow (ikon 24 + jarak 16).
  static const _indentInfo = AppSizes.xl + AppSizes.m;

  Future<void> _salin(String tautan) async {
    await Clipboard.setData(ClipboardData(text: tautan));
    if (!mounted) return;
    // Umpan balik di tombol itu sendiri: SnackBar akan tertutup sheet ini.
    setState(() => _disalin = true);
  }

  void _masuk() {
    // Messenger diambil sebelum sheet ditutup agar SnackBar tampil di layar asal.
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(SirkelSayaStrings.membuka(widget.sirkel.lokasi))),
      );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final sirkel = widget.sirkel;
    final mulai = widget.sesi.waktu;
    final sekarang = DateTime.now();

    final online = sirkel.mode == ModeBelajar.online;
    final tautan = SirkelSayaStrings.tautanOnline(sirkel.id);
    // Tombol Masuk sesi hanya aktif dari 15 menit sebelum mulai sampai sesi selesai.
    final bisaMasuk = bisaMasukSesi(mulai, sekarang);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.pagePadding,
          0,
          AppSizes.pagePadding,
          AppSizes.pagePadding,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                CoverImage(
                  path: sirkel.cover,
                  width: _ukuranSampul,
                  height: _ukuranSampul,
                  radius: AppSizes.sm,
                ),
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sirkel.mataKuliah.toUpperCase(),
                        style: text.labelMedium?.copyWith(color: scheme.primary),
                      ),
                      Text(
                        sirkel.judul,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: text.titleMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.l),
            InfoRow(
              icon: Icons.schedule,
              label: SirkelSayaStrings.waktu,
              value: SirkelSayaStrings.waktuSesi(
                tanggalPanjang(mulai),
                SirkelSayaStrings.rentangJam(
                  jamDari(mulai),
                  jamDari(mulai.add(durasiSesi)),
                ),
              ),
              subtitle: teksMulai(mulai, sekarang),
            ),
            const SizedBox(height: AppSizes.m),
            InfoRow(
              icon: online ? Icons.videocam : Icons.place,
              label: SirkelSayaStrings.lokasi,
              value: sirkel.lokasi,
              subtitle: online ? tautan : null,
            ),
            if (online)
              Padding(
                padding: const EdgeInsets.only(left: _indentInfo),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => _salin(tautan),
                    icon: Icon(_disalin ? Icons.check : Icons.copy),
                    label: Text(
                      _disalin
                          ? SirkelSayaStrings.tautanDisalin
                          : SirkelSayaStrings.salinTautan,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: AppSizes.xl),
            FilledButton.icon(
              onPressed: bisaMasuk ? _masuk : null,
              icon: const Icon(Icons.videocam),
              label: const Text(SirkelSayaStrings.masukSesi),
            ),
            if (!bisaMasuk)
              Padding(
                padding: const EdgeInsets.only(top: AppSizes.xs),
                child: Text(
                  SirkelSayaStrings.bantuanMasuk(batasMasukAwal.inMinutes),
                  textAlign: TextAlign.center,
                  style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ),
            const SizedBox(height: AppSizes.s),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(SirkelSayaStrings.lihatDetailSirkel),
            ),
          ],
        ),
      ),
    );
  }
}
