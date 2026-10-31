import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/constants/app_sizes.dart';
import '../../data/models/materi.dart';
import 'materi_strings.dart';

/// Pembaca materi (simulasi): halaman "kertas" yang digeser satu per satu dengan
/// PageView, plus deretan thumbnail halaman memakai CarouselView Material 3.
class PembacaMateriScreen extends StatefulWidget {
  const PembacaMateriScreen({super.key, required this.materi});

  final Materi materi;

  @override
  State<PembacaMateriScreen> createState() => _PembacaMateriScreenState();
}

class _PembacaMateriScreenState extends State<PembacaMateriScreen> {
  final _controller = PageController();
  int _halaman = 0;

  static const _maksHalaman = 12;
  static const _durasiGeser = Duration(milliseconds: 250);
  static const _tinggiCarousel = 72.0;
  static const _lebarThumbnail = 56.0;
  static const _batasTinggiHp = 600.0;

  /// Jumlah halaman = halaman materi, minimal 1 dan maksimal 12.
  int get _jumlah => math.max(1, math.min(widget.materi.halaman, _maksHalaman));

  bool get _halamanTerakhir => _halaman == _jumlah - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _keHalaman(int i) {
    _controller.animateToPage(i, duration: _durasiGeser, curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    // P7 (orientasi): di HP landscape tinggi layar sempit, jadi deretan thumbnail
    // disembunyikan agar halaman kertas tetap terbaca.
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
            Text(
              widget.materi.judul,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              MateriStrings.indikatorHalaman(_halaman + 1, _jumlah),
              style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            // P6: PageView menggeser satu halaman penuh setiap kali.
            child: PageView.builder(
              controller: _controller,
              itemCount: _jumlah,
              onPageChanged: (i) => setState(() => _halaman = i),
              itemBuilder: (context, i) => _HalamanKertas(
                judul: i < widget.materi.isi.length
                    ? widget.materi.isi[i]
                    : MateriStrings.judulHalaman(i + 1),
                nomor: i,
              ),
            ),
          ),
          if (!landscapeHp && _jumlah > 1)
            SizedBox(
              height: _tinggiCarousel,
              // P6: CarouselView (Material 3) berisi thumbnail; ketuk untuk lompat halaman.
              child: CarouselView(
                itemExtent: _lebarThumbnail,
                padding: const EdgeInsets.all(AppSizes.xs),
                onTap: _keHalaman,
                children: [
                  for (var i = 0; i < _jumlah; i++)
                    ColoredBox(
                      color: i == _halaman
                          ? scheme.primaryContainer
                          : scheme.surface,
                      child: Center(
                        child: Text(
                          MateriStrings.labelThumbnail(i + 1),
                          style: text.labelLarge?.copyWith(
                            color: i == _halaman
                                ? scheme.onPrimaryContainer
                                : scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
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
                      // Tombol nonaktif (null) di halaman pertama.
                      onPressed:
                          _halaman > 0 ? () => _keHalaman(_halaman - 1) : null,
                      icon: const Icon(Icons.chevron_left),
                      label: const Text(MateriStrings.sebelumnya),
                    ),
                  ),
                  const SizedBox(width: AppSizes.m),
                  Expanded(
                    child: FilledButton(
                      // Di halaman terakhir tombol berubah menjadi "Selesai" dan menutup pembaca.
                      onPressed: _halamanTerakhir
                          ? () => Navigator.pop(context)
                          : () => _keHalaman(_halaman + 1),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              _halamanTerakhir
                                  ? MateriStrings.selesai
                                  : MateriStrings.berikutnya,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: AppSizes.s),
                          Icon(
                            _halamanTerakhir ? Icons.check : Icons.chevron_right,
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

/// Satu halaman "kertas": judul poin materi lalu garis-garis abu sebagai isi tulisan.
class _HalamanKertas extends StatelessWidget {
  const _HalamanKertas({required this.judul, required this.nomor});

  final String judul;
  final int nomor;

  // Pola panjang garis; digeser per halaman agar tiap halaman tampak berbeda.
  static const _pola = [1.0, 0.92, 0.97, 0.6, 1.0, 0.85, 0.7, 0.95, 0.5];
  static const _tinggiBaris = AppSizes.s + AppSizes.sm;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

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
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSizes.s),
                // P7: banyaknya garis dihitung dari tinggi yang tersisa (constraints),
                // jadi halaman tidak overflow baik di portrait maupun landscape.
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final jumlah =
                          (constraints.maxHeight / _tinggiBaris).floor();
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
