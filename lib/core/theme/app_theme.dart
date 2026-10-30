import 'package:flutter/material.dart';

import '../constants/app_sizes.dart';

/// Tema Material 3 aplikasi Sirkel: semua warna diturunkan dari satu seed color.
class AppTheme {
  AppTheme._();

  static const seedColor = Color(0xFF4355B9);

  /// Warna resmi SDG 4. Hanya untuk kotak angka "4" di Splash.
  static const sdg4Red = Color(0xFFC5192D);
  static const fontFamily = 'PlusJakartaSans';

  static ThemeData light() {
    // P4: fromSeed menurunkan seluruh peran warna (primary, container, surface, dst.)
    // dari satu warna dasar, sehingga widget cukup membaca colorScheme.
    final scheme = ColorScheme.fromSeed(seedColor: seedColor);
    return _build(scheme);
  }

  static ThemeData _build(ColorScheme scheme) {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: fontFamily,
    );
    final tt = _textTheme(base.textTheme);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: fontFamily,
      textTheme: tt,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarThemeData(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: tt.titleLarge,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(AppSizes.xxl * 2, AppSizes.buttonHeight),
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.xl),
          shape: const StadiumBorder(),
          textStyle: tt.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(AppSizes.xxl * 2, AppSizes.buttonHeight),
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.xl),
          shape: const StadiumBorder(),
          side: BorderSide(color: scheme.outline),
          textStyle: tt.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(AppSizes.buttonHeight, AppSizes.buttonHeight),
          shape: const StadiumBorder(),
          textStyle: tt.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationThemeData(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusS),
          borderSide: BorderSide(color: scheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusS),
          borderSide: BorderSide(color: scheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusS),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.m,
          vertical: AppSizes.m,
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusS),
        ),
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerLow,
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surfaceContainer,
        indicatorColor: scheme.secondaryContainer,
        labelTextStyle: WidgetStatePropertyAll(tt.labelMedium),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.secondaryContainer,
      ),
      searchBarTheme: SearchBarThemeData(
        elevation: const WidgetStatePropertyAll(0),
        backgroundColor: WidgetStatePropertyAll(scheme.surfaceContainerHigh),
        constraints: const BoxConstraints(minHeight: AppSizes.searchBarHeight),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: AppSizes.m),
        ),
        hintStyle: WidgetStatePropertyAll(
          tt.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primaryContainer,
        foregroundColor: scheme.onPrimaryContainer,
        extendedTextStyle: tt.titleSmall,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSizes.radiusXL),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surfaceContainerHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusS),
        ),
      ),
      dividerTheme: DividerThemeData(color: scheme.outlineVariant, space: 1),
    );
  }

  // Skala tipografi Plus Jakarta Sans sesuai tabel Bagian 9 (ukuran/tinggi baris, bobot).
  static TextTheme _textTheme(TextTheme t) {
    return t.copyWith(
      headlineSmall: t.headlineSmall?.copyWith(
        fontSize: 24,
        height: 32 / 24,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: t.titleLarge?.copyWith(
        fontSize: 22,
        height: 28 / 22,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: t.titleMedium?.copyWith(
        fontSize: 16,
        height: 24 / 16,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: t.titleSmall?.copyWith(
        fontSize: 14,
        height: 20 / 14,
        fontWeight: FontWeight.w600,
      ),
      bodyMedium: t.bodyMedium?.copyWith(
        fontSize: 14,
        height: 20 / 14,
        fontWeight: FontWeight.w400,
      ),
      bodySmall: t.bodySmall?.copyWith(
        fontSize: 12,
        height: 16 / 12,
        fontWeight: FontWeight.w400,
      ),
      labelLarge: t.labelLarge?.copyWith(
        fontSize: 14,
        height: 20 / 14,
        fontWeight: FontWeight.w600,
      ),
      labelMedium: t.labelMedium?.copyWith(
        fontSize: 12,
        height: 16 / 12,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
