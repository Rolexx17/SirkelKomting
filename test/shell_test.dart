import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sirkel_mobile/core/theme/app_theme.dart';
import 'package:sirkel_mobile/features/beranda/beranda_strings.dart';
import 'package:sirkel_mobile/features/shell/main_shell.dart';
import 'package:sirkel_mobile/features/shell/shell_strings.dart';

/// Judul tab Jelajah (Bagian 10 brief); tampil hanya bila tab Jelajah aktif.
const _judulJelajah = 'Jelajah sirkel';

void main() {
  /// Memasang MainShell pada ukuran layar logis tertentu (lebar × tinggi dalam dp).
  Future<void> pasangShell(WidgetTester tester, Size ukuran) async {
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = ukuran * 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light(), home: const MainShell()),
    );
    await tester.pumpAndSettle();
  }

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
}
