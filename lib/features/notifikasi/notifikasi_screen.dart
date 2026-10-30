import 'package:flutter/material.dart';

import '../../core/constants/app_sizes.dart';
import '../../data/dummy/dummy_data.dart';
import '../../data/models/notifikasi.dart';
import '../../routes/app_routes.dart';
import '../../shared/widgets/cover_image.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/user_avatar.dart';
import 'notifikasi_strings.dart';

/// Layar Notifikasi: daftar kabar per grup ("Hari ini", "Minggu ini")
/// dengan status belum dibaca dan tombol "Tandai dibaca".
class NotifikasiScreen extends StatefulWidget {
  const NotifikasiScreen({super.key});

  /// Memecah teks di tanda `**`: potongan berindeks ganjil (yang diapit `**`)
  /// diberi [gayaTebal], sisanya memakai gaya induk TextSpan.
  /// Contoh: "**Sinta** membagikan" → [TextSpan("Sinta", tebal), TextSpan(" membagikan")].
  static List<TextSpan> uraiTebal(String teks, TextStyle? gayaTebal) {
    final potongan = teks.split(NotifikasiStrings.penandaTebal);
    return [
      for (var i = 0; i < potongan.length; i++)
        if (potongan[i].isNotEmpty)
          TextSpan(text: potongan[i], style: i.isOdd ? gayaTebal : null),
    ];
  }

  @override
  State<NotifikasiScreen> createState() => _NotifikasiScreenState();
}

class _NotifikasiScreenState extends State<NotifikasiScreen> {
  // Salinan lokal: status dibaca hanya disimpan di state layar ini (tanpa server).
  List<Notifikasi> _daftar = List.of(DummyData.notifikasi);

  static const _ukuranGambar = AppSizes.avatarM;
  static const _radiusSampul = 12.0;
  static const _radiusLencana = 14.0;
  static const _ukuranTitik = 8.0;

  bool get _adaBelumDibaca => _daftar.any((n) => n.belumDibaca);

  void _tandaiSemuaDibaca() {
    setState(() {
      _daftar = [for (final n in _daftar) n.copyWith(belumDibaca: false)];
    });
  }

  void _buka(String sirkelId) {
    Navigator.of(context).pushNamed(AppRoutes.detailSirkel, arguments: sirkelId);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    // Urutan grup mengikuti urutan kemunculan di data ("Hari ini" lalu "Minggu ini").
    final grup = <String>[];
    for (final n in _daftar) {
      if (!grup.contains(n.grup)) grup.add(n.grup);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(NotifikasiStrings.judul),
        actions: [
          TextButton(
            // Nonaktif bila semua sudah dibaca.
            onPressed: _adaBelumDibaca ? _tandaiSemuaDibaca : null,
            child: const Text(NotifikasiStrings.tandaiDibaca),
          ),
          const SizedBox(width: AppSizes.s),
        ],
      ),
      body: _daftar.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(AppSizes.pagePadding),
              child: EmptyState(
                title: NotifikasiStrings.kosongJudul,
                message: NotifikasiStrings.kosongPesan,
              ),
            )
          : Align(
              alignment: Alignment.topCenter,
              // P7: di layar lebar daftar dibatasi 560 px dan ditengahkan.
              child: ConstrainedBox(
                constraints:
                    const BoxConstraints(maxWidth: AppSizes.maxContentWidth),
                // P6: ListView vertikal berisi judul grup dan item notifikasi.
                child: ListView(
                  padding: const EdgeInsets.only(bottom: AppSizes.pagePadding),
                  children: [
                    for (final g in grup) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSizes.pagePadding,
                          AppSizes.m,
                          AppSizes.pagePadding,
                          AppSizes.s,
                        ),
                        child: Text(
                          g,
                          style: text.titleSmall
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ),
                      for (final n in _daftar.where((x) => x.grup == g))
                        _item(context, n),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Widget _item(BuildContext context, Notifikasi n) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final sirkelId = n.sirkelId;

    final isi = InkWell(
      // Notifikasi tanpa sirkel (misalnya lencana) tidak bisa diketuk.
      onTap: sirkelId == null ? null : () => _buka(sirkelId),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.pagePadding,
          vertical: AppSizes.sm,
        ),
        child: Row(
          children: [
            _gambar(context, n),
            const SizedBox(width: AppSizes.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // P3: Text.rich menggabungkan potongan teks biasa dan tebal dalam satu paragraf.
                  Text.rich(
                    TextSpan(
                      style: text.bodyLarge?.copyWith(color: scheme.onSurface),
                      children: NotifikasiScreen.uraiTebal(
                        n.teks,
                        const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.xs),
                  Text(
                    n.waktu,
                    style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            if (n.belumDibaca) ...[
              const SizedBox(width: AppSizes.sm),
              Container(
                width: _ukuranTitik,
                height: _ukuranTitik,
                decoration: BoxDecoration(
                  color: scheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );

    // Latar surfaceContainerLow hanya untuk notifikasi yang belum dibaca.
    // Ink (bukan Container) dipakai agar efek ketuk InkWell tetap terlihat di atas latar.
    return n.belumDibaca
        ? Ink(color: scheme.surfaceContainerLow, child: isi)
        : isi;
  }

  Widget _gambar(BuildContext context, Notifikasi n) {
    final scheme = Theme.of(context).colorScheme;
    final gambar = n.gambar;

    // Lencana memakai ikon, "diterima" memakai sampul sirkel, sisanya avatar orang.
    if (n.jenis == JenisNotifikasi.lencana || gambar == null) {
      return Container(
        width: _ukuranGambar,
        height: _ukuranGambar,
        decoration: BoxDecoration(
          color: scheme.tertiaryContainer,
          borderRadius: BorderRadius.circular(_radiusLencana),
        ),
        child: Icon(Icons.emoji_events, color: scheme.onTertiaryContainer),
      );
    }
    if (n.jenis == JenisNotifikasi.diterima) {
      return CoverImage(
        path: gambar,
        width: _ukuranGambar,
        height: _ukuranGambar,
        radius: _radiusSampul,
      );
    }
    return UserAvatar(imagePath: gambar, size: _ukuranGambar);
  }
}
