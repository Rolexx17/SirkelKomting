import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sirkel_mobile/core/theme/app_theme.dart';
import 'package:sirkel_mobile/data/dummy/dummy_data.dart';
import 'package:sirkel_mobile/data/models/sirkel.dart';
import 'package:sirkel_mobile/features/jelajah/filter_sheet.dart';
import 'package:sirkel_mobile/features/jelajah/jelajah_screen.dart';
import 'package:sirkel_mobile/features/jelajah/jelajah_strings.dart';
import 'package:sirkel_mobile/shared/widgets/sirkel_card.dart';

void main() {
  group('saringSirkel (unit test)', () {
    final semua = DummyData.semuaSirkel;
    List<String> idDari(List<Sirkel> daftar) => daftar.map((s) => s.id).toList();

    test('tanpa kata kunci dan filter mengembalikan semua sirkel', () {
      expect(saringSirkel(semua).length, semua.length);
    });

    test('pencarian mata kuliah tidak peka huruf besar/kecil', () {
      expect(idDari(saringSirkel(semua, kataKunci: 'KALKULUS')), ['s1']);
    });

    test('pencarian juga mencocokkan judul', () {
      expect(idDari(saringSirkel(semua, kataKunci: 'turunan')), ['s1']);
    });

    test('filter mode Online hanya menyisakan sirkel online', () {
      final hasil = saringSirkel(
        semua,
        filter: const FilterSirkel(mode: ModeBelajar.online),
      );
      expect(hasil, isNotEmpty);
      expect(hasil.every((s) => s.mode == ModeBelajar.online), isTrue);
    });

    test('kata kunci dan mode Offline bisa dikombinasikan', () {
      final hasil = saringSirkel(
        semua,
        kataKunci: 'data',
        filter: const FilterSirkel(mode: ModeBelajar.offline),
      );
      expect(idDari(hasil), unorderedEquals(['s2', 's3']));
    });

    test('filter hari Kamis', () {
      final hasil = saringSirkel(semua, filter: const FilterSirkel(hari: {'Kam'}));
      expect(idDari(hasil), ['s1']);
    });

    test('"Minggu ini" dari hari Kamis menyisakan Kamis, Jumat, Sabtu', () {
      final hasil = saringSirkel(
        semua,
        mingguIni: true,
        hariIni: DateTime(2026, 10, 29), // Kamis
      );
      expect(idDari(hasil), unorderedEquals(['s1', 's2', 's4']));
    });

    test('"Hanya yang masih ada kursi" membuang sirkel penuh', () {
      final hasil = saringSirkel(
        semua,
        filter: const FilterSirkel(hanyaAdaKursi: true),
      );
      expect(hasil.every((s) => !s.penuh), isTrue);
    });
  });

  group('JelajahScreen (widget test)', () {
    Future<void> pasangLayar(WidgetTester tester) async {
      // Ukuran ponsel 360×800 (logical pixel).
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.light(), home: const JelajahScreen()),
      );
    }

    testWidgets('mengetik "kalkulus" hanya menyisakan satu SirkelCard',
        (tester) async {
      await pasangLayar(tester);
      expect(find.byType(SirkelCard), findsWidgets);

      await tester.enterText(find.byType(SearchBar), 'kalkulus');
      await tester.pump();

      expect(find.byType(SirkelCard), findsOneWidget);
      expect(find.text('Limit & Turunan'), findsOneWidget);
    });

    testWidgets('kata kunci tanpa hasil menampilkan EmptyState', (tester) async {
      await pasangLayar(tester);

      await tester.enterText(find.byType(SearchBar), 'zzz');
      await tester.pump();

      expect(find.byType(SirkelCard), findsNothing);
      expect(find.text(JelajahStrings.kosongJudul), findsOneWidget);
    });
  });
}
