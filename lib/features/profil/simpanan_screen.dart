import 'package:flutter/material.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/utils/responsive.dart';
import '../../data/dummy/dummy_data.dart';
import '../../routes/app_routes.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/materi_card.dart';
import '../../shared/widgets/sirkel_card.dart';
import 'profil_strings.dart';

enum _Tab { sirkel, materi }

/// Halaman Simpanan: sirkel dan materi yang disimpan pengguna, dibuka dari menu Profil.
class SimpananScreen extends StatefulWidget {
  const SimpananScreen({super.key});

  @override
  State<SimpananScreen> createState() => _SimpananScreenState();
}

class _SimpananScreenState extends State<SimpananScreen> {
  _Tab _tab = _Tab.sirkel;

  // Setelah kembali dari Detail, daftar dibaca ulang: item yang batal disimpan
  // di Detail langsung hilang dari sini.
  Future<void> _buka(String route, String id) async {
    await Navigator.of(context).pushNamed(route, arguments: id);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final sirkel = DummyData.sirkelTersimpan;
    final materi = DummyData.materiTersimpan;
    final kosong = _tab == _Tab.sirkel ? sirkel.isEmpty : materi.isEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text(ProfilStrings.simpananJudul)),
      body: SafeArea(
        top: false,
        // P6: CustomScrollView agar tombol segmen dan grid tergulir bersama
        // (aman di HP landscape yang tingginya ±430).
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.pagePadding,
                AppSizes.s,
                AppSizes.pagePadding,
                AppSizes.l,
              ),
              sliver: SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: AppSizes.maxContentWidth,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: SegmentedButton<_Tab>(
                        segments: [
                          ButtonSegment(
                            value: _Tab.sirkel,
                            icon: const Icon(Icons.groups),
                            label: Text(ProfilStrings.tabSirkel(sirkel.length)),
                          ),
                          ButtonSegment(
                            value: _Tab.materi,
                            icon: const Icon(Icons.menu_book),
                            label: Text(ProfilStrings.tabMateri(materi.length)),
                          ),
                        ],
                        selected: {_tab},
                        onSelectionChanged: (pilihan) =>
                            setState(() => _tab = pilihan.first),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (kosong)
              // hasScrollBody false: EmptyState mengisi sisa layar dan ditengahkan.
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.pagePadding),
                  child: _tab == _Tab.sirkel
                      ? const EmptyState(
                          title: ProfilStrings.sirkelKosongJudul,
                          message: ProfilStrings.sirkelKosongPesan,
                        )
                      : const EmptyState(
                          title: ProfilStrings.materiKosongJudul,
                          message: ProfilStrings.materiKosongPesan,
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
                sliver: _tab == _Tab.sirkel
                    ? _gridSirkel(context)
                    : _gridMateri(context),
              ),
          ],
        ),
      ),
    );
  }

  /// Skala huruf pengguna; tinggi sel grid dikali angka ini agar kartu tidak terpotong.
  double _skalaTeks(BuildContext context) =>
      MediaQuery.textScalerOf(context).scale(AppSizes.m) / AppSizes.m;

  Widget _gridSirkel(BuildContext context) {
    final daftar = DummyData.sirkelTersimpan;
    // P7: 1 kolom di ponsel, 2 di 600–839, 3 di ≥ 840 (sama dengan Jelajah).
    final kolom = Responsive.columns(context, compact: 1, medium: 2, expanded: 3);
    // Kartu dibuat compact (sampul lebih pendek) bila grid lebih dari 1 kolom.
    final compact = kolom > 1;
    final tinggiSel =
        (compact ? AppSizes.coverCardCompact : AppSizes.coverCard) +
            AppSizes.sirkelCardBody * _skalaTeks(context);

    // P6: GridView versi sliver dengan tinggi sel tetap.
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: kolom,
        mainAxisSpacing: AppSizes.m,
        crossAxisSpacing: AppSizes.m,
        mainAxisExtent: tinggiSel,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, i) => SirkelCard(
          sirkel: daftar[i],
          compact: compact,
          onTap: () => _buka(AppRoutes.detailSirkel, daftar[i].id),
        ),
        childCount: daftar.length,
      ),
    );
  }

  Widget _gridMateri(BuildContext context) {
    final daftar = DummyData.materiTersimpan;
    // P7: 2 kolom di ponsel, 3 di 600–839, 4 di ≥ 840 (sama dengan Ruang Materi).
    final kolom = Responsive.columns(context, compact: 2, medium: 3, expanded: 4);
    final tinggiSel =
        MateriCard.tinggiSampul + MateriCard.tinggiIsi * _skalaTeks(context);

    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: kolom,
        mainAxisSpacing: AppSizes.m,
        crossAxisSpacing: AppSizes.m,
        mainAxisExtent: tinggiSel,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, i) => MateriCard(
          materi: daftar[i],
          onTap: () => _buka(AppRoutes.detailMateri, daftar[i].id),
        ),
        childCount: daftar.length,
      ),
    );
  }
}
