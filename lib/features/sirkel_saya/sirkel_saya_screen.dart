import 'package:flutter/material.dart';

import '../../core/constants/app_sizes.dart';
import '../../data/dummy/dummy_data.dart';
import '../../data/models/sesi.dart';
import '../../data/models/sirkel.dart';
import '../../routes/app_routes.dart';
import '../../shared/widgets/cover_image.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/sirkel_card.dart';
import 'jadwal_util.dart';
import 'sirkel_saya_strings.dart';
import 'widgets/sesi_sheet.dart';

enum _Segmen { jadwal, sirkel }

/// Layar Sirkel Saya: jadwal sesi per minggu (bisa disaring per tanggal),
/// detail tiap sesi lewat bottom sheet, dan daftar sirkel yang diikuti.
class SirkelSayaScreen extends StatefulWidget {
  const SirkelSayaScreen({super.key});

  @override
  State<SirkelSayaScreen> createState() => _SirkelSayaScreenState();
}

class _SirkelSayaScreenState extends State<SirkelSayaScreen> {
  _Segmen _segmen = _Segmen.jadwal;

  /// 0 = minggu ini, 1 = minggu depan, dan seterusnya (selama masih ada data jadwal).
  int _mingguKe = 0;

  /// Tanggal yang dipilih di strip; null = tampilkan semua sesi.
  DateTime? _hariTerpilih;

  static const _lebarJam = 44.0;
  static const _ukuranSampul = 56.0;
  static const _ukuranTitik = 6.0;
  static const _ukuranIkonLokasi = 16.0;

  Future<void> _bukaDetail(String sirkelId) async {
    await Navigator.of(context).pushNamed(AppRoutes.detailSirkel, arguments: sirkelId);
    if (mounted) setState(() {});
  }

  /// Membuka sheet detail sesi lalu membangun ulang jadwal (sirkel bisa saja
  /// ditinggalkan lewat Detail Sirkel yang dibuka dari sheet).
  Future<void> _bukaSesi(Sirkel sirkel, Sesi sesi) async {
    await showSesiSheet(context, sirkel: sirkel, sesi: sesi);
    if (mounted) setState(() {});
  }

  void _pindahMinggu(int mingguKe) {
    setState(() {
      _mingguKe = mingguKe;
      // Tanggal terpilih milik minggu lama, jadi saringannya dilepas.
      _hariTerpilih = null;
    });
  }

  void _pilihHari(DateTime tgl) {
    // Mengetuk tanggal yang sama sekali lagi membatalkan saringan.
    setState(() {
      final sama = _hariTerpilih != null && hariSama(_hariTerpilih!, tgl);
      _hariTerpilih = sama ? null : awalHari(tgl);
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final sekarang = DateTime.now();
    final diikuti = DummyData.sirkelDiikuti;
    // Sesi dari semua sirkel yang diikuti, sekarang s.d. 14 hari ke depan (data milik Ethan).
    final sesi = DummyData.jadwalSesi;
    final terdekat = sesiTerdekat(sesi, sekarang);

    // P7: seluruh Scaffold (termasuk AppBar) dibatasi 560 px dan ditengahkan di atas
    // latar surface, sehingga judul AppBar sejajar dengan isi di layar lebar.
    return ColoredBox(
      color: scheme.surface,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSizes.maxContentWidth),
          child: Scaffold(
            appBar: AppBar(title: const Text(SirkelSayaStrings.judul)),
            body: SafeArea(
              top: false,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSizes.pagePadding,
                      AppSizes.s,
                      AppSizes.pagePadding,
                      AppSizes.m,
                    ),
                    // P4: SegmentedButton Material 3 untuk berpindah dua tampilan.
                    child: SegmentedButton<_Segmen>(
                      expandedInsets: EdgeInsets.zero,
                      segments: [
                        const ButtonSegment(
                          value: _Segmen.jadwal,
                          label: Text(SirkelSayaStrings.jadwal),
                        ),
                        ButtonSegment(
                          value: _Segmen.sirkel,
                          label: Text(SirkelSayaStrings.sirkel(diikuti.length)),
                        ),
                      ],
                      selected: {_segmen},
                      onSelectionChanged: (pilihan) =>
                          setState(() => _segmen = pilihan.first),
                    ),
                  ),
                  Expanded(
                    child: _segmen == _Segmen.jadwal
                        ? _tabJadwal(context, sesi, terdekat, sekarang)
                        : _tabSirkel(diikuti),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- Tab Jadwal ----------------

  Widget _tabJadwal(
    BuildContext context,
    List<Sesi> sesi,
    Sesi? terdekat,
    DateTime sekarang,
  ) {
    final text = Theme.of(context).textTheme;

    // Data jadwal mencakup 14 hari, jadi minggu yang bisa dibuka dibatasi.
    final jumlah = jumlahMinggu(sekarang, DummyData.rentangJadwalHari);
    final mingguKe = _mingguKe.clamp(0, jumlah - 1);
    final hari = mingguDari(
      DateTime(sekarang.year, sekarang.month, sekarang.day + 7 * mingguKe),
    );

    // Saringan dua tahap: (1) hanya sesi di minggu yang tampil di strip,
    // (2) bila ada tanggal terpilih, hanya sesi tanggal itu.
    final sesiMinggu =
        sesi.where((s) => hari.any((h) => hariSama(h, s.waktu))).toList();
    final terpilih = _hariTerpilih;
    final tampil = terpilih == null
        ? sesiMinggu
        : sesiMinggu.where((s) => hariSama(s.waktu, terpilih)).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.pagePadding,
        0,
        AppSizes.pagePadding,
        AppSizes.pagePadding,
      ),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                SirkelSayaStrings.rentangMinggu(
                  tanggalSingkat(hari.first),
                  tanggalSingkat(hari.last),
                ),
                style: text.titleSmall,
              ),
            ),
            IconButton(
              tooltip: SirkelSayaStrings.mingguSebelumnya,
              onPressed: mingguKe > 0 ? () => _pindahMinggu(mingguKe - 1) : null,
              icon: const Icon(Icons.chevron_left),
            ),
            IconButton(
              tooltip: SirkelSayaStrings.mingguBerikutnya,
              onPressed: mingguKe < jumlah - 1
                  ? () => _pindahMinggu(mingguKe + 1)
                  : null,
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.xs),
        // P6: Row berisi 7 sel hari yang lebarnya dibagi rata dengan Expanded.
        Row(
          children: [
            for (final tgl in hari)
              Expanded(
                child: _selHari(
                  context,
                  tgl,
                  aktif: terpilih != null && hariSama(tgl, terpilih),
                  hariIni: hariSama(tgl, sekarang),
                  // Titik hanya untuk tanggal yang benar-benar punya sesi.
                  bertitik: sesi.any((s) => hariSama(s.waktu, tgl)),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSizes.l),
        if (terpilih != null)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.s),
            child: Row(
              children: [
                Expanded(
                  child: Text(tanggalPanjang(terpilih), style: text.titleMedium),
                ),
                TextButton(
                  onPressed: () => setState(() => _hariTerpilih = null),
                  child: const Text(SirkelSayaStrings.tampilkanSemua),
                ),
              ],
            ),
          ),
        if (tampil.isEmpty)
          terpilih != null
              ? const EmptyState(
                  title: SirkelSayaStrings.tidakAdaSesiJudul,
                  message: SirkelSayaStrings.tidakAdaSesiPesan,
                )
              : sesi.isEmpty
                  ? const EmptyState(
                      title: SirkelSayaStrings.jadwalKosongJudul,
                      message: SirkelSayaStrings.jadwalKosongPesan,
                    )
                  : const EmptyState(
                      title: SirkelSayaStrings.tidakAdaSesiMingguJudul,
                      message: SirkelSayaStrings.tidakAdaSesiMingguPesan,
                    )
        else
          ..._daftarSesi(
            context,
            tampil,
            terdekat,
            sekarang,
            // Saat disaring, judul tanggal sudah ada di baris "Tampilkan semua".
            denganJudulTanggal: terpilih == null,
          ),
      ],
    );
  }

  /// Baris-baris sesi; judul tanggal ditambahkan setiap kali tanggal berganti.
  List<Widget> _daftarSesi(
    BuildContext context,
    List<Sesi> daftar,
    Sesi? terdekat,
    DateTime sekarang, {
    required bool denganJudulTanggal,
  }) {
    final text = Theme.of(context).textTheme;
    final isi = <Widget>[];
    DateTime? tanggalSebelum;

    for (final s in daftar) {
      final sirkel = DummyData.cariSirkel(s.sirkelId);
      if (sirkel == null) continue;

      final hariBaru = tanggalSebelum == null || !hariSama(tanggalSebelum, s.waktu);
      final judulTanggal = hariBaru && denganJudulTanggal;
      if (isi.isNotEmpty) {
        isi.add(SizedBox(height: judulTanggal ? AppSizes.l : AppSizes.sm));
      }
      if (judulTanggal) {
        isi.add(
          Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.sm),
            child: Text(tanggalPanjang(s.waktu), style: text.titleMedium),
          ),
        );
      }
      tanggalSebelum = s.waktu;
      isi.add(
        _barisSesi(context, s, sirkel, sekarang, terdekat: identical(s, terdekat)),
      );
    }
    return isi;
  }

  Widget _selHari(
    BuildContext context,
    DateTime tgl, {
    required bool aktif,
    required bool hariIni,
    required bool bertitik,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    // Hari ini diberi warna primary agar mudah ditemukan walau belum dipilih.
    final warnaAngka = aktif
        ? scheme.onPrimary
        : (hariIni ? scheme.primary : scheme.onSurface);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.xs / 2),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: () => _pilihHari(tgl),
        // P5: Container berbentuk pil; berwarna primary hanya untuk hari terpilih.
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
          decoration: ShapeDecoration(
            color: aktif ? scheme.primary : null,
            shape: const StadiumBorder(),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                SirkelSayaStrings.namaHariSingkat[tgl.weekday - 1],
                style: text.bodySmall?.copyWith(
                  color: aktif ? scheme.onPrimary : scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSizes.xs),
              Text('${tgl.day}', style: text.titleLarge?.copyWith(color: warnaAngka)),
              const SizedBox(height: AppSizes.xs),
              // Titik tetap memakan tempat walau tersembunyi, agar tinggi semua sel sama.
              Visibility(
                visible: bertitik,
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true,
                child: Container(
                  width: _ukuranTitik,
                  height: _ukuranTitik,
                  decoration: BoxDecoration(
                    color: aktif ? scheme.onPrimary : scheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _barisSesi(
    BuildContext context,
    Sesi sesi,
    Sirkel sirkel,
    DateTime sekarang, {
    required bool terdekat,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final online = sirkel.mode == ModeBelajar.online;
    final bisaMasuk = bisaMasukSesi(sesi.waktu, sekarang);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: _lebarJam,
          child: Padding(
            padding: const EdgeInsets.only(top: AppSizes.sm),
            child: Text(jamDari(sesi.waktu), style: text.titleSmall),
          ),
        ),
        const SizedBox(width: AppSizes.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: InkWell(
                  onTap: () => _bukaSesi(sirkel, sesi),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.sm),
                    child: Row(
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
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: text.labelMedium
                                    ?.copyWith(color: scheme.primary),
                              ),
                              Text(
                                sirkel.judul,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: text.titleMedium,
                              ),
                              Row(
                                children: [
                                  Icon(
                                    online ? Icons.videocam : Icons.place,
                                    size: _ukuranIkonLokasi,
                                    color: scheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: AppSizes.xs),
                                  Expanded(
                                    child: Text(
                                      sirkel.lokasi,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: text.bodyMedium?.copyWith(
                                        color: scheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Baris waktu mulai + tombol sesi hanya untuk sesi terdekat.
              // Label "Masuk sesi" bila sudah ≤ 15 menit lagi, selain itu "Detail sesi".
              if (terdekat) ...[
                const SizedBox(height: AppSizes.s),
                Container(
                  padding: const EdgeInsets.fromLTRB(
                    AppSizes.m,
                    AppSizes.s,
                    AppSizes.s,
                    AppSizes.s,
                  ),
                  // Garis tepi (bukan latar primaryContainer) agar tombol
                  // primaryContainer di dalamnya tetap terlihat kontras.
                  decoration: BoxDecoration(
                    border: Border.all(color: scheme.outlineVariant),
                    borderRadius: BorderRadius.circular(AppSizes.radiusL),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        // Dihitung dari selisih waktu sesi dan sekarang.
                        child: Text(
                          teksMulai(sesi.waktu, sekarang),
                          style: text.labelLarge,
                        ),
                      ),
                      const SizedBox(width: AppSizes.s),
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: scheme.primaryContainer,
                          foregroundColor: scheme.onPrimaryContainer,
                        ),
                        onPressed: () => _bukaSesi(sirkel, sesi),
                        icon: Icon(bisaMasuk ? Icons.videocam : Icons.info_outline),
                        label: Text(
                          bisaMasuk
                              ? SirkelSayaStrings.masukSesi
                              : SirkelSayaStrings.detailSesi,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ---------------- Tab Sirkel ----------------

  Widget _tabSirkel(List<Sirkel> diikuti) {
    if (diikuti.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(AppSizes.pagePadding),
        child: EmptyState(
          title: SirkelSayaStrings.sirkelKosongJudul,
          message: SirkelSayaStrings.sirkelKosongPesan,
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.pagePadding,
        0,
        AppSizes.pagePadding,
        AppSizes.pagePadding,
      ),
      itemCount: diikuti.length,
      separatorBuilder: (context, i) => const SizedBox(height: AppSizes.m),
      itemBuilder: (context, i) => SirkelCard(
        sirkel: diikuti[i],
        onTap: () => _bukaDetail(diikuti[i].id),
      ),
    );
  }
}
