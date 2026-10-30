import 'package:flutter/material.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/utils/responsive.dart';
import '../../data/dummy/dummy_data.dart';
import '../../routes/app_routes.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/user_avatar.dart';
import 'profil_strings.dart';
import 'widgets/lencana_item.dart';

/// Tab Profil: identitas, statistik belajar, lencana terbaru, dan menu akun.
/// Navigasi bawah tidak dibuat di sini karena dipegang MainShell.
class ProfilScreen extends StatelessWidget {
  const ProfilScreen({super.key});

  static const _bentukKartu = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(AppSizes.radiusL)),
  );

  void _info(BuildContext context, String pesan) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(pesan)));
  }

  // pushNamedAndRemoveUntil menghapus seluruh riwayat, jadi tombol kembali di Masuk
  // tidak bisa membuka Profil lagi setelah keluar.
  void _keluar(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.masuk,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // P7: lebar ≥ 600 → kartu statistik dan lencana bersebelahan (Row).
            final lebar = constraints.maxWidth >= Responsive.mediumBreakpoint;
            final statistik = _kartuStatistik(context);
            final lencana = _bagianLencana(context);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.pagePadding),
              child: Align(
                alignment: Alignment.topCenter,
                // P7: di layar sangat lebar konten dibatasi agar tidak terlalu melebar.
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: Responsive.expandedBreakpoint,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _kepala(context),
                      const SizedBox(height: AppSizes.xl),
                      if (lebar)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: statistik),
                            const SizedBox(width: AppSizes.xl),
                            Expanded(child: lencana),
                          ],
                        )
                      else ...[
                        statistik,
                        const SizedBox(height: AppSizes.xl),
                        lencana,
                      ],
                      const SizedBox(height: AppSizes.xl),
                      _menu(context),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _kepala(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final pengguna = DummyData.penggunaAktif;

    return Column(
      children: [
        UserAvatar(imagePath: pengguna.avatar, size: AppSizes.avatarL),
        const SizedBox(height: AppSizes.m),
        Text(
          pengguna.nama,
          textAlign: TextAlign.center,
          style: text.titleLarge,
        ),
        const SizedBox(height: AppSizes.xs),
        Text(
          ProfilStrings.prodiAngkatan(pengguna.prodi, pengguna.angkatan),
          textAlign: TextAlign.center,
          style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: AppSizes.m),
        OutlinedButton.icon(
          onPressed: () => _info(context, ProfilStrings.ubahProfilInfo),
          icon: const Icon(Icons.edit),
          label: const Text(ProfilStrings.ubahProfil),
        ),
      ],
    );
  }

  Widget _kartuStatistik(BuildContext context) {
    return Card(
      shape: _bentukKartu,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.l),
        child: Row(
          children: [
            _kolomStatistik(
              context,
              '${DummyData.sirkelDiikuti.length}',
              ProfilStrings.statSirkel,
            ),
            _pemisah(context),
            _kolomStatistik(
              context,
              ProfilStrings.jumlahJamBelajar,
              ProfilStrings.statJamBelajar,
            ),
            _pemisah(context),
            _kolomStatistik(
              context,
              ProfilStrings.jumlahLencana,
              ProfilStrings.statLencana,
            ),
          ],
        ),
      ),
    );
  }

  // Expanded membagi lebar kartu menjadi 3 kolom sama besar.
  Widget _kolomStatistik(BuildContext context, String nilai, String label) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Expanded(
      child: Column(
        children: [
          Text(nilai, style: text.headlineSmall),
          Text(
            label,
            textAlign: TextAlign.center,
            style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _pemisah(BuildContext context) {
    return Container(
      width: 1,
      height: AppSizes.xxl + AppSizes.s,
      color: Theme.of(context).colorScheme.outlineVariant,
    );
  }

  Widget _bagianLencana(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final daftar = DummyData.lencanaTerbaru;
    // Latar & warna ikon lencana dari tema, berurutan sesuai spesifikasi 15.
    final warna = [
      (scheme.tertiaryContainer, scheme.onTertiaryContainer),
      (scheme.primaryContainer, scheme.onPrimaryContainer),
      (scheme.secondaryContainer, scheme.onSecondaryContainer),
      (scheme.surfaceContainerHighest, scheme.onSurface),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: ProfilStrings.lencanaTerbaru,
          actionLabel: ProfilStrings.semua,
          onAction: () => _info(context, ProfilStrings.semuaLencanaInfo),
        ),
        const SizedBox(height: AppSizes.m),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final (i, item) in daftar.indexed)
              Expanded(
                child: LencanaItem(
                  lencana: item,
                  latar: warna[i % warna.length].$1,
                  warnaIkon: warna[i % warna.length].$2,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _menu(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      shape: _bentukKartu,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.groups),
            title: const Text(ProfilStrings.menuSirkelSaya),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.sirkelSaya),
          ),
          const Divider(indent: AppSizes.m, endIndent: AppSizes.m),
          ListTile(
            leading: const Icon(Icons.school),
            title: const Text(ProfilStrings.menuDaftarMentor),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _info(context, ProfilStrings.daftarMentorInfo),
          ),
          const Divider(indent: AppSizes.m, endIndent: AppSizes.m),
          ListTile(
            leading: const Icon(Icons.logout),
            iconColor: scheme.error,
            textColor: scheme.error,
            title: const Text(ProfilStrings.keluar),
            onTap: () => _keluar(context),
          ),
        ],
      ),
    );
  }
}
