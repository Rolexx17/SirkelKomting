import 'package:flutter/material.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/utils/responsive.dart';
import '../../data/dummy/dummy_data.dart';
import '../../data/models/app_user.dart';
import '../../routes/app_routes.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/user_avatar.dart';
import 'lencana_progres.dart';
import 'profil_strings.dart';
import 'simpanan_screen.dart';
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
    if (!ya || !mounted) return;
    // Status peserta → menunggu; DummyData juga menambah notifikasi jenis mentor.
    DummyData.ajukanMentor();
    setState(() {});
    _info(ProfilStrings.pengajuanTerkirim);
  }

  Future<void> _bukaSimpanan() async {
    // SimpananScreen tidak punya route di AppRoutes, jadi dibuka lewat MaterialPageRoute.
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const SimpananScreen()),
    );
    // Jumlah di Badge bisa berubah bila ada item yang batal disimpan.
    if (mounted) setState(() {});
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
            // Lencana dihitung sekali per build dari data terbaru (gabung, simpan,
            // status mentor), lalu dipakai kartu statistik dan bagian lencana.
            final progres = progresLencanaSaatIni();
            final statistik = _kartuStatistik(progres);
            final lencana = _bagianLencana(progres);

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
    final statusMentor = DummyData.statusMentor;
    // switch expression: satu status → satu pasangan label & ikon.
    final (labelPeran, ikonPeran) = switch (statusMentor) {
      StatusMentor.peserta => (ProfilStrings.peranPeserta, Icons.person),
      StatusMentor.menunggu => (ProfilStrings.peranMenunggu, Icons.hourglass_top),
      StatusMentor.mentor => (ProfilStrings.peranMentor, Icons.school),
    };

    return Column(
      children: [
        // Akun baru (avatar kosong) tampil sebagai inisial nama.
        UserAvatar(
          imagePath: pengguna.avatar,
          size: AppSizes.avatarL,
          nama: pengguna.nama,
        ),
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
        // P4: Chip kecil sebagai label peran (bukan tombol), mengikuti status mentor.
        Chip(
          avatar: Icon(ikonPeran),
          label: Text(labelPeran),
          backgroundColor: statusMentor == StatusMentor.menunggu
              ? scheme.tertiaryContainer
              : scheme.secondaryContainer,
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

  Widget _kartuStatistik(List<ProgresLencana> progres) {
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
              '${progres.where((p) => p.didapat).length}',
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

  /// Empat lencana teratas: yang sudah didapat lebih dulu, lalu yang paling
  /// dekat tercapai. Ketuk lencana untuk melihat syarat dan progresnya.
  Widget _bagianLencana(List<ProgresLencana> progres) {
    final scheme = Theme.of(context).colorScheme;
    final daftar = progres.take(_jumlahLencanaDitampilkan).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: ProfilStrings.lencanaJudul,
          actionLabel: ProfilStrings.semua,
          onAction: _bukaSemuaLencana,
        ),
        const SizedBox(height: AppSizes.m),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final (i, item) in daftar.indexed)
              Expanded(
                child: LencanaItem(
                  progres: item,
                  latar: LencanaItem.warnaKe(scheme, i).$1,
                  warnaIkon: LencanaItem.warnaKe(scheme, i).$2,
                  onTap: () => showDetailLencanaSheet(
                    context,
                    progres: item,
                    latar: LencanaItem.warnaKe(scheme, i).$1,
                    warnaIkon: LencanaItem.warnaKe(scheme, i).$2,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  static const _jumlahLencanaDitampilkan = 4;

  Future<void> _bukaSemuaLencana() => showSemuaLencanaSheet(context);

  Widget _menu() {
    final scheme = Theme.of(context).colorScheme;
    final jumlahSimpanan =
        DummyData.sirkelTersimpan.length + DummyData.materiTersimpan.length;

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
          ListTile(
            leading: const Icon(Icons.bookmarks_outlined),
            title: const Text(ProfilStrings.menuSimpanan),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // P4: Badge jumlah item tersimpan; disembunyikan bila 0.
                Badge.count(
                  count: jumlahSimpanan,
                  isLabelVisible: jumlahSimpanan > 0,
                ),
                const SizedBox(width: AppSizes.s),
                const Icon(Icons.chevron_right),
              ],
            ),
            onTap: _bukaSimpanan,
          ),
          const Divider(indent: AppSizes.m, endIndent: AppSizes.m),
          _menuMentor(scheme),
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

  /// Menu mentor berubah sesuai status: hanya peserta yang bisa mengajukan;
  /// status menunggu dan mentor tampil sebagai teks tanpa onTap.
  Widget _menuMentor(ColorScheme scheme) {
    return switch (DummyData.statusMentor) {
      StatusMentor.peserta => ListTile(
          leading: const Icon(Icons.school),
          title: const Text(ProfilStrings.menuDaftarMentor),
          trailing: const Icon(Icons.chevron_right),
          onTap: _daftarMentor,
        ),
      StatusMentor.menunggu => ListTile(
          leading: Icon(Icons.hourglass_top, color: scheme.tertiary),
          title: const Text(ProfilStrings.mentorDitinjau),
          subtitle: const Text(ProfilStrings.mentorDitinjauSub),
        ),
      StatusMentor.mentor => ListTile(
          leading: Icon(Icons.verified, color: scheme.primary),
          title: const Text(ProfilStrings.sudahMentor),
        ),
    };
  }
}
