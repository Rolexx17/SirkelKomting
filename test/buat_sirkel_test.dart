import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sirkel_mobile/core/theme/app_theme.dart';
import 'package:sirkel_mobile/core/utils/responsive.dart';
import 'package:sirkel_mobile/data/dummy/dummy_data.dart';
import 'package:sirkel_mobile/features/buat_sirkel/buat_sirkel_screen.dart';
import 'package:sirkel_mobile/features/buat_sirkel/buat_sirkel_strings.dart';

void main() {
  group('Responsive.fromWidth (unit test)', () {
    test('599 → compact', () {
      expect(Responsive.fromWidth(599), WindowSize.compact);
    });

    test('600 → medium', () {
      expect(Responsive.fromWidth(600), WindowSize.medium);
    });

    test('839 → medium', () {
      expect(Responsive.fromWidth(839), WindowSize.medium);
    });

    test('840 → expanded', () {
      expect(Responsive.fromWidth(840), WindowSize.expanded);
    });
  });

  group('BuatSirkelScreen (widget test)', () {
    Future<void> pasangLayar(WidgetTester tester) async {
      // Ukuran ponsel 360×800 (logical pixel).
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.light(), home: const BuatSirkelScreen()),
      );
    }

    Finder tombolTerbitkan() =>
        find.widgetWithText(FilledButton, BuatSirkelStrings.terbitkan);

    Future<void> tekanTerbitkan(WidgetTester tester) async {
      await tester.ensureVisible(tombolTerbitkan());
      await tester.tap(tombolTerbitkan());
      await tester.pump();
    }

    testWidgets('judul kosong menampilkan pesan validasi dan sirkel tidak bertambah',
        (tester) async {
      await pasangLayar(tester);
      final jumlahAwal = DummyData.semuaSirkel.length;

      await tekanTerbitkan(tester);

      expect(find.text(BuatSirkelStrings.judulWajib), findsOneWidget);
      expect(find.text(BuatSirkelStrings.hariWajib), findsOneWidget);
      expect(DummyData.semuaSirkel.length, jumlahAwal);
    });

    testWidgets('setelah judul diisi, pesan validasi judul hilang',
        (tester) async {
      await pasangLayar(tester);

      await tester.enterText(
        find.widgetWithText(TextFormField, BuatSirkelStrings.judulSirkel),
        'Belajar Kalkulus',
      );
      await tekanTerbitkan(tester);

      expect(find.text(BuatSirkelStrings.judulWajib), findsNothing);
      // Hari masih kosong, jadi validasi hari tetap muncul.
      expect(find.text(BuatSirkelStrings.hariWajib), findsOneWidget);
    });

    testWidgets('stepper kuota tidak bisa turun di bawah 2', (tester) async {
      await pasangLayar(tester);
      final kurangi = find.byTooltip(BuatSirkelStrings.kurangiKuota);
      await tester.ensureVisible(kurangi);

      // Kuota awal 6; ditekan 6 kali tetap berhenti di 2.
      for (var i = 0; i < 6; i++) {
        await tester.tap(kurangi, warnIfMissed: false);
        await tester.pump();
      }

      expect(find.text('2'), findsOneWidget);
    });
  });
}
