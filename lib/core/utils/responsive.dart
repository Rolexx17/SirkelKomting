import 'package:flutter/widgets.dart';

/// Kelas ukuran jendela Material 3: compact (< 600), medium (600–839), expanded (≥ 840).
enum WindowSize { compact, medium, expanded }

/// Utilitas responsive bersama: menentukan kelas ukuran layar dan jumlah kolom.
class Responsive {
  Responsive._();

  // P7: breakpoint 600 dan 840 mengikuti panduan window size class Material 3
  // (ponsel tegak < 600, tablet kecil/ponsel landscape 600–839, tablet besar ≥ 840).
  static const mediumBreakpoint = 600.0, expandedBreakpoint = 840.0;

  static WindowSize fromWidth(double width) {
    if (width >= expandedBreakpoint) return WindowSize.expanded;
    if (width >= mediumBreakpoint) return WindowSize.medium;
    return WindowSize.compact;
  }

  /// P7: `MediaQuery.sizeOf` hanya membangun ulang widget saat ukuran berubah,
  /// bukan saat data MediaQuery lain (misalnya keyboard) berubah.
  static WindowSize of(BuildContext context) =>
      fromWidth(MediaQuery.sizeOf(context).width);

  /// Memilih salah satu nilai kolom sesuai kelas ukuran layar saat ini.
  static int columns(
    BuildContext context, {
    required int compact,
    required int medium,
    required int expanded,
  }) {
    return switch (of(context)) {
      WindowSize.compact => compact,
      WindowSize.medium => medium,
      WindowSize.expanded => expanded,
    };
  }
}

/// Jalan pintas agar bisa menulis `context.isCompact` di layar mana pun.
extension ResponsiveContext on BuildContext {
  WindowSize get windowSize => Responsive.of(this);
  bool get isCompact => windowSize == WindowSize.compact;
  bool get isExpanded => windowSize == WindowSize.expanded;
}
