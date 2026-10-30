import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/utils/responsive.dart';
import '../../data/dummy/dummy_data.dart';
import '../../routes/app_routes.dart';
import '../../shared/widgets/cover_image.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/sirkel_card.dart';
import '../../shared/widgets/user_avatar.dart';
import '../shell/main_shell.dart';
import '../sirkel_saya/jadwal_util.dart';
import 'beranda_strings.dart';
import 'widgets/hari_ini_card.dart';

/// Tab Beranda: sapaan, kartu sesi hari ini, mata kuliah, dan rekomendasi sirkel.
/// Tanpa navigasi bawah karena dipegang MainShell.
class BerandaScreen extends StatefulWidget {
  const BerandaScreen({super.key});

  /// Sapaan sesuai jam: pagi (04–10), siang (11–14), sore (15–17), malam (18–03).
  static String sapaan(int jam) {
    if (jam >= 4 && jam < 11) return BerandaStrings.pagi;
    if (jam >= 11 && jam < 15) return BerandaStrings.siang;
    if (jam >= 15 && jam < 18) return BerandaStrings.sore;
    return BerandaStrings.malam;
  }

  @override
  State<BerandaScreen> createState() => _BerandaScreenState();
}

class _BerandaScreenState extends State<BerandaScreen> {
  static const _jumlahMataKuliah = 4;
  static const _maksRekomendasi = 3;
  static const _lebarSampulMk = 92.0;
  static const _tinggiSampulMk = 68.0;
  static const _radiusSampulMk = 14.0;

  /// Tinggi satu baris nama mata kuliah (bodyMedium 14/20).
  static const _tinggiNamaMk = 20.0;

  Future<void> _buka(String route, {Object? arguments}) async {
    await Navigator.of(context).pushNamed(route, arguments: arguments);
    // Data bisa berubah setelah kembali (misalnya gabung sirkel), jadi Beranda dibangun ulang.
    if (mounted) setState(() {});
  }

  void _info(String pesan) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(pesan)));
  }

  @override
  Widget build(BuildContext context) {
    final sesi = sesiTerdekat(DummyData.jadwalSesi, DateTime.now());
    final sirkelHariIni = sesi == null ? null : DummyData.cariSirkel(sesi.sirkelId);

    final kiri = <Widget>[
      if (sirkelHariIni != null) ...[
        HariIniCard(
          sirkel: sirkelHariIni,
          onMasukSesi: () => _buka(AppRoutes.sirkelSaya),
        ),
        const SizedBox(height: AppSizes.xl),
      ],
      _mataKuliah(context),
    ];
    final rekomendasi = _rekomendasi(context);

    return SafeArea(
      bottom: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // P7: yang dibaca lebar area konten (constraints), bukan lebar layar,
          // karena di layar lebar sebagian lebar sudah dipakai NavigationRail.
          final duaKolom = Responsive.fromWidth(constraints.maxWidth) ==
              WindowSize.expanded;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.pagePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _header(context),
                const SizedBox(height: AppSizes.xl),
                // P7: ≥ 840 dua kolom (kiri: Hari ini + mata kuliah, kanan: rekomendasi).
                if (duaKolom)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: kiri,
                        ),
                      ),
                      const SizedBox(width: AppSizes.xl),
                      Expanded(child: rekomendasi),
                    ],
                  )
                else ...[
                  ...kiri,
                  const SizedBox(height: AppSizes.xl),
                  rekomendasi,
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _header(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final pengguna = DummyData.penggunaAktif;
    final namaDepan = pengguna.nama.split(' ').first;
    final adaBelumDibaca = DummyData.notifikasi.any((n) => n.belumDibaca);

    return Row(
      children: [
        UserAvatar(imagePath: pengguna.avatar, size: AppSizes.avatarM),
        const SizedBox(width: AppSizes.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                BerandaScreen.sapaan(DateTime.now().hour),
                style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
              Text(
                namaDepan,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: text.titleLarge,
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: BerandaStrings.tooltipNotifikasi,
          onPressed: () => _buka(AppRoutes.notifikasi),
          // P3: Badge titik menandai ada notifikasi yang belum dibaca.
          icon: Badge(
            isLabelVisible: adaBelumDibaca,
            child: const Icon(Icons.notifications_outlined),
          ),
        ),
      ],
    );
  }

  Widget _mataKuliah(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final daftar = DummyData.daftarMataKuliah.take(_jumlahMataKuliah).toList();

    // P7: tinggi daftar ikut skala teks pengguna agar nama mata kuliah tidak terpotong.
    final tinggiNama = MediaQuery.textScalerOf(context).scale(_tinggiNamaMk);
    final tinggiDaftar = _tinggiSampulMk + AppSizes.s + tinggiNama + AppSizes.xs;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: BerandaStrings.mataKuliahmu,
          actionLabel: BerandaStrings.atur,
          onAction: () => _info(BerandaStrings.aturInfo),
        ),
        const SizedBox(height: AppSizes.s),
        SizedBox(
          height: tinggiDaftar,
          // P6: ListView horizontal untuk daftar yang digeser ke samping.
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: daftar.length,
            separatorBuilder: (context, i) => const SizedBox(width: AppSizes.sm),
            itemBuilder: (context, i) => SizedBox(
              width: _lebarSampulMk,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Urutan daftarMataKuliah sama dengan AppAssets.covers,
                  // jadi indeks mata kuliah = indeks sampulnya.
                  CoverImage(
                    path: AppAssets.covers[i],
                    width: _lebarSampulMk,
                    height: _tinggiSampulMk,
                    radius: _radiusSampulMk,
                  ),
                  const SizedBox(height: AppSizes.s),
                  Text(
                    daftar[i],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _rekomendasi(BuildContext context) {
    // Rekomendasi = sirkel yang belum diikuti Nadia, paling banyak 3.
    final daftar = DummyData.semuaSirkel
        .where((s) => !DummyData.sudahGabung(s.id))
        .take(_maksRekomendasi)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: BerandaStrings.rekomendasi,
          actionLabel: BerandaStrings.lihatSemua,
          // Pindah tab lewat state MainShell, bukan pushNamed, agar navigasi bawah tetap ada.
          onAction: () =>
              MainShell.maybeOf(context)?.pindahTab(MainShell.tabJelajah),
        ),
        const SizedBox(height: AppSizes.s),
        for (final sirkel in daftar)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.m),
            child: SirkelCard(
              sirkel: sirkel,
              // Navigasi dengan argumen: hanya id yang dikirim ke Detail Sirkel.
              onTap: () => _buka(AppRoutes.detailSirkel, arguments: sirkel.id),
            ),
          ),
      ],
    );
  }
}
