import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sirkel_mobile/core/theme/app_theme.dart';
import 'package:sirkel_mobile/data/dummy/dummy_data.dart';
import 'package:sirkel_mobile/data/models/app_user.dart';
import 'package:sirkel_mobile/features/auth/auth_strings.dart';
import 'package:sirkel_mobile/features/auth/auth_validator.dart';
import 'package:sirkel_mobile/features/auth/daftar_screen.dart';
import 'package:sirkel_mobile/features/auth/masuk_screen.dart';
import 'package:sirkel_mobile/features/auth/widgets/auth_brand_panel.dart';
import 'package:sirkel_mobile/features/onboarding/onboarding_screen.dart';
import 'package:sirkel_mobile/features/onboarding/onboarding_strings.dart';
import 'package:sirkel_mobile/features/profil/lencana_progres.dart';
import 'package:sirkel_mobile/features/profil/profil_screen.dart';
import 'package:sirkel_mobile/features/profil/profil_strings.dart';
import 'package:sirkel_mobile/features/profil/simpanan_screen.dart';
import 'package:sirkel_mobile/routes/app_routes.dart';
import 'package:sirkel_mobile/shared/widgets/app_logo.dart';

/// Penanda halaman tujuan setelah Masuk/Daftar berhasil (pengganti MainShell khusus di test ini).
const _tandaBeranda = 'Halaman Beranda (uji)';

void main() {
  // Data disimpan statis; dikembalikan ke kondisi awal agar test tidak saling memengaruhi.
  setUp(DummyData.resetUntukTes);

  /// Memasang [layar] (default ponsel 360×800) dengan route Masuk, Daftar, dan Beranda uji.
  Future<void> pasang(
    WidgetTester tester,
    Widget layar, {
    Size ukuran = const Size(360, 800),
  }) async {
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = ukuran * 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: layar,
        routes: {
          AppRoutes.masuk: (_) => const MasukScreen(),
          AppRoutes.daftar: (_) => const DaftarScreen(),
          AppRoutes.home: (_) => const Scaffold(body: Text(_tandaBeranda)),
        },
      ),
    );
  }

  Future<void> pasangMasuk(WidgetTester tester) =>
      pasang(tester, const MasukScreen());

  Finder tombolMasuk() => find.widgetWithText(FilledButton, AuthStrings.masuk);
  Finder tombolBuatAkun() =>
      find.widgetWithText(FilledButton, AuthStrings.buatAkun);

  /// Menggulir sampai [target] terlihat, lalu mengetuknya.
  Future<void> ketuk(WidgetTester tester, Finder target) async {
    await tester.ensureVisible(target);
    await tester.pumpAndSettle();
    await tester.tap(target);
    await tester.pumpAndSettle();
  }

  group('Validasi halaman Masuk', () {
    testWidgets('menekan Masuk dengan email kosong menampilkan pesan validasi',
        (tester) async {
      await pasangMasuk(tester);

      await tester.tap(tombolMasuk());
      await tester.pump();

      expect(find.text(AuthStrings.emailWajib), findsOneWidget);
      expect(find.text(_tandaBeranda), findsNothing);
    });

    testWidgets('email nadia@mhs.ac.id + sandi 6 karakter tidak menampilkan error',
        (tester) async {
      await pasangMasuk(tester);

      await tester.enterText(find.byType(TextFormField).at(0), 'nadia@mhs.ac.id');
      await tester.enterText(find.byType(TextFormField).at(1), 'abc123');
      await tester.tap(tombolMasuk());
      await tester.pumpAndSettle();

      expect(find.text(AuthStrings.emailWajib), findsNothing);
      expect(find.text(AuthStrings.emailTidakValid), findsNothing);
      expect(find.text(AuthStrings.sandiWajib), findsNothing);
      expect(find.text(AuthStrings.sandiMinimal), findsNothing);
      // Form valid → aplikasi pindah ke route /home.
      expect(find.text(_tandaBeranda), findsOneWidget);
    });
  });

  group('RichText "Belum punya akun? Daftar"', () {
    testWidgets('hanya kata "Daftar" yang membuka layar Daftar', (tester) async {
      await pasangMasuk(tester);

      // Mengetuk bagian kalimat yang bukan "Daftar" tidak melakukan apa pun.
      await tester.tapOnText(find.textRange.ofSubstring('Belum punya akun?'));
      await tester.pumpAndSettle();
      expect(find.text(AuthStrings.daftarSubjudul), findsNothing);

      await tester.tapOnText(find.textRange.ofSubstring(AuthStrings.daftar));
      await tester.pumpAndSettle();
      expect(find.text(AuthStrings.daftarSubjudul), findsOneWidget);
    });
  });

  group('Halaman Daftar', () {
    testWidgets('tombol Buat akun nonaktif sebelum checkbox dicentang',
        (tester) async {
      await pasang(tester, const DaftarScreen());

      FilledButton tombol() => tester.widget<FilledButton>(tombolBuatAkun());
      expect(tombol().onPressed, isNull);

      await ketuk(tester, find.byType(Checkbox));
      expect(tombol().onPressed, isNotNull);
    });

    testWidgets('mendaftar sebagai "Budi Santoso" mengubah pengguna aktif',
        (tester) async {
      await pasang(tester, const DaftarScreen());
      final kolom = find.byType(TextFormField);

      await tester.enterText(kolom.at(0), 'Budi Santoso');
      await tester.enterText(kolom.at(1), 'budi@mhs.ac.id');
      await tester.enterText(kolom.at(2), 'rahasia');

      // Membuka DropdownMenu lalu memilih prodi. DropdownMenu membuat salinan
      // tersembunyi item untuk mengukur lebar, jadi item menu yang tampil adalah .last.
      await ketuk(tester, find.byType(DropdownMenu<String>));
      await tester.tap(
        find.widgetWithText(MenuItemButton, 'Teknik Informatika').last,
      );
      await tester.pumpAndSettle();

      await ketuk(tester, find.text(AuthStrings.mentor));
      await ketuk(tester, find.byType(Checkbox));
      await ketuk(tester, tombolBuatAkun());

      expect(find.text(_tandaBeranda), findsOneWidget);
      final pengguna = DummyData.penggunaAktif;
      expect(pengguna.nama, 'Budi Santoso');
      expect(pengguna.prodi, 'Teknik Informatika');
      // Peran Mentor saat daftar = pengajuan, bukan langsung mentor.
      expect(pengguna.isMentor, isFalse);
      expect(DummyData.statusMentor, StatusMentor.menunggu);
      // akunBaru: avatar dikosongkan agar tampil inisial, bukan foto Nadia.
      expect(pengguna.avatar, isEmpty);
    });
  });

  group('Onboarding', () {
    testWidgets('Lanjut 2× mengubah tombol menjadi "Mulai sekarang"',
        (tester) async {
      await pasang(tester, const OnboardingScreen());
      expect(find.text(OnboardingStrings.lanjut), findsOneWidget);

      await tester.tap(find.text(OnboardingStrings.lanjut));
      await tester.pumpAndSettle();
      await tester.tap(find.text(OnboardingStrings.lanjut));
      await tester.pumpAndSettle();

      expect(find.text(OnboardingStrings.mulaiSekarang), findsOneWidget);
      expect(find.text(OnboardingStrings.lanjut), findsNothing);
    });

    testWidgets('Lewati membuka layar Masuk', (tester) async {
      await pasang(tester, const OnboardingScreen());

      await tester.tap(find.text(OnboardingStrings.lewati));
      await tester.pumpAndSettle();

      expect(find.text(AuthStrings.masukJudul), findsOneWidget);
    });
  });

  group('Lupa kata sandi', () {
    Finder kolomSheet() => find.descendant(
          of: find.byType(BottomSheet),
          matching: find.byType(TextFormField),
        );
    Finder tombolKirim() =>
        find.widgetWithText(FilledButton, AuthStrings.kirimTautan);

    testWidgets('email bukan .ac.id menampilkan pesan error di sheet',
        (tester) async {
      await pasangMasuk(tester);
      await tester.tap(find.text(AuthStrings.lupaSandi));
      await tester.pumpAndSettle();

      await tester.enterText(kolomSheet(), 'budi@gmail.com');
      await tester.tap(tombolKirim());
      await tester.pump();

      expect(find.text(AuthStrings.emailTidakValid), findsOneWidget);
      expect(find.byType(BottomSheet), findsOneWidget);
    });

    testWidgets('email valid menutup sheet dan menampilkan SnackBar berisi email',
        (tester) async {
      await pasangMasuk(tester);
      await tester.tap(find.text(AuthStrings.lupaSandi));
      await tester.pumpAndSettle();

      await tester.enterText(kolomSheet(), 'budi@mhs.ac.id');
      await tester.tap(tombolKirim());
      await tester.pumpAndSettle();

      expect(find.byType(BottomSheet), findsNothing);
      expect(
        find.text(AuthStrings.tautanTerkirim('budi@mhs.ac.id')),
        findsOneWidget,
      );
    });
  });

  group('Masuk di layar lebar', () {
    testWidgets('1280×800: dua panel dan logo hanya muncul sekali',
        (tester) async {
      await pasang(tester, const MasukScreen(), ukuran: const Size(1280, 800));

      expect(find.byType(AuthBrandPanel), findsOneWidget);
      // Logo di atas form disembunyikan; yang tersisa hanya logo di panel brand.
      expect(find.byType(AppLogo), findsOneWidget);
    });
  });

  group('Profil', () {
    Future<void> pasangProfil(WidgetTester tester) =>
        pasang(tester, const ProfilScreen());

    testWidgets('Ubah profil menyimpan nama baru dan teks di Profil berubah',
        (tester) async {
      await pasangProfil(tester);
      expect(find.text('Nadia Putri'), findsOneWidget);

      await ketuk(tester, find.text(ProfilStrings.ubahProfil));
      await tester.enterText(
        find.descendant(
          of: find.byType(BottomSheet),
          matching: find.byType(TextFormField),
        ),
        'Budi Santoso',
      );
      await ketuk(tester, find.widgetWithText(FilledButton, ProfilStrings.simpan));

      expect(find.text('Budi Santoso'), findsOneWidget);
      expect(find.text(ProfilStrings.profilDiperbarui), findsOneWidget);
      expect(DummyData.penggunaAktif.nama, 'Budi Santoso');
    });

    testWidgets('dialog Keluar: Batal tetap di Profil', (tester) async {
      await pasangProfil(tester);

      await ketuk(tester, find.text(ProfilStrings.keluar));
      expect(find.text(ProfilStrings.keluarJudul), findsOneWidget);

      await ketuk(tester, find.text(ProfilStrings.batal));
      expect(find.text(ProfilStrings.keluarJudul), findsNothing);
      expect(find.byType(ProfilScreen), findsOneWidget);
    });

    testWidgets('dialog Keluar: Keluar membuka layar Masuk', (tester) async {
      await pasangProfil(tester);

      await ketuk(tester, find.text(ProfilStrings.keluar));
      // Ada dua teks "Keluar" (menu dan tombol dialog); yang diketuk tombol dialog.
      await ketuk(
        tester,
        find.widgetWithText(TextButton, ProfilStrings.keluar),
      );

      expect(find.text(AuthStrings.masukJudul), findsOneWidget);
      expect(find.byType(ProfilScreen), findsNothing);
    });

    testWidgets('Ajukan mentor mengubah menu menjadi status ditinjau',
        (tester) async {
      await pasangProfil(tester);

      await ketuk(tester, find.text(ProfilStrings.menuDaftarMentor));
      await ketuk(tester, find.widgetWithText(TextButton, ProfilStrings.ajukan));

      expect(DummyData.statusMentor, StatusMentor.menunggu);
      expect(find.text(ProfilStrings.mentorDitinjau), findsOneWidget);
      expect(find.text(ProfilStrings.menuDaftarMentor), findsNothing);
      expect(find.text(ProfilStrings.peranMenunggu), findsOneWidget);
    });

    testWidgets('menu Simpanan menampilkan Badge jumlah dan membuka Simpanan',
        (tester) async {
      DummyData.toggleSimpanSirkel('s1');
      await pasangProfil(tester);

      expect(
        find.descendant(of: find.byType(Badge), matching: find.text('1')),
        findsOneWidget,
      );

      await ketuk(tester, find.text(ProfilStrings.menuSimpanan));
      expect(find.byType(SimpananScreen), findsOneWidget);
    });
  });

  group('Simpanan', () {
    testWidgets('sirkel yang disimpan tampil di tab Sirkel', (tester) async {
      DummyData.toggleSimpanSirkel('s1');
      await pasang(tester, const SimpananScreen());

      expect(find.text(ProfilStrings.tabSirkel(1)), findsOneWidget);
      expect(find.text('Limit & Turunan'), findsOneWidget);
    });

    testWidgets('tanpa simpanan menampilkan pesan kosong', (tester) async {
      await pasang(tester, const SimpananScreen());

      expect(find.text(ProfilStrings.sirkelKosongJudul), findsOneWidget);
    });

    testWidgets('tab Materi menampilkan materi yang disimpan', (tester) async {
      DummyData.toggleSimpanMateri('m1');
      await pasang(tester, const SimpananScreen());

      await ketuk(tester, find.text(ProfilStrings.tabMateri(1)));

      expect(find.text('Rangkuman Limit Fungsi'), findsOneWidget);
    });
  });

  group('Iterasi 4: kekuatan kata sandi', () {
    test('kurang dari 6 karakter selalu lemah, walau lengkap', () {
      expect(AuthValidator.kekuatanSandi('Ab1!'), KekuatanSandi.lemah);
    });

    test('6 huruf kecil saja → lemah', () {
      expect(AuthValidator.kekuatanSandi('abcdef'), KekuatanSandi.lemah);
    });

    test('8 karakter + angka → sedang', () {
      expect(AuthValidator.kekuatanSandi('abcdef12'), KekuatanSandi.sedang);
    });

    test('8+ karakter, huruf besar & kecil, angka, simbol → kuat', () {
      expect(AuthValidator.kekuatanSandi('Abcdef12!'), KekuatanSandi.kuat);
    });

    testWidgets('indikator di Daftar berubah saat sandi diketik', (tester) async {
      await pasang(tester, const DaftarScreen());
      final kolomSandi = find.byType(TextFormField).at(2);

      expect(find.text(AuthStrings.sandiLemah), findsNothing);

      await tester.enterText(kolomSandi, 'abcdef');
      await tester.pump();
      expect(find.text(AuthStrings.sandiLemah), findsOneWidget);

      await tester.enterText(kolomSandi, 'Abcdef12!');
      await tester.pump();
      expect(find.text(AuthStrings.sandiKuat), findsOneWidget);
      expect(find.text(AuthStrings.saranSandi), findsNothing);
    });
  });

  group('Iterasi 4: lencana dinamis', () {
    List<String> nama(List<ProgresLencana> daftar) =>
        daftar.map((p) => p.lencana.nama).toList();

    test('data awal: 2 didapat di depan, lalu yang paling dekat tercapai', () {
      final hasil = hitungProgresLencana(
        sirkelDiikuti: 3,
        jamBelajar: 24,
        materiTersimpan: 0,
        sirkelTersimpan: 0,
        mentor: false,
      );

      expect(hasil.where((p) => p.didapat), hasLength(2));
      expect(nama(hasil).take(3).toList(), [
        ProfilStrings.lencanaSesiPertama,
        ProfilStrings.lencanaRajinHadir,
        ProfilStrings.lencanaAnggotaAktif, // 3/4, paling dekat
      ]);
    });

    test('nilai di atas target dibatasi: 6/4 tampil 4/4 dan rasio 1', () {
      final anggotaAktif = hitungProgresLencana(
        sirkelDiikuti: 6,
        jamBelajar: 0,
        materiTersimpan: 0,
        sirkelTersimpan: 0,
        mentor: false,
      ).firstWhere((p) => p.lencana.nama == ProfilStrings.lencanaAnggotaAktif);

      expect(anggotaAktif.didapat, isTrue);
      expect(anggotaAktif.nilaiTampil, targetAnggotaAktif);
      expect(anggotaAktif.rasio, 1.0);
    });

    test('mentor disetujui membuka lencana Mentor Sebaya', () {
      final mentorSebaya = hitungProgresLencana(
        sirkelDiikuti: 0,
        jamBelajar: 0,
        materiTersimpan: 0,
        sirkelTersimpan: 0,
        mentor: true,
      ).first;

      expect(mentorSebaya.lencana.nama, ProfilStrings.lencanaMentorSebaya);
      expect(mentorSebaya.didapat, isTrue);
    });

    testWidgets('Profil awal: Anggota Aktif masih 3/4', (tester) async {
      await pasang(tester, const ProfilScreen());

      expect(
        find.text(ProfilStrings.progres(3, targetAnggotaAktif)),
        findsOneWidget,
      );
    });

    testWidgets('setelah gabung sirkel ke-4, Anggota Aktif didapat', (tester) async {
      DummyData.gabung('s4');
      await pasang(tester, const ProfilScreen());

      expect(
        find.text(ProfilStrings.progres(3, targetAnggotaAktif)),
        findsNothing,
      );
      // Statistik "Lencana" ikut naik dari 2 menjadi 3.
      expect(progresLencanaSaatIni().where((p) => p.didapat), hasLength(3));
    });

    testWidgets('mengetuk lencana membuka detail berisi syarat', (tester) async {
      await pasang(tester, const ProfilScreen());

      await ketuk(tester, find.text(ProfilStrings.lencanaKolektorMateri));

      expect(
        find.text(ProfilStrings.syaratKolektorMateri(targetKolektorMateri)),
        findsOneWidget,
      );
      expect(find.text(ProfilStrings.belumDidapat), findsOneWidget);
    });

    testWidgets('sheet Semua lencana menampilkan jumlah didapat', (tester) async {
      await pasang(tester, const ProfilScreen());

      await ketuk(tester, find.text(ProfilStrings.semua));

      expect(find.text(ProfilStrings.lencanaTerkumpul(2, 6)), findsOneWidget);
    });
  });

  group('Iterasi 4: Simpanan geser hapus & Urungkan', () {
    test('hapusDariDaftar mengembalikan daftar baru dan posisi asal', () {
      final hasil = hapusDariDaftar(['s1', 's2', 's3'], 's2');
      expect(hasil.daftar, ['s1', 's3']);
      expect(hasil.posisi, 1);
    });

    test('hapusDariDaftar untuk id yang tidak ada → posisi -1, daftar tetap', () {
      final hasil = hapusDariDaftar(['s1'], 's9');
      expect(hasil.daftar, ['s1']);
      expect(hasil.posisi, -1);
    });

    test('sisipkanKembali mengembalikan ke posisi semula, tanpa dobel', () {
      expect(sisipkanKembali(['s1', 's3'], 's2', 1), ['s1', 's2', 's3']);
      expect(sisipkanKembali(['s1', 's2'], 's2', 0), ['s1', 's2']);
      // Posisi di luar batas dipotong ke ujung daftar.
      expect(sisipkanKembali(['s1'], 's2', 9), ['s1', 's2']);
    });

    testWidgets('geser kartu menghapus dari simpanan, Urungkan mengembalikannya',
        (tester) async {
      DummyData.toggleSimpanSirkel('s1');
      DummyData.toggleSimpanSirkel('s2');
      await pasang(tester, const SimpananScreen());

      // Kartu teratas = terakhir disimpan (s2). Geser ke kiri sampai terhapus.
      await tester.drag(
        find.text('Tree & Graph'),
        const Offset(-600, 0),
      );
      await tester.pumpAndSettle();

      expect(DummyData.idSirkelDisimpan, ['s1']);
      expect(find.text(ProfilStrings.sirkelDihapus), findsOneWidget);

      await tester.tap(find.text(ProfilStrings.urungkan));
      await tester.pumpAndSettle();

      expect(DummyData.idSirkelDisimpan, ['s1', 's2']);
      expect(find.text('Tree & Graph'), findsOneWidget);
    });
  });
}
