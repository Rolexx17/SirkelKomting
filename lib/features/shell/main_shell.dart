import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/utils/responsive.dart';
import '../../routes/app_routes.dart';
import '../../shared/widgets/app_logo.dart';
import '../beranda/beranda_screen.dart';
import '../jelajah/jelajah_screen.dart';
import '../materi/ruang_materi_screen.dart';
import '../profil/profil_screen.dart';
import 'shell_strings.dart';

/// Kerangka utama setelah masuk: empat tab (Beranda, Jelajah, Materi, Profil)
/// dengan NavigationBar di ponsel atau NavigationRail di layar lebar.
class MainShell extends StatefulWidget {
  const MainShell({super.key, this.initialIndex = tabBeranda});

  /// Tab yang aktif saat MainShell pertama kali dibuka.
  final int initialIndex;

  static const tabBeranda = 0, tabJelajah = 1, tabMateri = 2, tabProfil = 3;

  /// State MainShell terdekat, agar layar anak bisa memindahkan tab, misalnya
  /// `MainShell.maybeOf(context)?.pindahTab(MainShell.tabJelajah)`.
  static MainShellState? maybeOf(BuildContext context) =>
      context.findAncestorStateOfType<MainShellState>();

  @override
  State<MainShell> createState() => MainShellState();
}

/// State MainShell. Dibuat publik supaya [pindahTab] bisa dipanggil layar anak.
class MainShellState extends State<MainShell> {
  late int _index = widget.initialIndex;

  // GlobalKey membuat IndexedStack (beserta state setiap tab) dipindahkan, bukan
  // dibuat ulang, saat layout berganti antara NavigationBar dan NavigationRail.
  final _kunciIsi = GlobalKey();

  // Dinaikkan setelah kembali dari Buat Sirkel lewat FAB di rail. Key Jelajah
  // ikut berubah sehingga Jelajah dibuat ulang dan sirkel baru langsung tampil.
  int _versiJelajah = 0;

  static const _ikon = [Icons.home, Icons.search, Icons.menu_book, Icons.person];
  static const _label = [
    ShellStrings.beranda,
    ShellStrings.jelajah,
    ShellStrings.materi,
    ShellStrings.profil,
  ];

  static const _ukuranLogo = 40.0;

  /// Tinggi minimum rail (logo + FAB + 4 tujuan berlabel). Bila layar lebih
  /// pendek (misalnya landscape 800×360), rail digulir sehingga tidak overflow.
  static const _tinggiMinimumRail = 440.0;

  int get indexAktif => _index;

  void pindahTab(int index) {
    if (index == _index) return;
    setState(() => _index = index);
  }

  Future<void> _bukaBuatSirkel() async {
    await Navigator.of(context).pushNamed(AppRoutes.buatSirkel);
    if (mounted) setState(() => _versiJelajah++);
  }

  @override
  Widget build(BuildContext context) {
    // P6: IndexedStack membangun keempat tab sekali dan hanya menampilkan satu,
    // sehingga posisi scroll dan isian setiap tab tetap terjaga saat berpindah.
    final isi = IndexedStack(
      key: _kunciIsi,
      index: _index,
      children: [
        const BerandaScreen(),
        KeyedSubtree(
          key: ValueKey(_versiJelajah),
          child: const JelajahScreen(),
        ),
        const RuangMateriScreen(),
        const ProfilScreen(),
      ],
    );

    // P7: lebar layar dibaca lewat Responsive (MediaQuery.sizeOf).
    // < 600 → NavigationBar di bawah; ≥ 600 → NavigationRail di kiri.
    final ukuran = context.windowSize;
    if (ukuran == WindowSize.compact) {
      return Scaffold(
        body: isi,
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: pindahTab,
          destinations: [
            for (var i = 0; i < _ikon.length; i++)
              NavigationDestination(icon: Icon(_ikon[i]), label: _label[i]),
          ],
        ),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          _rail(tampilLabel: ukuran == WindowSize.expanded),
          const VerticalDivider(width: 1),
          Expanded(child: isi),
        ],
      ),
    );
  }

  Widget _rail({required bool tampilLabel}) {
    return SafeArea(
      right: false,
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          child: SizedBox(
            height: math.max(constraints.maxHeight, _tinggiMinimumRail),
            child: NavigationRail(
              selectedIndex: _index,
              onDestinationSelected: pindahTab,
              // P7: ≥ 840 label selalu tampil; 600–839 cukup ikon agar hemat ruang.
              labelType: tampilLabel
                  ? NavigationRailLabelType.all
                  : NavigationRailLabelType.none,
              leading: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AppLogo(size: _ukuranLogo),
                  // FAB "Buat sirkel" hanya relevan di tab Jelajah (mockup 16_tablet).
                  if (_index == MainShell.tabJelajah) ...[
                    const SizedBox(height: AppSizes.m),
                    FloatingActionButton(
                      elevation: 0,
                      tooltip: ShellStrings.buatSirkel,
                      onPressed: _bukaBuatSirkel,
                      child: const Icon(Icons.add),
                    ),
                  ],
                  const SizedBox(height: AppSizes.s),
                ],
              ),
              destinations: [
                for (var i = 0; i < _ikon.length; i++)
                  NavigationRailDestination(
                    icon: Icon(_ikon[i]),
                    label: Text(_label[i]),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
