import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sirkel_mobile/core/constants/app_assets.dart';
import 'package:sirkel_mobile/core/theme/app_theme.dart';
import 'package:sirkel_mobile/data/dummy/dummy_data.dart';
import 'package:sirkel_mobile/data/models/sirkel.dart';
import 'package:sirkel_mobile/features/jelajah/filter_sheet.dart';
import 'package:sirkel_mobile/features/jelajah/jelajah_screen.dart';
import 'package:sirkel_mobile/features/jelajah/jelajah_strings.dart';
import 'package:sirkel_mobile/features/sirkel/detail_sirkel_screen.dart';
import 'package:sirkel_mobile/features/sirkel/gabung_dialog.dart';
import 'package:sirkel_mobile/features/sirkel/sirkel_strings.dart';
import 'package:sirkel_mobile/shared/widgets/cover_image.dart';
import 'package:sirkel_mobile/shared/widgets/sirkel_card.dart';

/// Ukuran layar uji (logical pixel).
const hpPortrait = Size(360, 800);
const hpLandscape = Size(932, 430);
const desktop = Size(1280, 800);

/// Memasang [layar] dengan tema aplikasi pada [ukuran] (bawaan: HP portrait 360×800).
Future<void> pasang(
  WidgetTester tester,
  Widget layar, {
  Size ukuran = hpPortrait,
}) async {
  tester.view.physicalSize = ukuran;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(theme: AppTheme.light(), home: layar));
}

/// Membuka dialog Gabung (sirkel s4) dari tombol sementara pada [ukuran].
Future<void> bukaDialogGabung(WidgetTester tester, Size ukuran) async {
  await pasang(
    tester,
    Builder(
      builder: (context) => Scaffold(
        body: Center(
          child: TextButton(
            onPressed: () =>
                showGabungDialog(context, DummyData.cariSirkel('s4')!),
            child: const Text('buka'),
          ),
        ),
      ),
    ),
    ukuran: ukuran,
  );
  await tester.tap(find.text('buka'));
  await tester.pumpAndSettle();
}

/// Ilustrasi di dalam dialog Gabung (satu-satunya Image di Dialog).
Finder get ilustrasiDialog => find.descendant(
      of: find.byType(Dialog),
      matching: find.byType(Image),
    );

/// Membuat sirkel multi-hari lewat fungsi Buat Sirkel milik DummyData; Nadia jadi mentornya.
String buatSirkelSeninRabu() => DummyData.tambahSirkel(
      mataKuliah: 'Kalkulus I',
      judul: 'Latihan Integral',
      mode: ModeBelajar.online,
      hari: 'Senin & Rabu',
      jam: '16.00',
      kuota: 6,
      cover: AppAssets.coverKalkulus,
    );

void main() {
  // Data DummyData statis; dikembalikan ke kondisi awal sebelum setiap test.
  setUp(DummyData.resetUntukTes);

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
    Future<void> pasangLayar(WidgetTester tester) =>
        pasang(tester, const JelajahScreen());

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

    testWidgets('kataKunciAwal "Kalkulus" langsung menampilkan satu SirkelCard',
        (tester) async {
      await pasang(tester, const JelajahScreen(kataKunciAwal: 'Kalkulus'));

      expect(find.byType(SirkelCard), findsOneWidget);
    });

    testWidgets('"Minggu ini" di hari Minggu menampilkan pesan khusus',
        (tester) async {
      await pasang(tester, JelajahScreen(hariIni: DateTime(2026, 11, 1)));

      // Chip ada di baris yang bisa digeser; pastikan terlihat sebelum diketuk.
      final chip = find.text(JelajahStrings.chipMingguIni);
      await tester.ensureVisible(chip);
      await tester.pump();
      await tester.tap(chip);
      await tester.pump();

      expect(find.byType(SirkelCard), findsNothing);
      expect(find.text(JelajahStrings.kosongMingguIniJudul), findsOneWidget);
      expect(find.text(JelajahStrings.kosongJudul), findsNothing);
    });
  });

  group('Iterasi 2: hari majemuk & Minggu ini (unit test)', () {
    test('sirkel "Senin & Rabu" lolos filter hari Rab', () {
      final id = buatSirkelSeninRabu();
      final hasil = saringSirkel(
        DummyData.semuaSirkel,
        filter: const FilterSirkel(hari: {'Rab'}),
      );
      expect(hasil.map((s) => s.id), contains(id));
    });

    test('sirkel "Senin & Rabu" ikut "Minggu ini" pada hari Selasa', () {
      final id = buatSirkelSeninRabu();
      final hasil = saringSirkel(
        DummyData.semuaSirkel,
        mingguIni: true,
        hariIni: DateTime(2026, 10, 27), // Selasa
      );
      expect(hasil.map((s) => s.id), contains(id));
    });

    test('"Minggu ini" pada hari Minggu menghasilkan list kosong', () {
      final hasil = saringSirkel(
        DummyData.semuaSirkel,
        mingguIni: true,
        hariIni: DateTime(2026, 11, 1), // Minggu
      );
      expect(hasil, isEmpty);
    });

    test('"Minggu ini" diurutkan dari sesi terdekat', () {
      final hasil = saringSirkel(
        DummyData.semuaSirkel,
        mingguIni: true,
        hariIni: DateTime(2026, 10, 29), // Kamis
      );
      // Kamis (s1) → Jumat (s4) → Sabtu (s2).
      expect(hasil.map((s) => s.id).toList(), ['s1', 's4', 's2']);
    });
  });

  group('DetailSirkelScreen (widget test)', () {
    testWidgets('mengetuk "Lihat" menampilkan Raka Pratama di bottom sheet',
        (tester) async {
      await pasang(tester, const DetailSirkelScreen(sirkelId: 's1'));

      final lihat = find.text(SirkelStrings.lihat);
      await tester.ensureVisible(lihat);
      await tester.pumpAndSettle();
      await tester.tap(lihat);
      await tester.pumpAndSettle();

      final diSheet = find.descendant(
        of: find.byType(BottomSheet),
        matching: find.text('Raka Pratama'),
      );
      expect(diSheet, findsOneWidget);
    });

    testWidgets('mengetuk bookmark mengubah ikon menjadi Icons.bookmark',
        (tester) async {
      await pasang(tester, const DetailSirkelScreen(sirkelId: 's1'));
      expect(find.byIcon(Icons.bookmark), findsNothing);

      await tester.tap(find.byIcon(Icons.bookmark_border));
      await tester.pump();

      expect(find.byIcon(Icons.bookmark), findsOneWidget);
      expect(DummyData.sirkelDisimpan('s1'), isTrue);
    });

    testWidgets('sirkel buatan sendiri menampilkan "Kamu mentor sirkel ini"',
        (tester) async {
      final id = buatSirkelSeninRabu();
      await pasang(tester, DetailSirkelScreen(sirkelId: id));

      expect(find.text(SirkelStrings.kamuMentor), findsOneWidget);
      expect(find.text(SirkelStrings.gabung), findsNothing);
      expect(find.text(SirkelStrings.sudahGabung), findsNothing);
    });
  });

  group('Iterasi 3: orientasi Detail & dialog Gabung (widget test)', () {
    testWidgets('header Detail 220 px di desktop 1280×800', (tester) async {
      await pasang(
        tester,
        const DetailSirkelScreen(sirkelId: 's1'),
        ukuran: desktop,
      );
      expect(tester.getSize(find.byType(CoverImage)).height, 220);
    });

    testWidgets('header Detail 140 px di HP landscape 932×430', (tester) async {
      await pasang(
        tester,
        const DetailSirkelScreen(sirkelId: 's1'),
        ukuran: hpLandscape,
      );
      expect(tester.getSize(find.byType(CoverImage)).height, 140);
    });

    testWidgets('dialog Gabung menampilkan ilustrasi di desktop 1280×800',
        (tester) async {
      await bukaDialogGabung(tester, desktop);
      expect(ilustrasiDialog, findsOneWidget);
    });

    testWidgets('dialog Gabung menyembunyikan ilustrasi di HP landscape',
        (tester) async {
      await bukaDialogGabung(tester, hpLandscape);
      expect(ilustrasiDialog, findsNothing);
      expect(find.text(SirkelStrings.gabungJudul), findsOneWidget);
    });
  });

  group('Iterasi 3: keluar sirkel & penanda simpan (widget test)', () {
    testWidgets('keluar sirkel s1: konfirmasi → tombol "Gabung sirkel" kembali',
        (tester) async {
      await pasang(tester, const DetailSirkelScreen(sirkelId: 's1'));
      expect(find.text(SirkelStrings.kamuAnggota), findsOneWidget);

      await tester.tap(find.text(SirkelStrings.keluarSirkel));
      await tester.pumpAndSettle();
      expect(find.text(SirkelStrings.keluarJudul('Limit & Turunan')),
          findsOneWidget);

      await tester.tap(find.text(SirkelStrings.keluar));
      await tester.pumpAndSettle();

      expect(find.text(SirkelStrings.gabung), findsOneWidget);
      expect(find.text(SirkelStrings.keluarBerhasil), findsOneWidget);
      expect(DummyData.sirkelDiikuti.map((s) => s.id), isNot(contains('s1')));
      expect(DummyData.jadwalSesi.any((sesi) => sesi.sirkelId == 's1'), isFalse);
    });

    testWidgets('"Batal" di dialog keluar tidak mengubah apa pun',
        (tester) async {
      await pasang(tester, const DetailSirkelScreen(sirkelId: 's1'));
      final anggotaAwal = DummyData.cariSirkel('s1')!.anggota.length;

      await tester.tap(find.text(SirkelStrings.keluarSirkel));
      await tester.pumpAndSettle();
      await tester.tap(find.text(SirkelStrings.batal));
      await tester.pumpAndSettle();

      expect(find.text(SirkelStrings.keluarSirkel), findsOneWidget);
      expect(DummyData.sudahGabung('s1'), isTrue);
      expect(DummyData.cariSirkel('s1')!.anggota.length, anggotaAwal);
    });

    testWidgets('sirkel buatan sendiri tidak menampilkan "Keluar sirkel"',
        (tester) async {
      final id = buatSirkelSeninRabu();
      await pasang(tester, DetailSirkelScreen(sirkelId: id));

      expect(find.text(SirkelStrings.keluarSirkel), findsNothing);
      expect(find.text(SirkelStrings.lihatJadwal), findsOneWidget);
    });

    testWidgets('SirkelCard menampilkan Icons.bookmark setelah disimpan',
        (tester) async {
      Widget kartu() => Scaffold(
            body: SirkelCard(sirkel: DummyData.cariSirkel('s1')!),
          );

      await pasang(tester, kartu());
      expect(find.byIcon(Icons.bookmark), findsNothing);

      DummyData.toggleSimpanSirkel('s1');
      await pasang(tester, kartu());
      expect(find.byIcon(Icons.bookmark), findsOneWidget);
    });
  });
}
