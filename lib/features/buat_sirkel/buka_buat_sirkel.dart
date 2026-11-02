import 'package:flutter/material.dart';

import '../../data/dummy/dummy_data.dart';
import '../../data/models/app_user.dart';
import '../../routes/app_routes.dart';
import 'buat_sirkel_strings.dart';

/// Pintu masuk Buat Sirkel, dipakai FAB Jelajah (ponsel) dan FAB NavigationRail.
/// Hanya mentor yang sudah disetujui yang dibawa ke form. Peserta diajak
/// mengajukan diri, dan yang pengajuannya masih ditinjau diberi tahu statusnya.
/// Mengembalikan true bila form Buat Sirkel dibuka.
Future<bool> bukaBuatSirkel(BuildContext context) async {
  switch (DummyData.statusMentor) {
    case StatusMentor.mentor:
      await Navigator.of(context).pushNamed(AppRoutes.buatSirkel);
      return true;
    case StatusMentor.peserta:
      await _tawarkanPengajuan(context);
      return false;
    case StatusMentor.menunggu:
      await _infoDitinjau(context);
      return false;
  }
}

/// Dialog untuk peserta: jelaskan syaratnya, lalu tawarkan pengajuan mentor.
Future<void> _tawarkanPengajuan(BuildContext context) async {
  final ajukan = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text(BuatSirkelStrings.khususMentorJudul),
      content: const Text(BuatSirkelStrings.khususMentorPesan),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text(BuatSirkelStrings.nanti),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text(BuatSirkelStrings.ajukanMentor),
        ),
      ],
    ),
  );
  if (ajukan != true) return;

  // Sama dengan "Daftar jadi mentor" di Profil: status menjadi "sedang ditinjau".
  DummyData.ajukanMentor();
  if (!context.mounted) return;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      const SnackBar(content: Text(BuatSirkelStrings.pengajuanTerkirim)),
    );
}

/// Dialog untuk pengguna yang pengajuan mentornya masih ditinjau.
Future<void> _infoDitinjau(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text(BuatSirkelStrings.ditinjauJudul),
      content: const Text(BuatSirkelStrings.ditinjauPesan),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text(BuatSirkelStrings.mengerti),
        ),
      ],
    ),
  );
}
