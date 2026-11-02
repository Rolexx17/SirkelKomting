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
import 'package:sirkel_mobile/features/sirkel/sirkel_waktu.dart';
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
      expect(idDari(hasil), unorderedEquals(['s1', 's7']));
    });

    test('"Minggu ini" dari hari Kamis menyisakan Kamis, Jumat, Sabtu', () {
      final hasil = saringSirkel(
        semua,
        mingguIni: true,
        hariIni: DateTime(2026, 10, 29), // Kamis
      );
      expect(idDari(hasil), unorderedEquals(['s1', 's7', 's2', 's4']));
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
      // Kamis 19.00 (s1) → Kamis 19.30 (s7) → Jumat (s4) → Sabtu (s2).
      expect(hasil.map((s) => s.id).toList(), ['s1', 's7', 's4', 's2']);
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

  group('Iterasi 4: urutan hasil Jelajah (unit test)', () {
    final kamis = DateTime(2026, 10, 29);

    test('Jadwal terdekat dari Kamis berputar ke minggu depan', () {
      final hasil = saringSirkel(
        DummyData.semuaSirkel,
        filter: const FilterSirkel(urutan: UrutanSirkel.terdekat),
        hariIni: kamis,
      );
      // Kamis 19.00 → Kamis 19.30 → Jumat → Sabtu → Senin → Selasa → Rabu.
      expect(
        hasil.map((s) => s.id).toList(),
        ['s1', 's7', 's4', 's2', 's6', 's5', 's3'],
      );
    });

    test('Kursi terbanyak: sisa kursi tidak pernah naik', () {
      final hasil = saringSirkel(
        DummyData.semuaSirkel,
        filter: const FilterSirkel(urutan: UrutanSirkel.kursiTerbanyak),
      );
      for (var i = 1; i < hasil.length; i++) {
        expect(hasil[i].sisaKursi, lessThanOrEqualTo(hasil[i - 1].sisaKursi));
      }
    });

    test('Rating mentor: rating tidak pernah naik', () {
      final hasil = saringSirkel(
        DummyData.semuaSirkel,
        filter: const FilterSirkel(urutan: UrutanSirkel.ratingMentor),
      );
      double rating(Sirkel s) => s.mentor.rating ?? 0;
      for (var i = 1; i < hasil.length; i++) {
        expect(rating(hasil[i]), lessThanOrEqualTo(rating(hasil[i - 1])));
      }
    });

    test('urutan tidak mengubah isi hasil, hanya posisinya', () {
      final biasa = saringSirkel(DummyData.semuaSirkel, kataKunci: 'data');
      final urut = saringSirkel(
        DummyData.semuaSirkel,
        kataKunci: 'data',
        filter: const FilterSirkel(urutan: UrutanSirkel.kursiTerbanyak),
      );
      expect(
        urut.map((s) => s.id),
        unorderedEquals(biasa.map((s) => s.id)),
      );
    });
  });

  group('Iterasi 4: jadwal bentrok (unit test)', () {
    Sirkel sirkel(String id) => DummyData.cariSirkel(id)!;

    test('State Management (Kamis 19.30) bentrok dengan Kalkulus I (Kamis 19.00)',
        () {
      expect(cariBentrok(sirkel('s7'), DummyData.sirkelDiikuti)?.id, 's1');
    });

    test('Statistika (Jumat 20.00) tidak bentrok dengan sirkel yang diikuti', () {
      expect(cariBentrok(sirkel('s4'), DummyData.sirkelDiikuti), isNull);
    });

    test('sesi berurutan pas (mulai 20.30, saat Kalkulus selesai) tidak bentrok',
        () {
      final berurutan = sirkel('s7').copyWith(jam: '20.30');
      expect(cariBentrok(berurutan, DummyData.sirkelDiikuti), isNull);
    });

    test('sirkel multi-hari "Senin & Kamis" 19.00 ikut terdeteksi bentrok', () {
      final multiHari = sirkel('s6').copyWith(hari: 'Senin & Kamis', jam: '19.00');
      expect(cariBentrok(multiHari, DummyData.sirkelDiikuti)?.id, 's1');
    });
  });

  group('Iterasi 4: gabung dengan jadwal bentrok (widget test)', () {
    Future<void> ketukGabung(WidgetTester tester) async {
      await pasang(tester, const DetailSirkelScreen(sirkelId: 's7'));
      await tester.tap(find.text(SirkelStrings.gabung));
      await tester.pumpAndSettle();
    }

    testWidgets('gabung s7 menampilkan peringatan; Batal tidak bergabung',
        (tester) async {
      await ketukGabung(tester);
      expect(find.text(SirkelStrings.bentrokJudul), findsOneWidget);

      await tester.tap(find.text(SirkelStrings.batal));
      await tester.pumpAndSettle();

      expect(DummyData.sudahGabung('s7'), isFalse);
      expect(find.text(SirkelStrings.gabung), findsOneWidget);
    });

    testWidgets('"Tetap gabung" bergabung dan membuka dialog berhasil',
        (tester) async {
      await ketukGabung(tester);

      await tester.tap(find.text(SirkelStrings.tetapGabung));
      await tester.pumpAndSettle();

      expect(DummyData.sudahGabung('s7'), isTrue);
      expect(find.text(SirkelStrings.gabungJudul), findsOneWidget);
    });

    testWidgets('gabung sirkel tanpa bentrok langsung membuka dialog berhasil',
        (tester) async {
      await pasang(tester, const DetailSirkelScreen(sirkelId: 's4'));
      await tester.tap(find.text(SirkelStrings.gabung));
      await tester.pumpAndSettle();

      expect(find.text(SirkelStrings.bentrokJudul), findsNothing);
      expect(find.text(SirkelStrings.gabungJudul), findsOneWidget);
    });
  });

  group('Iterasi 4: riwayat pencarian', () {
    test('kata dirapikan, kata kosong diabaikan', () {
      expect(perbaruiRiwayat([], '  Kalkulus '), ['Kalkulus']);
      expect(perbaruiRiwayat(['data'], '   '), ['data']);
    });

    test('kata yang sama tidak dobel dan naik ke paling atas', () {
      expect(perbaruiRiwayat(['data', 'Kalkulus'], 'kalkulus'), ['kalkulus', 'data']);
    });

    test('hanya 5 kata terbaru yang disimpan', () {
      var riwayat = <String>[];
      for (final kata in ['a', 'b', 'c', 'd', 'e', 'f']) {
        riwayat = perbaruiRiwayat(riwayat, kata);
      }
      expect(riwayat, ['f', 'e', 'd', 'c', 'b']);
    });

    testWidgets('Enter mencatat riwayat; chip riwayat memakai kata itu lagi',
        (tester) async {
      await pasang(tester, const JelajahScreen());

      await tester.enterText(find.byType(SearchBar), 'kalkulus');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(DummyData.riwayatPencarian, ['kalkulus']);

      // Kolom dikosongkan → chip riwayat muncul.
      await tester.enterText(find.byType(SearchBar), '');
      await tester.pump();
      expect(find.widgetWithText(InputChip, 'kalkulus'), findsOneWidget);

      await tester.tap(find.widgetWithText(InputChip, 'kalkulus'));
      await tester.pump();
      expect(find.byType(SirkelCard), findsOneWidget);
    });
  });
}
