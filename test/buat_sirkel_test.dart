import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sirkel_mobile/core/theme/app_theme.dart';
import 'package:sirkel_mobile/core/utils/responsive.dart';
import 'package:sirkel_mobile/data/dummy/dummy_data.dart';
import 'package:sirkel_mobile/data/models/app_user.dart';
import 'package:sirkel_mobile/data/models/notifikasi.dart';
import 'package:sirkel_mobile/data/models/sesi.dart';
import 'package:sirkel_mobile/data/models/sirkel.dart';
import 'package:sirkel_mobile/features/buat_sirkel/buat_sirkel_screen.dart';
import 'package:sirkel_mobile/features/buat_sirkel/buat_sirkel_strings.dart';
import 'package:sirkel_mobile/features/buat_sirkel/buka_buat_sirkel.dart';
import 'package:sirkel_mobile/features/materi/materi_strings.dart';
import 'package:sirkel_mobile/features/materi/pembaca_materi_screen.dart';
import 'package:sirkel_mobile/routes/app_routes.dart';

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

    test('semua sesi belum selesai dan tidak lebih dari 14 hari ke depan', () {
      final sebelum = DateTime.now();
      final jadwal = DummyData.jadwalSesi;
      final sesudah = DateTime.now();

      expect(jadwal, isNotEmpty);
      for (final s in jadwal) {
        // Sesi yang sedang berlangsung boleh ada, asalkan belum selesai.
        expect(s.waktu.add(Sesi.durasi).isAfter(sebelum), isTrue);
        expect(
          s.waktu.isAfter(sesudah.add(const Duration(days: 14))),
          isFalse,
        );
      }
    });

    test('pukul 19.30, sesi s1 19.00 hari itu (sedang berlangsung) masih ada', () {
      // Kamis 5 Nov 2026 pukul 19.30; sesi s1 Kamis 19.00 baru selesai 20.30.
      final jadwal = DummyData.jadwalSesiSejak(DateTime(2026, 11, 5, 19, 30));
      final s1 = jadwal.where((s) => s.sirkelId == 's1').toList();

      expect(s1.first.waktu, DateTime(2026, 11, 5, 19));
      expect(jadwal.first.waktu, DateTime(2026, 11, 5, 19));
    });

    test('pukul 20.31, sesi s1 hari itu sudah selesai dan tidak dihitung', () {
      // Kamis 5 Nov 2026 pukul 20.31: sesi 19.00–20.30 sudah selesai.
      final jadwal = DummyData.jadwalSesiSejak(DateTime(2026, 11, 5, 20, 31));
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

  group('Data iterasi 3 (unit test)', () {
    // Kamis 5 Nov 2026 pukul 20.31: sesi Kalkulus I (Kamis 19.00–20.30) hari itu sudah selesai.
    final kamisMalam = DateTime(2026, 11, 5, 20, 31);

    String buatSirkelBaru() => DummyData.tambahSirkel(
          mataKuliah: 'Kalkulus I',
          judul: 'Latihan Integral',
          mode: ModeBelajar.online,
          hari: 'Senin & Rabu',
          jam: '16.00',
          kuota: 6,
          cover: DummyData.cariSirkel('s1')!.cover,
        );

    test('pengingat sesi merujuk sirkel dari sesi pertama jadwal', () {
      final sesiPertama = DummyData.jadwalSesiSejak(kamisMalam).first;
      final pengingat = DummyData.notifikasiSejak(kamisMalam).first;

      expect(pengingat.id, DummyData.idPengingatSesi);
      expect(pengingat.jenis, JenisNotifikasi.sesi);
      expect(pengingat.sirkelId, sesiPertama.sirkelId);
      // Sesi pertama setelah Kamis malam: Struktur Data, Sabtu 7 Nov 10.00.
      expect(pengingat.teks, contains('Struktur Data'));
      expect(pengingat.teks, contains('Sabtu, 7 Nov'));
    });

    test('label pengingat memakai "Hari ini" dan "Besok"', () {
      // Rabu 4 Nov 08.00 → Basis Data hari ini pukul 16.00.
      expect(
        DummyData.notifikasiSejak(DateTime(2026, 11, 4, 8)).first.teks,
        contains('Hari ini pukul 16.00'),
      );
      // Rabu 4 Nov 17.31 (Basis Data 16.00–17.30 sudah selesai) → Kalkulus I besok pukul 19.00.
      expect(
        DummyData.notifikasiSejak(DateTime(2026, 11, 4, 17, 31)).first.teks,
        contains('Besok pukul 19.00'),
      );
    });

    test('notifikasi statis "dimulai 1 jam lagi" sudah tidak ada', () {
      final daftar = DummyData.notifikasi;
      expect(daftar.any((n) => n.teks.contains('dimulai 1 jam lagi')), isFalse);
      expect(daftar.any((n) => n.id == 'n1'), isFalse);
    });

    test('gabung("s4") menambah notifikasi diterima yang belum dibaca', () {
      DummyData.gabung('s4');

      final baru = DummyData.notifikasi
          .where((n) => n.jenis == JenisNotifikasi.diterima && n.sirkelId == 's4')
          .toList();
      expect(baru, hasLength(1));
      expect(baru.single.belumDibaca, isTrue);
      expect(baru.single.teks, contains('Statistika · Uji Hipotesis'));
    });

    test('keluarSirkel("s1") menghapus s1 dari sirkelDiikuti dan jadwalSesi', () {
      final anggotaAwal = DummyData.cariSirkel('s1')!.anggota.length;

      DummyData.keluarSirkel('s1');

      expect(DummyData.sirkelDiikuti.any((s) => s.id == 's1'), isFalse);
      expect(DummyData.jadwalSesi.any((s) => s.sirkelId == 's1'), isFalse);
      expect(DummyData.cariSirkel('s1')!.anggota.length, anggotaAwal - 1);
    });

    test('keluarSirkel diabaikan untuk sirkel yang mentornya pengguna aktif', () {
      final id = buatSirkelBaru();

      DummyData.keluarSirkel(id);

      expect(DummyData.sudahGabung(id), isTrue);
      expect(DummyData.jadwalSesi.any((s) => s.sirkelId == id), isTrue);
    });

    test('ajukanMentor: status menjadi menunggu dan ada notifikasi mentor', () {
      expect(DummyData.statusMentor, StatusMentor.peserta);

      DummyData.ajukanMentor();

      expect(DummyData.statusMentor, StatusMentor.menunggu);
      expect(
        DummyData.notifikasi
            .any((n) => n.jenis == JenisNotifikasi.mentor && n.gambar == null),
        isTrue,
      );
    });

    test('tambahSirkel tidak mengubah status peran dan menambah notifikasi terbit', () {
      final id = buatSirkelBaru();

      // Peran hanya berubah lewat pengajuan mentor, bukan lewat menerbitkan sirkel.
      expect(DummyData.statusMentor, StatusMentor.peserta);
      expect(DummyData.penggunaAktif.isMentor, isFalse);
      expect(
        DummyData.notifikasi
            .any((n) => n.sirkelId == id && n.teks.contains('Latihan Integral')),
        isTrue,
      );
    });

    test('pengajuan mentor disetujui otomatis setelah lamaPeninjauanMentor', () {
      final diajukan = DateTime(2026, 11, 4, 10);
      DummyData.ajukanMentor(diajukan);

      final hampir = diajukan.add(
        DummyData.lamaPeninjauanMentor - const Duration(seconds: 1),
      );
      expect(DummyData.statusMentorSejak(hampir), StatusMentor.menunggu);
      expect(
        DummyData.notifikasiSejak(hampir)
            .any((n) => n.id == DummyData.idMentorDisetujui),
        isFalse,
      );

      final setelah = diajukan.add(DummyData.lamaPeninjauanMentor);
      expect(DummyData.statusMentorSejak(setelah), StatusMentor.mentor);
      // Kabar "disetujui" tampil paling atas dan belum dibaca.
      final kabar = DummyData.notifikasiSejak(setelah).first;
      expect(kabar.id, DummyData.idMentorDisetujui);
      expect(kabar.belumDibaca, isTrue);
    });

    test('sirkelTersimpan dan materiTersimpan: terakhir disimpan paling atas', () {
      DummyData.toggleSimpanSirkel('s2');
      DummyData.toggleSimpanSirkel('s5');
      DummyData.toggleSimpanMateri('m1');
      DummyData.toggleSimpanMateri('m3');

      expect(DummyData.sirkelTersimpan.map((s) => s.id).toList(), ['s5', 's2']);
      expect(DummyData.materiTersimpan.map((m) => m.id).toList(), ['m3', 'm1']);
    });

    test('ubahProfil(akunBaru: true) mengosongkan avatar di semua tempat', () {
      DummyData.ubahProfil(
        nama: 'Budi Santoso',
        prodi: 'Manajemen',
        akunBaru: true,
      );

      expect(DummyData.penggunaAktif.avatar, isEmpty);
      final diS1 =
          DummyData.cariSirkel('s1')!.anggota.firstWhere((a) => a.id == 'u1');
      expect(diS1.avatar, isEmpty);
      expect(diS1.nama, 'Budi Santoso');
    });

    test('pengingat yang sudah dibaca tampil belum dibaca lagi bila sesinya berganti',
        () {
      DummyData.tandaiSemuaNotifikasiDibaca();
      expect(DummyData.adaNotifikasiBaru, isFalse);
      final sirkelLama = DummyData.notifikasi.first.sirkelId!;

      DummyData.keluarSirkel(sirkelLama);

      final pengingat = DummyData.notifikasi.first;
      expect(pengingat.id, DummyData.idPengingatSesi);
      expect(pengingat.sirkelId, isNot(sirkelLama));
      expect(pengingat.belumDibaca, isTrue);
    });

    test('rentangHalaman membagi halaman materi rata ke setiap bagian', () {
      final m1 = DummyData.cariMateri('m1')!; // 12 hlm, 4 bagian
      expect(m1.rentangHalaman(0), (awal: 1, akhir: 3));
      expect(m1.rentangHalaman(3), (awal: 10, akhir: 12));

      final m2 = DummyData.cariMateri('m2')!; // 1 hlm, 3 bagian
      expect(m2.rentangHalaman(2), (awal: 1, akhir: 1));
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

    testWidgets('Pembaca materi: "Bagian 1 dari 4", lalu Berikutnya ke bagian 2',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);
      final m1 = DummyData.cariMateri('m1')!;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: PembacaMateriScreen(materi: m1),
        ),
      );

      expect(find.textContaining('Bagian 1 dari 4'), findsOneWidget);
      expect(find.text(m1.catatan.first), findsOneWidget);

      await tester.tap(find.text(MateriStrings.berikutnya));
      await tester.pumpAndSettle();

      expect(find.textContaining('Bagian 2 dari 4'), findsOneWidget);
    });
  });

  group('bukaBuatSirkel: hanya mentor yang bisa membuat sirkel (widget test)', () {
    /// Memasang satu tombol yang memanggil bukaBuatSirkel, plus route Buat Sirkel.
    Future<void> pasangTombol(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          routes: {AppRoutes.buatSirkel: (_) => const BuatSirkelScreen()},
          home: Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: TextButton(
                  onPressed: () => bukaBuatSirkel(context),
                  child: const Text('Buka'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Buka'));
      await tester.pumpAndSettle();
    }

    testWidgets('peserta: dialog "Khusus mentor", Ajukan → status menunggu',
        (tester) async {
      await pasangTombol(tester);

      expect(find.text(BuatSirkelStrings.khususMentorJudul), findsOneWidget);
      expect(find.byType(BuatSirkelScreen), findsNothing);

      await tester.tap(find.text(BuatSirkelStrings.ajukanMentor));
      await tester.pumpAndSettle();

      expect(DummyData.statusMentor, StatusMentor.menunggu);
      expect(find.text(BuatSirkelStrings.pengajuanTerkirim), findsOneWidget);
    });

    testWidgets('sedang ditinjau: dialog status, form tidak terbuka',
        (tester) async {
      DummyData.ajukanMentor();
      await pasangTombol(tester);

      expect(find.text(BuatSirkelStrings.ditinjauJudul), findsOneWidget);
      expect(find.byType(BuatSirkelScreen), findsNothing);
    });

    testWidgets('mentor: langsung membuka form Buat Sirkel', (tester) async {
      DummyData.ubahProfil(
        nama: 'Nadia Putri',
        prodi: 'Sistem Informasi',
        mentor: true,
      );
      await pasangTombol(tester);

      expect(find.byType(BuatSirkelScreen), findsOneWidget);
    });
  });
}
