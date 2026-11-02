import 'package:flutter/material.dart';

import '../../core/constants/app_sizes.dart';
import '../../data/models/sirkel.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/user_avatar.dart';
import 'sirkel_strings.dart';

/// Membuka bottom sheet daftar lengkap anggota [sirkel]: mentor di urutan pertama,
/// lalu setiap anggota. Dipanggil dari tombol "Lihat" di Detail Sirkel.
Future<void> showAnggotaSheet(BuildContext context, Sirkel sirkel) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    // P7: lebar sheet maksimum 640 di layar lebar, sama dengan sheet Filter.
    constraints: const BoxConstraints(maxWidth: AppSizes.sheetMaxWidth),
    builder: (_) => _AnggotaSheet(sirkel: sirkel),
  );
}

class _AnggotaSheet extends StatelessWidget {
  const _AnggotaSheet({required this.sirkel});

  final Sirkel sirkel;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final mentor = sirkel.mentor;

    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.pagePadding),
            child: Text(
              SirkelStrings.anggota(sirkel.anggota.length, sirkel.kuota),
              style: text.titleLarge,
            ),
          ),
          const SizedBox(height: AppSizes.s),
          // P6: Flexible + ListView(shrinkWrap) → sheet setinggi isinya, dan
          // bisa digulir bila anggota banyak atau layar landscape.
          Flexible(
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.only(bottom: AppSizes.m),
              children: [
                _BarisOrang(
                  avatar: mentor.avatar,
                  nama: mentor.nama,
                  keterangan:
                      SirkelStrings.prodiAngkatan(mentor.prodi, mentor.angkatan),
                  trailing: const Chip(label: Text(SirkelStrings.labelMentor)),
                ),
                if (sirkel.anggota.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(AppSizes.pagePadding),
                    child: EmptyState(
                      title: SirkelStrings.belumAdaAnggota,
                      message: SirkelStrings.belumAdaAnggotaPesan,
                    ),
                  )
                else
                  for (final a in sirkel.anggota)
                    _BarisOrang(
                      avatar: a.avatar,
                      nama: a.nama,
                      keterangan: SirkelStrings.prodiAngkatan(a.prodi, a.angkatan),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BarisOrang extends StatelessWidget {
  const _BarisOrang({
    required this.avatar,
    required this.nama,
    required this.keterangan,
    this.trailing,
  });

  final String avatar;
  final String nama;
  final String keterangan;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSizes.pagePadding),
      // Nama ikut dikirim: akun baru tanpa foto tampil sebagai inisial.
      leading: UserAvatar(imagePath: avatar, nama: nama, size: AppSizes.avatarM),
      title: Text(nama),
      subtitle: Text(keterangan),
      trailing: trailing,
    );
  }
}
