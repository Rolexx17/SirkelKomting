import 'package:flutter/material.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/utils/responsive.dart';
import '../../data/dummy/dummy_data.dart';
import '../../data/models/materi.dart';
import '../../routes/app_routes.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/materi_card.dart';
import 'materi_strings.dart';

/// Tab Materi: daftar materi dalam grid yang bisa disaring per mata kuliah.
/// Tanpa Scaffold sendiri karena navigasi dipegang MainShell.
class RuangMateriScreen extends StatefulWidget {
  const RuangMateriScreen({super.key});

  @override
  State<RuangMateriScreen> createState() => _RuangMateriScreenState();
}

class _RuangMateriScreenState extends State<RuangMateriScreen> {
  /// Mata kuliah yang dipilih; null berarti chip "Semua".
  String? _terpilih;

  Future<void> _bukaDetail(Materi materi) async {
    // Hanya id yang dikirim; Detail Materi mengambil datanya sendiri lewat cariMateri.
    await Navigator.pushNamed(context, AppRoutes.detailMateri, arguments: materi.id);
    // Setelah kembali, bangun ulang grid agar penanda "tersimpan" di kartu ikut berubah.
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final semua = DummyData.semuaMateri;

    // Chip hanya untuk mata kuliah yang punya materi, urut sesuai daftar mata kuliah.
    final mataKuliahChip = DummyData.daftarMataKuliah
        .where((mk) => semua.any((m) => m.mataKuliah == mk))
        .toList();

    // Filter: "Semua" menampilkan semuanya, chip lain hanya mata kuliah yang sama.
    final hasil = _terpilih == null
        ? semua
        : semua.where((m) => m.mataKuliah == _terpilih).toList();

    // P7: kolom grid 2 (< 600), 3 (600–839), 4 (≥ 840).
    final kolom = Responsive.columns(context, compact: 2, medium: 3, expanded: 4);

    // P7: tinggi sel = sampul + isi kartu dikali skala teks pengguna,
    // supaya kartu tidak overflow ketika ukuran huruf diperbesar.
    final skalaTeks =
        MediaQuery.textScalerOf(context).scale(AppSizes.m) / AppSizes.m;
    final tinggiSel = MateriCard.tinggiSampul + MateriCard.tinggiIsi * skalaTeks;

    return SafeArea(
      bottom: false,
      // P6: CustomScrollView agar judul, chip, dan grid tergulir bersama
      // (aman di landscape 800×360).
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.pagePadding,
              AppSizes.pagePadding,
              AppSizes.pagePadding,
              AppSizes.m,
            ),
            sliver: SliverToBoxAdapter(child: _buildHeader(context)),
          ),
          SliverToBoxAdapter(child: _buildChips(mataKuliahChip)),
          const SliverToBoxAdapter(child: SizedBox(height: AppSizes.m)),
          if (hasil.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(AppSizes.pagePadding),
                child: EmptyState(
                  title: MateriStrings.kosongJudul,
                  message: MateriStrings.kosongPesan,
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.pagePadding,
                0,
                AppSizes.pagePadding,
                AppSizes.pagePadding,
              ),
              // P6: GridView (versi sliver) dengan jumlah kolom dari Responsive.
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: kolom,
                  mainAxisSpacing: AppSizes.m,
                  crossAxisSpacing: AppSizes.m,
                  mainAxisExtent: tinggiSel,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, i) => MateriCard(
                    materi: hasil[i],
                    onTap: () => _bukaDetail(hasil[i]),
                  ),
                  childCount: hasil.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(MateriStrings.judul, style: text.titleLarge),
        const SizedBox(height: AppSizes.xs),
        Text(
          MateriStrings.subjudul,
          style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildChips(List<String> mataKuliah) {
    // P6: Row di dalam scroll horizontal agar chip bisa digeser di layar sempit.
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.pagePadding),
      child: Row(
        spacing: AppSizes.s,
        children: [
          FilterChip(
            label: const Text(MateriStrings.semua),
            selected: _terpilih == null,
            onSelected: (_) => setState(() => _terpilih = null),
          ),
          for (final mk in mataKuliah)
            FilterChip(
              label: Text(mk),
              selected: _terpilih == mk,
              // Mengetuk chip yang sudah aktif mengembalikan ke "Semua".
              onSelected: (pilih) => setState(() => _terpilih = pilih ? mk : null),
            ),
        ],
      ),
    );
  }
}
