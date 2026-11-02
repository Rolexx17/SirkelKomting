import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/constants/app_sizes.dart';
import '../../data/models/materi.dart';
import 'materi_strings.dart';

/// Pembaca materi (simulasi): satu "kertas" per poin isi materi yang digeser dengan
/// PageView, plus deretan thumbnail bagian memakai CarouselView Material 3.
class PembacaMateriScreen extends StatefulWidget {
  const PembacaMateriScreen({super.key, required this.materi});

  final Materi materi;

  @override
  State<PembacaMateriScreen> createState() => _PembacaMateriScreenState();
}

class _PembacaMateriScreenState extends State<PembacaMateriScreen> {
  final _halamanController = PageController();
  final _carouselController = CarouselController();
  int _bagian = 0;

  static const _durasiGeser = Duration(milliseconds: 250);
  static const _tinggiCarousel = 80.0;
  static const _lebarThumbnail = 140.0;
  static const _batasTinggiHp = 600.0;

  Materi get _materi => widget.materi;
  int get _jumlah => _materi.jumlahBagian;
  bool get _bagianTerakhir => _bagian == _jumlah - 1;

  /// Judul bagian ke-[i] = poin isi; bila materi tanpa isi, pakai judul materi.
  String _judulBagian(int i) =>
      i < _materi.isi.length ? _materi.isi[i] : _materi.judul;

  @override
  void dispose() {
    _halamanController.dispose();
    _carouselController.dispose();
    super.dispose();
  }

  void _keBagian(int i) {
    _halamanController.animateToPage(
      i,
      duration: _durasiGeser,
      curve: Curves.easeOut,
    );
  }

  void _saatBagianBerubah(int i) {
    setState(() => _bagian = i);
    // Thumbnail ikut bergeser ke bagian aktif. hasClients dicek karena carousel
    // disembunyikan di HP landscape (controller-nya tidak terpasang).
    if (_carouselController.hasClients) {
      _carouselController.animateToItem(
        i,
        duration: _durasiGeser,
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final rentang = _materi.rentangHalaman(_bagian);

    // P7 (orientasi): di HP landscape tinggi layar sempit, jadi deretan thumbnail
    // disembunyikan agar kertas tetap terbaca.
    final landscapeHp =
        MediaQuery.orientationOf(context) == Orientation.landscape &&
            MediaQuery.sizeOf(context).height < _batasTinggiHp;

    return Scaffold(
      backgroundColor: scheme.surfaceContainer,
      appBar: AppBar(
        backgroundColor: scheme.surfaceContainer,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_materi.judul, maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(
              MateriStrings.subjudulPembaca(
                _bagian + 1,
                _jumlah,
                rentang.awal,
                rentang.akhir,
              ),
              style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            // P6: PageView menggeser satu bagian penuh setiap kali.
            child: PageView.builder(
              controller: _halamanController,
              itemCount: _jumlah,
              onPageChanged: _saatBagianBerubah,
              itemBuilder: (context, i) => _HalamanKertas(
                judul: _judulBagian(i),
                catatan: i < _materi.catatan.length ? _materi.catatan[i] : null,
                nomor: i,
              ),
            ),
          ),
          if (!landscapeHp && _jumlah > 1)
            SizedBox(
              height: _tinggiCarousel,
              // P6: CarouselView (Material 3) berisi thumbnail bagian; ketuk untuk lompat.
              child: CarouselView(
                controller: _carouselController,
                itemExtent: _lebarThumbnail,
                padding: const EdgeInsets.all(AppSizes.xs),
                onTap: _keBagian,
                children: [
                  for (var i = 0; i < _jumlah; i++)
                    _Thumbnail(
                      label: MateriStrings.labelBagian(i + 1),
                      judul: _judulBagian(i),
                      aktif: i == _bagian,
                    ),
                ],
              ),
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.pagePadding,
            vertical: AppSizes.sm,
          ),
          child: Center(
            heightFactor: 1,
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(maxWidth: AppSizes.maxContentWidth),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      // Tombol nonaktif (null) di bagian pertama.
                      onPressed: _bagian > 0 ? () => _keBagian(_bagian - 1) : null,
                      icon: const Icon(Icons.chevron_left),
                      label: const Text(MateriStrings.sebelumnya),
                    ),
                  ),
                  const SizedBox(width: AppSizes.m),
                  Expanded(
                    child: FilledButton(
                      // Di bagian terakhir tombol menjadi "Selesai" dan menutup pembaca.
                      onPressed: _bagianTerakhir
                          ? () => Navigator.pop(context)
                          : () => _keBagian(_bagian + 1),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              _bagianTerakhir
                                  ? MateriStrings.selesai
                                  : MateriStrings.berikutnya,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: AppSizes.s),
                          Icon(
                            _bagianTerakhir ? Icons.check : Icons.chevron_right,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Satu thumbnail di carousel: label bagian + judul poin (maks. 2 baris).
class _Thumbnail extends StatelessWidget {
  const _Thumbnail({
    required this.label,
    required this.judul,
    required this.aktif,
  });

  final String label;
  final String judul;
  final bool aktif;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final warnaTeks = aktif ? scheme.onPrimaryContainer : scheme.onSurfaceVariant;

    return ColoredBox(
      color: aktif ? scheme.primaryContainer : scheme.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.sm,
          vertical: AppSizes.s,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: text.labelMedium?.copyWith(color: warnaTeks)),
            Flexible(
              child: Text(
                judul,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: text.bodySmall?.copyWith(color: warnaTeks),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Satu halaman "kertas": judul poin, kalimat catatan, lalu garis abu sebagai sisa tulisan.
class _HalamanKertas extends StatelessWidget {
  const _HalamanKertas({
    required this.judul,
    required this.catatan,
    required this.nomor,
  });

  final String judul;
  final String? catatan;
  final int nomor;

  // Pola panjang garis; digeser per halaman agar tiap halaman tampak berbeda.
  static const _pola = [1.0, 0.92, 0.97, 0.6, 1.0, 0.85, 0.7, 0.95, 0.5];
  static const _tinggiBaris = AppSizes.s + AppSizes.sm;

  /// Batas garis agar kertas tetap minimalis di layar yang sangat tinggi.
  static const _maksGaris = 12;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final catatan = this.catatan;

    // P7: kertas maksimal 560 px dan selalu memenuhi tinggi yang tersedia.
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppSizes.maxContentWidth),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.pagePadding),
          child: Container(
            padding: const EdgeInsets.all(AppSizes.l),
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(AppSizes.radiusS),
              border: Border.all(color: scheme.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  judul,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: text.titleMedium,
                ),
                if (catatan != null) ...[
                  const SizedBox(height: AppSizes.s),
                  Text(
                    catatan,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: text.bodyMedium,
                  ),
                ],
                const SizedBox(height: AppSizes.s),
                // P7: banyaknya garis dihitung dari tinggi yang tersisa (constraints),
                // jadi kertas tidak overflow baik di portrait maupun landscape.
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final muat = (constraints.maxHeight / _tinggiBaris).floor();
                      final jumlah = math.max(0, math.min(muat, _maksGaris));
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (var b = 0; b < jumlah; b++)
                            Padding(
                              padding: const EdgeInsets.only(top: AppSizes.sm),
                              child: FractionallySizedBox(
                                widthFactor: _pola[(b + nomor) % _pola.length],
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  height: AppSizes.s,
                                  decoration: BoxDecoration(
                                    color: scheme.outlineVariant,
                                    borderRadius:
                                        BorderRadius.circular(AppSizes.xs),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
