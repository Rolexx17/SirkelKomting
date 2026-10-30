import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../data/dummy/dummy_data.dart';
import '../../data/models/materi.dart';
import '../../shared/widgets/cover_image.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/user_avatar.dart';
import 'materi_strings.dart';

/// Layar Detail Materi. Id materi dikirim lewat argumen route `/detail-materi`
/// (atau lewat [materiId]), lalu datanya diambil dengan `DummyData.cariMateri`.
class DetailMateriScreen extends StatelessWidget {
  const DetailMateriScreen({super.key, this.materiId});

  /// Opsional; bila null, id dibaca dari `ModalRoute.settings.arguments`.
  final String? materiId;

  void _snack(BuildContext context, String pesan) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(pesan)));
  }

  @override
  Widget build(BuildContext context) {
    // Navigasi dengan argumen: id dikirim RuangMateriScreen lewat pushNamed.
    final arg = ModalRoute.of(context)?.settings.arguments;
    final id = materiId ?? (arg is String ? arg : null);
    final materi = id == null ? null : DummyData.cariMateri(id);

    if (materi == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Padding(
          padding: EdgeInsets.all(AppSizes.pagePadding),
          child: EmptyState(
            title: MateriStrings.tidakDitemukan,
            message: MateriStrings.tidakDitemukanPesan,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            tooltip: MateriStrings.simpan,
            icon: const Icon(Icons.bookmark_border),
            onPressed: () => _snack(context, MateriStrings.disimpan),
          ),
        ],
      ),
      body: SingleChildScrollView(
        // P7: konten dibatasi 560 px dan ditengahkan di layar lebar.
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppSizes.maxContentWidth),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.pagePadding,
                AppSizes.s,
                AppSizes.pagePadding,
                AppSizes.pagePadding,
              ),
              child: _Konten(materi: materi),
            ),
          ),
        ),
      ),
      bottomNavigationBar: _BarBawah(
        onSimpan: () => _snack(context, MateriStrings.disimpan),
        onBuka: () => _snack(context, AppStrings.simulasi),
      ),
    );
  }
}

class _Konten extends StatelessWidget {
  const _Konten({required this.materi});

  final Materi materi;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final pengunggah = materi.pengunggah;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Pratinjau(materi: materi),
        const SizedBox(height: AppSizes.xl),
        Text(materi.judul, style: text.titleLarge),
        const SizedBox(height: AppSizes.sm),
        // P6: Wrap agar chip turun ke baris baru bila layar sempit.
        Wrap(
          spacing: AppSizes.s,
          runSpacing: AppSizes.s,
          children: [
            _InfoChip(
              icon: Icons.description,
              label: MateriStrings.formatHalaman(materi.format, materi.halaman),
            ),
            _InfoChip(icon: Icons.menu_book, label: materi.mataKuliah),
          ],
        ),
        const SizedBox(height: AppSizes.l),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.m),
            child: Row(
              children: [
                UserAvatar(imagePath: pengunggah.avatar, size: _ukuranAvatar),
                const SizedBox(width: AppSizes.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(pengunggah.nama, style: text.titleSmall),
                      Text(
                        MateriStrings.infoPengunggah(
                          pengunggah.isMentor,
                          materi.waktu,
                        ),
                        style: text.bodySmall
                            ?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSizes.xl),
        Text(MateriStrings.isiMateri, style: text.titleMedium),
        const SizedBox(height: AppSizes.s),
        // Daftar bernomor: nomor diberi lebar tetap agar teks sejajar rapi.
        for (final (i, poin) in materi.isi.indexed)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSizes.xs),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: AppSizes.xl,
                  child: Text('${i + 1}.', style: text.bodyLarge),
                ),
                Expanded(child: Text(poin, style: text.bodyLarge)),
              ],
            ),
          ),
      ],
    );
  }

  static const _ukuranAvatar = 40.0;
}

/// Pratinjau 200 px: sampul di belakang dan "kertas" miring di depannya.
class _Pratinjau extends StatelessWidget {
  const _Pratinjau({required this.materi});

  final Materi materi;

  static const _tinggi = 200.0;
  static const _radius = 20.0;

  // Transform.rotate memakai radian: −3° × π / 180 ≈ −0,052 rad (miring ke kiri).
  static const _sudut = -3 * math.pi / 180;

  @override
  Widget build(BuildContext context) {
    // P5 & P6: ClipRRect memotong sudut, Stack menumpuk kertas di atas sampul.
    return ClipRRect(
      borderRadius: BorderRadius.circular(_radius),
      child: SizedBox(
        height: _tinggi,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CoverImage(path: materi.cover, radius: 0),
            // P5: Align menurunkan kertas sedikit; FractionallySizedBox membuat
            // ukurannya mengikuti lebar kotak sehingga tetap proporsional.
            Align(
              alignment: const Alignment(0, 0.6),
              child: FractionallySizedBox(
                widthFactor: 0.42,
                heightFactor: 0.84,
                child: Transform.rotate(
                  angle: _sudut,
                  child: _Kertas(judul: materi.judul),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Kertas extends StatelessWidget {
  const _Kertas({required this.judul});

  final String judul;

  // Panjang relatif garis-garis "tulisan" di kertas.
  static const _garis = [1.0, 1.0, 0.6, 1.0, 0.55];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSizes.m),
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusS),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.12),
            blurRadius: AppSizes.s,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            judul,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          for (final lebar in _garis) ...[
            const SizedBox(height: AppSizes.s),
            FractionallySizedBox(
              widthFactor: lebar,
              alignment: Alignment.centerLeft,
              child: Container(
                height: AppSizes.s,
                decoration: BoxDecoration(
                  color: scheme.outlineVariant,
                  borderRadius: BorderRadius.circular(AppSizes.xs),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Chip(
      avatar: Icon(icon, color: scheme.onSurfaceVariant),
      label: Text(label),
      backgroundColor: scheme.surfaceContainerLow,
      side: BorderSide.none,
    );
  }
}

/// Bar bawah tetap: Simpan (outlined) + Buka materi (filled).
class _BarBawah extends StatelessWidget {
  const _BarBawah({required this.onSimpan, required this.onBuka});

  final VoidCallback onSimpan;
  final VoidCallback onBuka;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.pagePadding,
            vertical: AppSizes.m,
          ),
          child: Center(
            heightFactor: 1,
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(maxWidth: AppSizes.maxContentWidth),
              // P6: Row dengan Expanded berbanding 3:4 seperti mockup.
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: OutlinedButton.icon(
                      onPressed: onSimpan,
                      icon: const Icon(Icons.bookmark_border),
                      label: const Text(MateriStrings.simpan),
                    ),
                  ),
                  const SizedBox(width: AppSizes.m),
                  Expanded(
                    flex: 4,
                    child: FilledButton.icon(
                      onPressed: onBuka,
                      icon: const Icon(Icons.visibility_outlined),
                      label: const Text(MateriStrings.bukaMateri),
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
