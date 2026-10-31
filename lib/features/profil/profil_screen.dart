import 'package:flutter/material.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/utils/responsive.dart';
import '../../data/dummy/dummy_data.dart';
import '../../routes/app_routes.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/user_avatar.dart';
import 'profil_strings.dart';
import 'widgets/lencana_item.dart';
import 'widgets/semua_lencana_sheet.dart';
import 'widgets/ubah_profil_sheet.dart';

/// Tab Profil: identitas, statistik belajar, lencana terbaru, dan menu akun.
/// Navigasi bawah tidak dibuat di sini karena dipegang MainShell.
class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  static const _bentukKartu = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(AppSizes.radiusL)),
  );

  void _info(String pesan) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(pesan)));
  }

  /// Dialog konfirmasi umum; true bila tombol [labelYa] ditekan.
  Future<bool> _konfirmasi({
    required String judul,
    required String isi,
    required String labelYa,
    bool bahaya = false,
  }) async {
    final scheme = Theme.of(context).colorScheme;
    final hasil = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(judul),
        content: Text(isi),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text(ProfilStrings.batal),
          ),
          TextButton(
            // Aksi berbahaya (Keluar) memakai warna error dari tema.
            style: bahaya
                ? TextButton.styleFrom(foregroundColor: scheme.error)
                : null,
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(labelYa),
          ),
        ],
      ),
    );
    // Dialog ditutup dengan tap di luar → null, dianggap batal.
    return hasil ?? false;
  }

  Future<void> _ubahProfil() async {
    final disimpan = await showUbahProfilSheet(context);
    if (disimpan != true || !mounted) return;
    // DummyData sudah berubah; setState membangun ulang layar dengan data baru.
    setState(() {});
    _info(ProfilStrings.profilDiperbarui);
  }

  Future<void> _bukaSirkelSaya() async {
    await Navigator.of(context).pushNamed(AppRoutes.sirkelSaya);
    // Jumlah sirkel bisa berubah selama di Sirkel Saya, jadi statistik dibaca ulang.
    if (mounted) setState(() {});
  }

  Future<void> _daftarMentor() async {
    final ya = await _konfirmasi(
      judul: ProfilStrings.daftarMentorJudul,
      isi: ProfilStrings.daftarMentorIsi,
      labelYa: ProfilStrings.ajukan,
    );
    if (ya && mounted) _info(ProfilStrings.pengajuanTerkirim);
  }

  Future<void> _keluar() async {
    final ya = await _konfirmasi(
      judul: ProfilStrings.keluarJudul,
      isi: ProfilStrings.keluarIsi,
      labelYa: ProfilStrings.keluar,
      bahaya: true,
    );
    if (!ya || !mounted) return;
    // pushNamedAndRemoveUntil menghapus seluruh riwayat, jadi tombol kembali di
    // Masuk tidak bisa membuka Profil lagi setelah keluar.
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
            // P7: statistik dan lencana bersebelahan bila lebar ≥ 600 ATAU layar
            // landscape. Di HP landscape tingginya pendek, jadi lebih hemat ditaruh
            // berdampingan daripada ditumpuk.
            final landscape =
                MediaQuery.orientationOf(context) == Orientation.landscape;
            final berdampingan = landscape ||
                constraints.maxWidth >= Responsive.mediumBreakpoint;
            final statistik = _kartuStatistik();
            final lencana = _bagianLencana();

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
                      _kepala(),
                      const SizedBox(height: AppSizes.xl),
                      if (berdampingan)
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
                      _menu(),
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

  Widget _kepala() {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    // Dibaca ulang setiap build, jadi perubahan dari Daftar/Ubah profil langsung tampil.
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
        const SizedBox(height: AppSizes.s),
        // P4: Chip kecil sebagai label peran (bukan tombol).
        Chip(
          avatar: Icon(pengguna.isMentor ? Icons.school : Icons.person),
          label: Text(
            pengguna.isMentor
                ? ProfilStrings.peranMentor
                : ProfilStrings.peranPeserta,
          ),
          backgroundColor: scheme.secondaryContainer,
          side: BorderSide.none,
          visualDensity: VisualDensity.compact,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        const SizedBox(height: AppSizes.m),
        OutlinedButton.icon(
          onPressed: _ubahProfil,
          icon: const Icon(Icons.edit),
          label: const Text(ProfilStrings.ubahProfil),
        ),
      ],
    );
  }

  Widget _kartuStatistik() {
    return Card(
      shape: _bentukKartu,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.l),
        child: Row(
          children: [
            _kolomStatistik(
              '${DummyData.sirkelDiikuti.length}',
              ProfilStrings.statSirkel,
            ),
            _pemisah(),
            _kolomStatistik(
              '${DummyData.jumlahJamBelajar}',
              ProfilStrings.statJamBelajar,
            ),
            _pemisah(),
            _kolomStatistik(
              '${DummyData.semuaLencana.length}',
              ProfilStrings.statLencana,
            ),
          ],
        ),
      ),
    );
  }

  // Expanded membagi lebar kartu menjadi 3 kolom sama besar.
  Widget _kolomStatistik(String nilai, String label) {
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

  Widget _pemisah() {
    return Container(
      width: 1,
      height: AppSizes.xxl + AppSizes.s,
      color: Theme.of(context).colorScheme.outlineVariant,
    );
  }

  Widget _bagianLencana() {
    final scheme = Theme.of(context).colorScheme;
    final daftar = DummyData.lencanaTerbaru;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: ProfilStrings.lencanaTerbaru,
          actionLabel: ProfilStrings.semua,
          onAction: () => showSemuaLencanaSheet(context),
        ),
        const SizedBox(height: AppSizes.m),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final (i, item) in daftar.indexed)
              Expanded(
                child: LencanaItem(
                  lencana: item,
                  latar: LencanaItem.warnaKe(scheme, i).$1,
                  warnaIkon: LencanaItem.warnaKe(scheme, i).$2,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _menu() {
    final scheme = Theme.of(context).colorScheme;
    final sudahMentor = DummyData.penggunaAktif.isMentor;

    return Card(
      shape: _bentukKartu,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.groups),
            title: const Text(ProfilStrings.menuSirkelSaya),
            trailing: const Icon(Icons.chevron_right),
            onTap: _bukaSirkelSaya,
          ),
          const Divider(indent: AppSizes.m, endIndent: AppSizes.m),
          // Mentor tidak perlu mendaftar lagi: menu diganti teks tanpa onTap.
          if (sudahMentor)
            ListTile(
              leading: Icon(Icons.verified, color: scheme.primary),
              title: const Text(ProfilStrings.sudahMentor),
            )
          else
            ListTile(
              leading: const Icon(Icons.school),
              title: const Text(ProfilStrings.menuDaftarMentor),
              trailing: const Icon(Icons.chevron_right),
              onTap: _daftarMentor,
            ),
          const Divider(indent: AppSizes.m, endIndent: AppSizes.m),
          ListTile(
            leading: const Icon(Icons.logout),
            iconColor: scheme.error,
            textColor: scheme.error,
            title: const Text(ProfilStrings.keluar),
            onTap: _keluar,
          ),
        ],
      ),
    );
  }
}
