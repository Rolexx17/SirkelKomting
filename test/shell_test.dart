import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sirkel_mobile/core/theme/app_theme.dart';
import 'package:sirkel_mobile/data/dummy/dummy_data.dart';
import 'package:sirkel_mobile/features/beranda/beranda_strings.dart';
import 'package:sirkel_mobile/features/notifikasi/notifikasi_screen.dart';
import 'package:sirkel_mobile/features/notifikasi/notifikasi_strings.dart';
import 'package:sirkel_mobile/features/shell/main_shell.dart';
import 'package:sirkel_mobile/features/shell/shell_strings.dart';
import 'package:sirkel_mobile/features/sirkel_saya/sirkel_saya_screen.dart';
import 'package:sirkel_mobile/features/sirkel_saya/sirkel_saya_strings.dart';
import 'package:sirkel_mobile/routes/app_routes.dart';

/// Judul tab Jelajah (Bagian 10 brief); tampil hanya bila tab Jelajah aktif.
const _judulJelajah = 'Jelajah sirkel';

void main() {
  // Data disimpan statis; dikembalikan ke kondisi awal agar test tidak saling memengaruhi.
  setUp(DummyData.resetUntukTes);

  /// Mengatur ukuran layar logis (lebar × tinggi dalam dp) untuk satu test.
  void aturUkuran(WidgetTester tester, Size ukuran) {
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = ukuran * 3.0;
    addTearDown(tester.view.reset);
  }

  /// Memasang MainShell. Route Notifikasi didaftarkan agar lonceng bisa dibuka.
  Future<void> pasangShell(WidgetTester tester, Size ukuran) async {
    aturUkuran(tester, ukuran);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const MainShell(),
        routes: {AppRoutes.notifikasi: (_) => const NotifikasiScreen()},
      ),
    );
    await tester.pumpAndSettle();
  }

  bool badgeTampil(WidgetTester tester) =>
      tester.widget<Badge>(find.byType(Badge)).isLabelVisible;

  group('MainShell', () {
    testWidgets('menekan tab Jelajah menampilkan teks "Jelajah sirkel"',
        (tester) async {
      await pasangShell(tester, const Size(360, 800));

      // Jelajah sudah dibangun di IndexedStack, tetapi belum tampil (offstage).
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.text(_judulJelajah), findsNothing);

      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text(ShellStrings.jelajah),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(_judulJelajah), findsOneWidget);
    });

    testWidgets('di ukuran 1000×800 yang tampil adalah NavigationRail',
        (tester) async {
      await pasangShell(tester, const Size(1000, 800));

      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
    });

    testWidgets('"Lihat semua" di Beranda memindahkan tab ke Jelajah',
        (tester) async {
      await pasangShell(tester, const Size(360, 800));

      final lihatSemua = find.text(BerandaStrings.lihatSemua);
      await tester.ensureVisible(lihatSemua);
      await tester.pumpAndSettle();
      await tester.tap(lihatSemua);
      await tester.pumpAndSettle();

      expect(find.text(_judulJelajah), findsOneWidget);
    });
  });

  group('Iterasi 2', () {
    testWidgets('setelah "Tandai dibaca" lalu kembali, titik Badge di Beranda hilang',
        (tester) async {
      await pasangShell(tester, const Size(360, 800));
      expect(badgeTampil(tester), isTrue);

      await tester.tap(find.byIcon(Icons.notifications_outlined));
      await tester.pumpAndSettle();
      await tester.tap(find.text(NotifikasiStrings.tandaiDibaca));
      await tester.pumpAndSettle();
      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(DummyData.adaNotifikasiBaru, isFalse);
      expect(badgeTampil(tester), isFalse);
    });

    testWidgets('mengetuk "Kalkulus I" di carousel membuka Jelajah dengan kata kunci itu',
        (tester) async {
      await pasangShell(tester, const Size(360, 800));
      const mataKuliah = 'Kalkulus I';

      final item = find.descendant(
        of: find.byType(CarouselView),
        matching: find.text(mataKuliah),
      );
      await tester.ensureVisible(item);
      await tester.pumpAndSettle();
      // Ketukan diterima lapisan InkWell milik CarouselView yang menutupi item,
      // jadi peringatan "tidak mengenai Text" dimatikan.
      await tester.tap(item, warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.text(_judulJelajah), findsOneWidget);
      final searchBar = tester.widget<SearchBar>(find.byType(SearchBar));
      expect(searchBar.controller?.text, mataKuliah);
    });

    testWidgets('di Sirkel Saya, mengetuk tanggal tanpa sesi menampilkan pesan kosong',
        (tester) async {
      aturUkuran(tester, const Size(360, 800));
      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.light(), home: const SirkelSayaScreen()),
      );
      await tester.pumpAndSettle();

      // Data awal: sirkel yang diikuti bertemu Rabu, Kamis, dan Sabtu, jadi
      // hari Jumat pada minggu mana pun tidak punya sesi.
      await tester.tap(find.text(SirkelSayaStrings.namaHariSingkat[4]));
      await tester.pumpAndSettle();

      expect(find.text(SirkelSayaStrings.tidakAdaSesiJudul), findsOneWidget);
      expect(find.text(SirkelSayaStrings.tampilkanSemua), findsOneWidget);
    });
  });
}
