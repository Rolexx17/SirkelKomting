import 'package:flutter/material.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/utils/responsive.dart';
import '../../data/dummy/dummy_data.dart';
import '../../data/models/sirkel.dart';
import '../../routes/app_routes.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/sirkel_card.dart';
import '../sirkel/sirkel_strings.dart';
import '../sirkel/sirkel_waktu.dart';
import 'filter_sheet.dart';
import 'jelajah_strings.dart';

/// Menyaring daftar sirkel untuk Jelajah. Dipisah dari widget agar mudah diuji.
///
/// - [kataKunci]: dicocokkan ke mata kuliah atau judul, tidak peka huruf besar/kecil.
/// - [filter]: pilihan dari chip mode dan bottom sheet Filter.
/// - [mingguIni]: hanya sirkel yang harinya belum lewat pada minggu berjalan
///   (hari sesi ≥ [hariIni]); [hariIni] bisa diisi tanggal tetap saat pengujian.
List<Sirkel> saringSirkel(
  List<Sirkel> sumber, {
  String kataKunci = '',
  FilterSirkel filter = const FilterSirkel(),
  bool mingguIni = false,
  DateTime? hariIni,
}) {
  final kunci = kataKunci.trim().toLowerCase();
  final nomorHariIni = (hariIni ?? DateTime.now()).weekday;

  return sumber.where((s) {
    if (kunci.isNotEmpty &&
        !s.mataKuliah.toLowerCase().contains(kunci) &&
        !s.judul.toLowerCase().contains(kunci)) {
      return false;
    }
    if (mingguIni) {
      final n = nomorHari(s.hari);
      if (n == null || n < nomorHariIni) return false;
    }
    return filter.cocok(s);
  }).toList();
}

/// Tab Jelajah: pencarian, chip filter cepat, filter lengkap, dan daftar/grid sirkel.
class JelajahScreen extends StatefulWidget {
  const JelajahScreen({super.key});

  @override
  State<JelajahScreen> createState() => _JelajahScreenState();
}

class _JelajahScreenState extends State<JelajahScreen> {
  final _cari = TextEditingController();
  FilterSirkel _filter = const FilterSirkel();
  bool _mingguIni = false;

  @override
  void dispose() {
    _cari.dispose();
    super.dispose();
  }

  // Sumber untuk sheet Filter: sudah tersaring kata kunci & "Minggu ini",
  // sehingga angka "Tampilkan N sirkel" sama dengan hasil yang nanti tampil.
  List<Sirkel> get _sumberFilter => saringSirkel(
        DummyData.semuaSirkel,
        kataKunci: _cari.text,
        mingguIni: _mingguIni,
      );

  Future<void> _bukaFilter() async {
    final hasil = await showFilterSheet(
      context,
      awal: _filter,
      sumber: _sumberFilter,
    );
    // null = sheet ditutup tanpa menekan "Tampilkan", filter tidak berubah.
    if (hasil != null && mounted) setState(() => _filter = hasil);
  }

  // Data bisa berubah setelah kembali (gabung/buat sirkel), jadi daftar dibangun ulang.
  void _buka(String route, {Object? arguments}) {
    Navigator.of(context).pushNamed(route, arguments: arguments).then((_) {
      if (mounted) setState(() {});
    });
  }

  void _pilihSemua() => setState(() {
        _filter = const FilterSirkel();
        _mingguIni = false;
      });

  void _pilihMode(ModeBelajar mode, bool pilih) =>
      setState(() => _filter = _filter.denganMode(pilih ? mode : null));

  @override
  Widget build(BuildContext context) {
    final hasil = saringSirkel(
      DummyData.semuaSirkel,
      kataKunci: _cari.text,
      filter: _filter,
      mingguIni: _mingguIni,
    );

    // P7: jumlah kolom grid 1 (< 600), 2 (600–839), 3 (≥ 840).
    final kolom = Responsive.columns(context, compact: 1, medium: 2, expanded: 3);
    final compactCard = kolom > 1;

    // P7: tinggi sel grid dihitung dari tinggi sampul + isi kartu, dikali skala
    // teks pengguna, agar kartu tidak terpotong saat ukuran huruf diperbesar.
    final skalaTeks = MediaQuery.textScalerOf(context).scale(AppSizes.m) / AppSizes.m;
    final tinggiKartu =
        (compactCard ? AppSizes.coverCardCompact : AppSizes.coverCard) +
            AppSizes.sirkelCardBody * skalaTeks;

    return Scaffold(
      // Di layar lebar FAB sudah ada di NavigationRail (MainShell), jadi di sini hanya untuk ponsel.
      floatingActionButton: context.isCompact
          ? FloatingActionButton.extended(
              onPressed: () => _buka(AppRoutes.buatSirkel),
              icon: const Icon(Icons.add),
              label: const Text(JelajahStrings.buatSirkel),
            )
          : null,
      body: SafeArea(
        bottom: false,
        // P6: CustomScrollView agar header, chip, dan grid ikut tergulir bersama
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
            SliverToBoxAdapter(child: _buildChips()),
            const SliverToBoxAdapter(child: SizedBox(height: AppSizes.m)),
            if (hasil.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.pagePadding),
                  child: EmptyState(
                    title: JelajahStrings.kosongJudul,
                    message: JelajahStrings.kosongPesan,
                  ),
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  AppSizes.pagePadding,
                  0,
                  AppSizes.pagePadding,
                  context.isCompact ? AppSizes.fabSpace : AppSizes.pagePadding,
                ),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: kolom,
                    mainAxisSpacing: AppSizes.m,
                    crossAxisSpacing: AppSizes.m,
                    mainAxisExtent: tinggiKartu,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => SirkelCard(
                      sirkel: hasil[i],
                      compact: compactCard,
                      // Kirim id sebagai argumen route; Detail mengambil datanya sendiri.
                      onTap: () => _buka(
                        AppRoutes.detailSirkel,
                        arguments: hasil[i].id,
                      ),
                    ),
                    childCount: hasil.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final judul = Text(
      JelajahStrings.judul,
      style: Theme.of(context).textTheme.titleLarge,
    );
    final cari = SearchBar(
      controller: _cari,
      hintText: JelajahStrings.cariHint,
      leading: const Icon(Icons.search),
      trailing: [
        IconButton(
          tooltip: JelajahStrings.tooltipFilter,
          icon: const Icon(Icons.tune),
          onPressed: _bukaFilter,
        ),
      ],
      // Pencarian langsung: setiap ketikan membangun ulang daftar.
      onChanged: (_) => setState(() {}),
    );

    // P7: di layar lebar judul dan SearchBar sejajar (mockup 16_tablet).
    if (!context.isCompact) {
      return Row(
        children: [
          Expanded(child: judul),
          const SizedBox(width: AppSizes.l),
          Expanded(child: cari),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        judul,
        const SizedBox(height: AppSizes.m),
        cari,
      ],
    );
  }

  Widget _buildChips() {
    final semua = !_filter.aktif && !_mingguIni;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.pagePadding),
      child: Row(
        spacing: AppSizes.s,
        children: [
          FilterChip(
            label: const Text(JelajahStrings.chipSemua),
            selected: semua,
            onSelected: (_) => _pilihSemua(),
          ),
          FilterChip(
            avatar: const Icon(Icons.videocam),
            label: const Text(SirkelStrings.online),
            selected: _filter.mode == ModeBelajar.online,
            onSelected: (v) => _pilihMode(ModeBelajar.online, v),
          ),
          FilterChip(
            avatar: const Icon(Icons.place),
            label: const Text(SirkelStrings.offline),
            selected: _filter.mode == ModeBelajar.offline,
            onSelected: (v) => _pilihMode(ModeBelajar.offline, v),
          ),
          FilterChip(
            avatar: const Icon(Icons.calendar_today_outlined),
            label: const Text(JelajahStrings.chipMingguIni),
            selected: _mingguIni,
            onSelected: (v) => setState(() => _mingguIni = v),
          ),
        ],
      ),
    );
  }
}
