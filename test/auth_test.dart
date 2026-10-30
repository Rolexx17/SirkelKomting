import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sirkel_mobile/core/theme/app_theme.dart';
import 'package:sirkel_mobile/features/auth/auth_strings.dart';
import 'package:sirkel_mobile/features/auth/masuk_screen.dart';
import 'package:sirkel_mobile/routes/app_routes.dart';

/// Penanda halaman tujuan setelah Masuk berhasil (pengganti MainShell khusus di test ini).
const _tandaBeranda = 'Halaman Beranda (uji)';

void main() {
  Future<void> pasangMasuk(WidgetTester tester) async {
    // Ukuran ponsel 360×800 (logical pixel).
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const MasukScreen(),
        routes: {
          AppRoutes.home: (_) => const Scaffold(body: Text(_tandaBeranda)),
        },
      ),
    );
  }

  Finder tombolMasuk() => find.widgetWithText(FilledButton, AuthStrings.masuk);

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
}
