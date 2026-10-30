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

enum _Segmen { jadwal, sirkel }

/// Layar Sirkel Saya: jadwal mingguan sesi dan daftar sirkel yang diikuti.
class SirkelSayaScreen extends StatefulWidget {
  const SirkelSayaScreen({super.key});

  @override
  State<SirkelSayaScreen> createState() => _SirkelSayaScreenState();
}

class _SirkelSayaScreenState extends State<SirkelSayaScreen> {
  _Segmen _segmen = _Segmen.jadwal;

  /// Hari yang disorot di strip; null = hari sesi terdekat.
  DateTime? _hariTerpilih;

  static const _lebarJam = 44.0;
  static const _ukuranSampul = 56.0;
  static const _ukuranTitik = 6.0;
  static const _ukuranIkonLokasi = 16.0;

  Future<void> _bukaDetail(String sirkelId) async {
    await Navigator.of(context).pushNamed(AppRoutes.detailSirkel, arguments: sirkelId);
    if (mounted) setState(() {});
  }

  void _masukSesi(Sirkel sirkel) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(SirkelSayaStrings.masukSesiInfo(sirkel.mataKuliah))),
      );
  }

  @override
  Widget build(BuildContext context) {
    final diikuti = DummyData.sirkelDiikuti;

    // Hanya sesi dari sirkel yang diikuti, diurutkan dari yang paling awal.
    final idDiikuti = diikuti.map((s) => s.id).toSet();
    final sesi = DummyData.jadwalSesi
        .where((s) => idDiikuti.contains(s.sirkelId))
        .toList()
      ..sort((a, b) => a.waktu.compareTo(b.waktu));
    final terdekat = sesiTerdekat(sesi, DateTime.now());

    return Scaffold(
      appBar: AppBar(title: const Text(SirkelSayaStrings.judul)),
      body: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.topCenter,
          // P7: di layar lebar konten dibatasi AppSizes.maxContentWidth dan ditengahkan.
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppSizes.maxContentWidth),
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
                      ? _tabJadwal(context, sesi, terdekat, diikuti)
                      : _tabSirkel(diikuti),
                ),
              ],
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
    List<Sirkel> diikuti,
  ) {
    final text = Theme.of(context).textTheme;

    // Minggu yang ditampilkan = minggu sesi terdekat (Sen 6 – Min 12 Okt pada data contoh).
    final acuan = terdekat?.waktu ?? DateTime.now();
    final terpilih = _hariTerpilih ?? awalHari(acuan);

    // Titik = hari rutin sirkel yang diikuti (Rabu, Kamis, Sabtu), sehingga
    // sirkel yang baru digabung ikut menandai harinya.
    final hariRutin =
        diikuti.map((s) => nomorHariDariNama(s.hari)).whereType<int>().toSet();

    // Daftar sesi dikelompokkan per tanggal: judul tanggal muncul saat tanggal berganti.
    final isi = <Widget>[];
    DateTime? tanggalSebelum;
    for (final s in sesi) {
      final sirkel = DummyData.cariSirkel(s.sirkelId);
      if (sirkel == null) continue;
      if (tanggalSebelum == null || !hariSama(tanggalSebelum, s.waktu)) {
        if (isi.isNotEmpty) isi.add(const SizedBox(height: AppSizes.l));
        isi.add(
          Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.sm),
            child: Text(tanggalPanjang(s.waktu), style: text.titleMedium),
          ),
        );
        tanggalSebelum = s.waktu;
      } else {
        isi.add(const SizedBox(height: AppSizes.sm));
      }
      isi.add(_barisSesi(context, s, sirkel, terdekat: identical(s, terdekat)));
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.pagePadding,
        0,
        AppSizes.pagePadding,
        AppSizes.pagePadding,
      ),
      children: [
        // P6: Row berisi 7 sel hari yang lebarnya dibagi rata dengan Expanded.
        Row(
          children: [
            for (final tgl in mingguDari(acuan))
              Expanded(
                child: _selHari(
                  context,
                  tgl,
                  aktif: hariSama(tgl, terpilih),
                  bertitik: hariRutin.contains(tgl.weekday),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSizes.l),
        if (isi.isEmpty)
          const EmptyState(
            title: SirkelSayaStrings.jadwalKosongJudul,
            message: SirkelSayaStrings.jadwalKosongPesan,
          )
        else
          ...isi,
      ],
    );
  }

  Widget _selHari(
    BuildContext context,
    DateTime tgl, {
    required bool aktif,
    required bool bertitik,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final warnaTeks = aktif ? scheme.onPrimary : scheme.onSurface;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.xs / 2),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: () => setState(() => _hariTerpilih = awalHari(tgl)),
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
              Text('${tgl.day}', style: text.titleLarge?.copyWith(color: warnaTeks)),
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
    Sirkel sirkel, {
    required bool terdekat,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final online = sirkel.mode == ModeBelajar.online;

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
                  onTap: () => _bukaDetail(sirkel.id),
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
              // Baris "Mulai dalam 1 jam" hanya untuk sesi terdekat.
              if (terdekat) ...[
                const SizedBox(height: AppSizes.s),
                Container(
                  padding: const EdgeInsets.fromLTRB(
                    AppSizes.m,
                    AppSizes.s,
                    AppSizes.s,
                    AppSizes.s,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(AppSizes.radiusL),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          SirkelSayaStrings.mulaiSatuJam,
                          style: text.labelLarge
                              ?.copyWith(color: scheme.onPrimaryContainer),
                        ),
                      ),
                      const SizedBox(width: AppSizes.s),
                      FilledButton.icon(
                        onPressed: () => _masukSesi(sirkel),
                        icon: const Icon(Icons.videocam),
                        label: const Text(SirkelSayaStrings.masukSesi),
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
