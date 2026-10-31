import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/utils/responsive.dart';
import '../../data/dummy/dummy_data.dart';
import '../../data/models/sesi.dart';
import '../../data/models/sirkel.dart';
import '../../routes/app_routes.dart';
import '../../shared/widgets/cover_image.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/sirkel_card.dart';
import '../../shared/widgets/user_avatar.dart';
import '../notifikasi/notifikasi_screen.dart';
import '../shell/main_shell.dart';
import '../sirkel_saya/jadwal_util.dart';
import 'beranda_strings.dart';
import 'widgets/atur_mata_kuliah_sheet.dart';
import 'widgets/hari_ini_card.dart';

/// Tab Beranda: sapaan, kartu sesi berikutnya, carousel mata kuliah, jadwal
/// terdekat (layar lebar), dan rekomendasi sirkel. Navigasi bawah dipegang MainShell.
class BerandaScreen extends StatefulWidget {
  const BerandaScreen({super.key});

  /// Sapaan sesuai jam: pagi (04–10), siang (11–14), sore (15–17), malam (18–03).
  static String sapaan(int jam) {
    if (jam >= 4 && jam < 11) return BerandaStrings.pagi;
    if (jam >= 11 && jam < 15) return BerandaStrings.siang;
    if (jam >= 15 && jam < 18) return BerandaStrings.sore;
    return BerandaStrings.malam;
  }

  /// Label kartu sesi: "HARI INI" (hari yang sama), "BESOK" (selisih 1 hari),
  /// selebihnya nama hari + tanggal, misalnya "KAMIS, 5 NOV".
  static String labelSesi(DateTime waktu, DateTime sekarang) {
    final selisih = selisihHari(sekarang, waktu);
    if (selisih == 0) return BerandaStrings.hariIni;
    if (selisih == 1) return BerandaStrings.besok;
    return BerandaStrings.labelTanggal(namaHariDari(waktu), tanggalSingkat(waktu));
  }

  @override
  State<BerandaScreen> createState() => _BerandaScreenState();
}

class _BerandaScreenState extends State<BerandaScreen> {
  static const _jumlahMataKuliahAwal = 4;
  static const _maksRekomendasi = 3;
  static const _maksJadwalTerdekat = 3;

  // Ukuran item carousel mata kuliah.
  static const _lebarItemMk = 140.0;
  static const _lebarItemMinMk = 100.0;
  static const _tinggiSampulMk = 84.0;
  static const _radiusSampulMk = 14.0;

  /// Tinggi satu baris nama mata kuliah (bodyMedium 14/20).
  static const _tinggiNamaMk = 20.0;
  static const _ukuranSampulJadwal = 44.0;

  /// Mata kuliah yang tampil di carousel; diubah lewat sheet "Atur".
  List<String> _mataKuliah =
      DummyData.daftarMataKuliah.take(_jumlahMataKuliahAwal).toList();

  Future<void> _buka(String route, {Object? arguments}) async {
    await Navigator.of(context).pushNamed(route, arguments: arguments);
    // Data bisa berubah setelah kembali (misalnya gabung sirkel), jadi Beranda dibangun ulang.
    if (mounted) setState(() {});
  }

  Future<void> _bukaNotifikasi() async {
    final hasil = await Navigator.of(context).pushNamed(AppRoutes.notifikasi);
    if (!mounted) return;
    // Badge membaca ulang DummyData.adaNotifikasiBaru, jadi titiknya hilang
    // setelah semua notifikasi ditandai dibaca.
    setState(() {});
    // Notifikasi lencana menutup layar dengan hasil "profil" → pindah ke tab Profil.
    if (hasil == NotifikasiScreen.hasilBukaProfil) {
      MainShell.maybeOf(context)?.pindahTab(MainShell.tabProfil);
    }
  }

  Future<void> _aturMataKuliah() async {
    final hasil = await showAturMataKuliahSheet(
      context,
      semua: DummyData.daftarMataKuliah,
      terpilih: _mataKuliah,
    );
    if (hasil == null || !mounted) return;
    setState(() => _mataKuliah = hasil);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text(BerandaStrings.aturTersimpan)),
      );
  }

  /// Sampul mata kuliah: urutan daftarMataKuliah sama dengan AppAssets.covers.
  String _sampul(String mataKuliah) {
    final i = DummyData.daftarMataKuliah.indexOf(mataKuliah);
    return i >= 0 && i < AppAssets.covers.length
        ? AppAssets.covers[i]
        : AppAssets.emptyState;
  }

  @override
  Widget build(BuildContext context) {
    // Jadwal dihitung sekali per build dari waktu sekarang (data milik Ethan).
    final sekarang = DateTime.now();
    final daftarSesi = DummyData.jadwalSesi;
    final sesi = sesiTerdekat(daftarSesi, sekarang);
    final sirkelSesi = sesi == null ? null : DummyData.cariSirkel(sesi.sirkelId);
    final sesiBerikutnya = daftarSesi
        .where((s) => !identical(s, sesi))
        .take(_maksJadwalTerdekat)
        .toList();

    return SafeArea(
      bottom: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // P7: yang dibaca lebar area konten (constraints), bukan lebar layar,
          // karena di layar lebar sebagian lebar sudah dipakai NavigationRail.
          final ukuran = Responsive.fromWidth(constraints.maxWidth);

          final kartuSesi = sesi != null && sirkelSesi != null
              ? HariIniCard(
                  sirkel: sirkelSesi,
                  sesi: sesi,
                  label: BerandaScreen.labelSesi(sesi.waktu, sekarang),
                  onMasukSesi: () => _buka(AppRoutes.sirkelSaya),
                )
              : null;

          final kiri = <Widget>[
            if (kartuSesi != null) ...[
              kartuSesi,
              const SizedBox(height: AppSizes.xl),
            ],
            _carouselMataKuliah(context),
            // P7: ≥ 840 kolom kiri diisi "Jadwal terdekat" agar tidak ada ruang kosong.
            if (ukuran == WindowSize.expanded && sesiBerikutnya.isNotEmpty) ...[
              const SizedBox(height: AppSizes.xl),
              _jadwalTerdekat(context, sesiBerikutnya),
            ],
          ];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.pagePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _header(context),
                const SizedBox(height: AppSizes.xl),
                // P7: ≥ 840 dua kolom (kiri: sesi, mata kuliah, jadwal; kanan: rekomendasi).
                if (ukuran == WindowSize.expanded)
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
                      Expanded(child: _rekomendasi(context, kolom: 1)),
                    ],
                  )
                else ...[
                  ...kiri,
                  const SizedBox(height: AppSizes.xl),
                  // P7: 600–839 rekomendasi 2 kolom; < 600 satu kolom.
                  _rekomendasi(
                    context,
                    kolom: ukuran == WindowSize.medium ? 2 : 1,
                  ),
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
          onPressed: _bukaNotifikasi,
          // P3: Badge titik tampil hanya bila masih ada notifikasi belum dibaca.
          icon: Badge(
            isLabelVisible: DummyData.adaNotifikasiBaru,
            child: const Icon(Icons.notifications_outlined),
          ),
        ),
      ],
    );
  }

  Widget _carouselMataKuliah(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    // P7: tinggi carousel ikut skala teks pengguna agar nama mata kuliah tidak terpotong.
    // Tinggi = sampul + nama + padding teks (atas-bawah) + padding bawaan item CarouselView (4 + 4).
    final tinggiNama = MediaQuery.textScalerOf(context).scale(_tinggiNamaMk);
    final tinggiCarousel =
        _tinggiSampulMk + tinggiNama + AppSizes.s * 2 + AppSizes.xs * 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: BerandaStrings.mataKuliahmu,
          actionLabel: BerandaStrings.atur,
          onAction: _aturMataKuliah,
        ),
        const SizedBox(height: AppSizes.s),
        SizedBox(
          height: tinggiCarousel,
          // P6: CarouselView Material 3. Berbeda dengan ListView horizontal, item di
          // tepi mengecil sampai shrinkExtent saat digeser, setiap item sudah
          // berbentuk kartu yang bisa diketuk (onTap), dan efek riak disediakan otomatis.
          child: CarouselView(
            itemExtent: _lebarItemMk,
            shrinkExtent: _lebarItemMinMk,
            backgroundColor: scheme.surfaceContainerLow,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_radiusSampulMk),
            ),
            onTap: (i) => MainShell.maybeOf(context)
                ?.bukaJelajah(kataKunci: _mataKuliah[i]),
            children: [
              for (final mk in _mataKuliah)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: CoverImage(path: _sampul(mk), radius: 0)),
                    Padding(
                      padding: const EdgeInsets.all(AppSizes.s),
                      child: Text(
                        mk,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.bodyMedium,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _jadwalTerdekat(BuildContext context, List<Sesi> daftar) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: BerandaStrings.jadwalTerdekat,
          actionLabel: BerandaStrings.lihatSemua,
          onAction: () => _buka(AppRoutes.sirkelSaya),
        ),
        const SizedBox(height: AppSizes.s),
        for (final sesi in daftar) _barisJadwal(context, sesi),
      ],
    );
  }

  Widget _barisJadwal(BuildContext context, Sesi sesi) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final sirkel = DummyData.cariSirkel(sesi.sirkelId);
    if (sirkel == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.s),
      child: _kartuJadwal(context, sesi, sirkel, scheme, text),
    );
  }

  Widget _kartuJadwal(
    BuildContext context,
    Sesi sesi,
    Sirkel sirkel,
    ColorScheme scheme,
    TextTheme text,
  ) {
    return Card(
      child: InkWell(
        onTap: () => _buka(AppRoutes.detailSirkel, arguments: sirkel.id),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.sm),
          child: Row(
            children: [
              CoverImage(
                path: sirkel.cover,
                width: _ukuranSampulJadwal,
                height: _ukuranSampulJadwal,
                radius: AppSizes.sm,
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sirkel.mataKuliah,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.titleSmall,
                    ),
                    Text(
                      BerandaStrings.jadwalRingkas(
                        namaHariDari(sesi.waktu),
                        tanggalSingkat(sesi.waktu),
                        jamDari(sesi.waktu),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.bodySmall
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }

  Widget _rekomendasi(BuildContext context, {required int kolom}) {
    // Rekomendasi = sirkel yang belum diikuti pengguna, paling banyak 3.
    var daftar = DummyData.semuaSirkel
        .where((s) => !DummyData.sudahGabung(s.id))
        .take(_maksRekomendasi)
        .toList();
    // Di grid 2 kolom jumlah kartu dibuat genap agar baris terakhir tidak bolong.
    if (kolom == 2 && daftar.length > 1 && daftar.length.isOdd) {
      daftar = daftar.take(daftar.length - 1).toList();
    }

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
        // P6 + P7: kartu disusun per baris berisi [kolom] kartu (Row + Expanded),
        // sehingga tinggi baris mengikuti isi kartu dan tidak bisa overflow.
        for (var i = 0; i < daftar.length; i += kolom)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.m),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var j = i; j < i + kolom; j++) ...[
                  if (j > i) const SizedBox(width: AppSizes.m),
                  Expanded(
                    child: j < daftar.length
                        ? SirkelCard(
                            sirkel: daftar[j],
                            compact: kolom > 1,
                            // Navigasi dengan argumen: hanya id yang dikirim ke Detail Sirkel.
                            onTap: () => _buka(
                              AppRoutes.detailSirkel,
                              arguments: daftar[j].id,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}
