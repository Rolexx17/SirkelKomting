import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sirkel_mobile/core/theme/app_theme.dart';
import 'package:sirkel_mobile/core/utils/responsive.dart';
import 'package:sirkel_mobile/data/dummy/dummy_data.dart';
import 'package:sirkel_mobile/data/models/sirkel.dart';
import 'package:sirkel_mobile/features/buat_sirkel/buat_sirkel_screen.dart';
import 'package:sirkel_mobile/features/buat_sirkel/buat_sirkel_strings.dart';

void main() {
  // Data DummyData statis; dikembalikan ke kondisi awal sebelum setiap test.
  setUp(DummyData.resetUntukTes);

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

  group('Data iterasi 2 (unit test)', () {
    Sirkel denganHari(String hari) =>
        DummyData.cariSirkel('s1')!.copyWith(hari: hari);

    test('daftarNomorHari: "Senin & Rabu" → [1, 3]', () {
      expect(denganHari('Senin & Rabu').daftarNomorHari, [1, 3]);
    });

    test('daftarNomorHari: satu hari dan tiga hari', () {
      expect(denganHari('Kamis').daftarNomorHari, [4]);
      expect(denganHari('Senin, Rabu & Jumat').daftarNomorHari, [1, 3, 5]);
    });

    test('setelah tambahSirkel, jadwalSesi memuat sesi sirkel baru', () {
      final id = DummyData.tambahSirkel(
        mataKuliah: 'Kalkulus I',
        judul: 'Latihan Integral',
        mode: ModeBelajar.online,
        hari: 'Senin & Rabu',
        jam: '16.00',
        kuota: 6,
        cover: DummyData.cariSirkel('s1')!.cover,
      );

      expect(DummyData.jadwalSesi.any((s) => s.sirkelId == id), isTrue);
      expect(DummyData.adalahMentorSirkel(id), isTrue);
    });

    test('setelah gabung("s4"), jadwalSesi memuat sesi s4', () {
      expect(DummyData.jadwalSesi.any((s) => s.sirkelId == 's4'), isFalse);

      DummyData.gabung('s4');

      expect(DummyData.jadwalSesi.any((s) => s.sirkelId == 's4'), isTrue);
    });

    test('semua sesi berada di antara sekarang dan 14 hari ke depan', () {
      final sebelum = DateTime.now();
      final jadwal = DummyData.jadwalSesi;
      final sesudah = DateTime.now();

      expect(jadwal, isNotEmpty);
      for (final s in jadwal) {
        expect(s.waktu.isBefore(sebelum), isFalse);
        expect(
          s.waktu.isAfter(sesudah.add(const Duration(days: 14))),
          isFalse,
        );
      }
    });

    test('sesi hari ini yang jamnya sudah lewat tidak dihitung', () {
      // Kamis 5 Nov 2026 pukul 20.00; sesi s1 (Kamis 19.00) hari itu sudah lewat.
      final jadwal = DummyData.jadwalSesiSejak(DateTime(2026, 11, 5, 20));
      final s1 = jadwal.where((s) => s.sirkelId == 's1').toList();

      expect(s1.first.waktu, DateTime(2026, 11, 12, 19));
      // Terurut dari yang paling awal.
      for (var i = 1; i < jadwal.length; i++) {
        expect(jadwal[i].waktu.isBefore(jadwal[i - 1].waktu), isFalse);
      }
    });

    test('tandaiSemuaNotifikasiDibaca membuat adaNotifikasiBaru false', () {
      expect(DummyData.adaNotifikasiBaru, isTrue);

      DummyData.tandaiSemuaNotifikasiDibaca();

      expect(DummyData.adaNotifikasiBaru, isFalse);
    });

    test('toggleSimpanMateri dua kali mengembalikan status awal', () {
      final awal = DummyData.materiDisimpan('m1');

      DummyData.toggleSimpanMateri('m1');
      expect(DummyData.materiDisimpan('m1'), !awal);

      DummyData.toggleSimpanMateri('m1');
      expect(DummyData.materiDisimpan('m1'), awal);
    });

    test('ubahProfil mengganti nama di pengguna aktif dan anggota sirkel', () {
      DummyData.ubahProfil(nama: 'Budi Santoso', prodi: 'Manajemen', mentor: true);

      expect(DummyData.penggunaAktif.nama, 'Budi Santoso');
      expect(DummyData.penggunaAktif.isMentor, isTrue);
      final anggotaS1 = DummyData.cariSirkel('s1')!.anggota;
      expect(anggotaS1.any((a) => a.nama == 'Budi Santoso'), isTrue);
      expect(anggotaS1.any((a) => a.nama == 'Nadia Putri'), isFalse);
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

    testWidgets('mengetuk kolom Jam membuka time picker', (tester) async {
      await pasangLayar(tester);
      final kolomJam = find.text(BuatSirkelStrings.jam);
      await tester.ensureVisible(kolomJam);

      // Ketukan diterima GestureDetector di luar AbsorbPointer, bukan oleh teksnya.
      await tester.tap(kolomJam, warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.byType(TimePickerDialog), findsOneWidget);
    });
  });
}
