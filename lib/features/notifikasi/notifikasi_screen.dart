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
/// dengan status belum dibaca yang disimpan di DummyData.
class NotifikasiScreen extends StatefulWidget {
  const NotifikasiScreen({super.key});

  /// Hasil `Navigator.pop` saat notifikasi lencana/mentor diketuk; Beranda lalu membuka tab Profil.
  static const hasilBukaProfil = 'profil';

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
  static const _ukuranGambar = AppSizes.avatarM;
  static const _radiusSampul = 12.0;
  static const _radiusLencana = 14.0;
  static const _ukuranTitik = 8.0;

  void _tandaiSemuaDibaca() {
    // Status disimpan di DummyData (bukan salinan lokal), sehingga Badge lonceng
    // di Beranda ikut hilang setelah kembali.
    setState(() => DummyData.tandaiSemuaNotifikasiDibaca());
  }

  void _ketuk(Notifikasi n) {
    setState(() => DummyData.tandaiNotifikasiDibaca(n.id));

    final sirkelId = n.sirkelId;
    if (sirkelId != null) {
      Navigator.of(context).pushNamed(AppRoutes.detailSirkel, arguments: sirkelId);
    } else if (n.jenis == JenisNotifikasi.lencana ||
        n.jenis == JenisNotifikasi.mentor) {
      // Lencana dan status mentor tampil di Profil: tutup Notifikasi dan minta
      // Beranda membuka tab Profil.
      Navigator.of(context).pop(NotifikasiScreen.hasilBukaProfil);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final daftar = DummyData.notifikasi;
    final adaBelumDibaca = DummyData.adaNotifikasiBaru;

    // Urutan grup mengikuti urutan kemunculan di data ("Hari ini" lalu "Minggu ini").
    final grup = <String>[];
    for (final n in daftar) {
      if (!grup.contains(n.grup)) grup.add(n.grup);
    }

    // P7: seluruh Scaffold (termasuk AppBar) dibatasi 560 px dan ditengahkan di atas
    // latar surface, sehingga judul & "Tandai dibaca" sejajar dengan isi di layar lebar.
    return ColoredBox(
      color: scheme.surface,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSizes.maxContentWidth),
          child: Scaffold(
            appBar: AppBar(
              title: const Text(NotifikasiStrings.judul),
              actions: [
                TextButton(
                  // Nonaktif bila semua sudah dibaca.
                  onPressed: adaBelumDibaca ? _tandaiSemuaDibaca : null,
                  child: const Text(NotifikasiStrings.tandaiDibaca),
                ),
                const SizedBox(width: AppSizes.s),
              ],
            ),
            body: daftar.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(AppSizes.pagePadding),
                    child: EmptyState(
                      title: NotifikasiStrings.kosongJudul,
                      message: NotifikasiStrings.kosongPesan,
                    ),
                  )
                // P6: ListView vertikal berisi judul grup dan item notifikasi.
                : ListView(
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
                        for (final n in daftar.where((x) => x.grup == g))
                          _item(context, n),
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _item(BuildContext context, Notifikasi n) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final isi = InkWell(
      onTap: () => _ketuk(n),
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

    // Lencana & mentor memakai kotak ikon, "diterima" memakai sampul sirkel,
    // sisanya avatar orang. Tanpa gambar → kotak ikon sebagai cadangan.
    if (n.jenis == JenisNotifikasi.mentor) {
      return _kotakIkon(
        Icons.school,
        scheme.secondaryContainer,
        scheme.onSecondaryContainer,
      );
    }
    if (n.jenis == JenisNotifikasi.lencana || gambar == null) {
      return _kotakIkon(
        Icons.emoji_events,
        scheme.tertiaryContainer,
        scheme.onTertiaryContainer,
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

  // P5: Container berhias (sudut 14) berisi ikon untuk notifikasi tanpa foto.
  Widget _kotakIkon(IconData ikon, Color latar, Color warnaIkon) {
    return Container(
      width: _ukuranGambar,
      height: _ukuranGambar,
      decoration: BoxDecoration(
        color: latar,
        borderRadius: BorderRadius.circular(_radiusLencana),
      ),
      child: Icon(ikon, color: warnaIkon),
    );
  }
}
