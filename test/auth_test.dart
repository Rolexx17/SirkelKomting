import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sirkel_mobile/core/theme/app_theme.dart';
import 'package:sirkel_mobile/data/dummy/dummy_data.dart';
import 'package:sirkel_mobile/features/auth/auth_strings.dart';
import 'package:sirkel_mobile/features/auth/daftar_screen.dart';
import 'package:sirkel_mobile/features/auth/masuk_screen.dart';
import 'package:sirkel_mobile/routes/app_routes.dart';

/// Penanda halaman tujuan setelah Masuk/Daftar berhasil (pengganti MainShell khusus di test ini).
const _tandaBeranda = 'Halaman Beranda (uji)';

void main() {
  // Data disimpan statis; dikembalikan ke kondisi awal agar test tidak saling memengaruhi.
  setUp(DummyData.resetUntukTes);

  /// Memasang [layar] di ukuran ponsel 360×800 dengan route Daftar dan Beranda uji.
  Future<void> pasang(WidgetTester tester, Widget layar) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: layar,
        routes: {
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
      expect(pengguna.isMentor, isTrue);
    });
  });
}
