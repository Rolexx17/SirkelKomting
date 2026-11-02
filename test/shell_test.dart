import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sirkel_mobile/core/theme/app_theme.dart';
import 'package:sirkel_mobile/data/dummy/dummy_data.dart';
import 'package:sirkel_mobile/data/models/sesi.dart';
import 'package:sirkel_mobile/features/beranda/beranda_screen.dart';
import 'package:sirkel_mobile/features/beranda/beranda_strings.dart';
import 'package:sirkel_mobile/features/notifikasi/notifikasi_screen.dart';
import 'package:sirkel_mobile/features/notifikasi/notifikasi_strings.dart';
import 'package:sirkel_mobile/features/shell/main_shell.dart';
import 'package:sirkel_mobile/features/shell/shell_strings.dart';
import 'package:sirkel_mobile/features/sirkel_saya/jadwal_util.dart';
import 'package:sirkel_mobile/features/sirkel_saya/sirkel_saya_screen.dart';
import 'package:sirkel_mobile/features/sirkel_saya/sirkel_saya_strings.dart';
import 'package:sirkel_mobile/features/sirkel_saya/widgets/sesi_sheet.dart';
import 'package:sirkel_mobile/routes/app_routes.dart';
import 'package:sirkel_mobile/shared/widgets/user_avatar.dart';

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
  group('Iterasi 3: MainShell & Beranda', () {
    /// Pindah ke tab Jelajah lalu kembali ke Beranda lewat NavigationBar.
    Future<void> pulangKeBeranda(WidgetTester tester) async {
      Finder tab(String label) => find.descendant(
            of: find.byType(NavigationBar),
            matching: find.text(label),
          );
      await tester.tap(tab(ShellStrings.jelajah));
      await tester.pumpAndSettle();
      await tester.tap(tab(ShellStrings.beranda));
      await tester.pumpAndSettle();
    }

    testWidgets('regresi tab basi: nama baru langsung tampil setelah pindah tab',
        (tester) async {
      await pasangShell(tester, const Size(360, 800));
      expect(find.text('Budi'), findsNothing);

      DummyData.ubahProfil(nama: 'Budi Santoso', prodi: 'Teknik Informatika');
      await pulangKeBeranda(tester);

      expect(find.text('Budi'), findsOneWidget);
    });

    testWidgets('setelah semua notifikasi dibaca dan Beranda di-build ulang, Badge hilang',
        (tester) async {
      await pasangShell(tester, const Size(360, 800));
      expect(badgeTampil(tester), isTrue);

      DummyData.tandaiSemuaNotifikasiDibaca();
      await pulangKeBeranda(tester);

      expect(badgeTampil(tester), isFalse);
    });

    testWidgets('notifikasi mentor bisa diketuk dan membuka tab Profil',
        (tester) async {
      DummyData.ajukanMentor();
      await pasangShell(tester, const Size(360, 800));

      await tester.tap(find.byIcon(Icons.notifications_outlined));
      await tester.pumpAndSettle();
      final itemMentor = find.byIcon(Icons.school);
      expect(itemMentor, findsOneWidget);
      await tester.tap(itemMentor);
      await tester.pumpAndSettle();

      final shell = tester.state<MainShellState>(find.byType(MainShell));
      expect(shell.indexAktif, MainShell.tabProfil);
    });

    final pagi = DateTime(2026, 11, 2, 8);

    test('labelSesi: sesi hari ini → "HARI INI"', () {
      expect(
        BerandaScreen.labelSesi(DateTime(2026, 11, 2, 19), pagi),
        BerandaStrings.hariIni,
      );
    });

    test('labelSesi: sesi besok → "BESOK"', () {
      expect(
        BerandaScreen.labelSesi(DateTime(2026, 11, 3, 19), pagi),
        BerandaStrings.besok,
      );
    });

    test('labelSesi: sesi lusa → nama hari + tanggal', () {
      expect(
        BerandaScreen.labelSesi(DateTime(2026, 11, 4, 16), pagi),
        'RABU, 4 NOV',
      );
    });
  });

  group('Iterasi 3: UserAvatar', () {
    Future<void> pasangAvatar(WidgetTester tester, UserAvatar avatar) async {
      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.light(), home: Scaffold(body: avatar)),
      );
    }

    testWidgets('tanpa foto dengan nama menampilkan inisial "BS"', (tester) async {
      await pasangAvatar(
        tester,
        const UserAvatar(imagePath: '', nama: 'Budi Santoso'),
      );
      expect(find.text('BS'), findsOneWidget);
    });

    testWidgets('tanpa foto dan tanpa nama menampilkan ikon person', (tester) async {
      await pasangAvatar(tester, const UserAvatar(imagePath: ''));
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    test('inisial maksimal dua huruf kapital', () {
      expect(UserAvatar.inisial('budi santoso putra'), 'BS');
      expect(UserAvatar.inisial('Nadia'), 'N');
      expect(UserAvatar.inisial('   '), '');
    });
  });

  group('Iterasi 3: jadwal_util', () {
    final sekarang = DateTime(2026, 11, 2, 8);

    test('teksMulai: 30 menit lagi', () {
      expect(
        teksMulai(sekarang.add(const Duration(minutes: 30)), sekarang),
        'Mulai dalam 30 menit',
      );
    });

    test('teksMulai: 5 jam lagi', () {
      expect(
        teksMulai(sekarang.add(const Duration(hours: 5)), sekarang),
        'Mulai dalam 5 jam',
      );
    });

    test('teksMulai: besok (lebih dari 24 jam) → "Besok, 19.00"', () {
      expect(teksMulai(DateTime(2026, 11, 3, 19), sekarang), 'Besok, 19.00');
    });

    test('teksMulai: 3 hari lagi', () {
      expect(teksMulai(DateTime(2026, 11, 5, 19), sekarang), 'Mulai 3 hari lagi');
    });

    test('bisaMasukSesi: 15 menit sebelum mulai sampai sesi selesai', () {
      final mulai = DateTime(2026, 11, 2, 19);
      bool bisa(int menitDariMulai) =>
          bisaMasukSesi(mulai, mulai.add(Duration(minutes: menitDariMulai)));

      expect(bisa(-20), isFalse);
      expect(bisa(-10), isTrue);
      expect(bisa(60), isTrue);
      expect(bisa(100), isFalse);
    });
  });

  group('Iterasi 3: Sirkel Saya & sheet sesi', () {
    testWidgets('chevron kanan mengganti daftar ke sesi minggu berikutnya',
        (tester) async {
      aturUkuran(tester, const Size(360, 800));
      final sekarang = DateTime.now();
      final mingguDepan = mingguDari(
        DateTime(sekarang.year, sekarang.month, sekarang.day + 7),
      );
      final sesiMingguDepan = DummyData.jadwalSesi
          .where((s) => mingguDepan.any((h) => hariSama(h, s.waktu)))
          .toList();
      final judulPertama = tanggalPanjang(sesiMingguDepan.first.waktu);

      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.light(), home: const SirkelSayaScreen()),
      );
      await tester.pumpAndSettle();
      // Minggu ini: sesi minggu depan belum boleh tampil.
      expect(find.text(judulPertama), findsNothing);

      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pumpAndSettle();

      final rentang = SirkelSayaStrings.rentangMinggu(
        tanggalSingkat(mingguDepan.first),
        tanggalSingkat(mingguDepan.last),
      );
      expect(find.text(rentang), findsOneWidget);
      expect(find.text(judulPertama), findsOneWidget);
    });

    /// Memasang tombol yang membuka sheet sesi untuk sirkel s1 (online).
    Future<void> bukaSheet(WidgetTester tester, Duration jarakKeSesi) async {
      aturUkuran(tester, const Size(360, 800));
      final sirkel = DummyData.cariSirkel('s1')!;
      final sesi = Sesi(sirkelId: 's1', waktu: DateTime.now().add(jarakKeSesi));
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: TextButton(
                  onPressed: () =>
                      showSesiSheet(context, sirkel: sirkel, sesi: sesi),
                  child: const Text('buka'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('buka'));
      await tester.pumpAndSettle();
    }

    FilledButton tombolMasuk(WidgetTester tester) => tester.widget<FilledButton>(
          find.ancestor(
            of: find.text(SirkelSayaStrings.masukSesi),
            matching: find.byWidgetPredicate((w) => w is FilledButton),
          ),
        );

    testWidgets('sheet: "Masuk sesi" nonaktif untuk sesi lebih dari 15 menit lagi',
        (tester) async {
      await bukaSheet(tester, const Duration(days: 2));

      expect(tombolMasuk(tester).onPressed, isNull);
      expect(
        find.text(SirkelSayaStrings.bantuanMasuk(batasMasukAwal.inMinutes)),
        findsOneWidget,
      );
    });

    testWidgets('sheet: "Masuk sesi" aktif 10 menit sebelum sesi', (tester) async {
      await bukaSheet(tester, const Duration(minutes: 10));
      expect(tombolMasuk(tester).onPressed, isNotNull);
    });

    testWidgets('sheet: "Salin tautan" berubah menjadi "Tautan disalin"',
        (tester) async {
      // Clipboard memakai platform channel; di test dijawab tiruan agar tidak error.
      final messenger = tester.binding.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async => null,
      );
      addTearDown(
        () => messenger.setMockMethodCallHandler(SystemChannels.platform, null),
      );

      await bukaSheet(tester, const Duration(days: 2));
      await tester.tap(find.text(SirkelSayaStrings.salinTautan));
      await tester.pumpAndSettle();

      expect(find.text(SirkelSayaStrings.tautanDisalin), findsOneWidget);
    });
  });
}
