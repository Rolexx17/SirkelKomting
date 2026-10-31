import 'package:flutter/material.dart';

import '../../core/constants/app_sizes.dart';
import '../../data/dummy/dummy_data.dart';
import '../../data/models/sirkel.dart';
import '../../shared/widgets/cover_image.dart';
import '../../shared/widgets/info_row.dart';
import '../../shared/widgets/mode_badge.dart';
import '../../shared/widgets/section_header.dart';
import '../../routes/app_routes.dart';
import '../../shared/widgets/user_avatar.dart';
import 'anggota_sheet.dart';
import 'gabung_dialog.dart';
import 'sirkel_strings.dart';
import 'sirkel_waktu.dart';

/// Layar Detail Sirkel. Id sirkel dikirim lewat argumen route `/detail-sirkel`
/// (atau lewat [sirkelId]), lalu datanya diambil dengan `DummyData.cariSirkel`.
class DetailSirkelScreen extends StatefulWidget {
  const DetailSirkelScreen({super.key, this.sirkelId});

  /// Opsional; bila null, id dibaca dari `ModalRoute.settings.arguments`.
  final String? sirkelId;

  @override
  State<DetailSirkelScreen> createState() => _DetailSirkelScreenState();
}

class _DetailSirkelScreenState extends State<DetailSirkelScreen> {
  String? get _id {
    final arg = ModalRoute.of(context)?.settings.arguments;
    return widget.sirkelId ?? (arg is String ? arg : null);
  }

  void _snack(String pesan) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(pesan)));
  }

  Future<void> _gabung(Sirkel sirkel) async {
    // Gabung mengubah data di memori: Nadia masuk anggota & sirkelDiikuti, kursi berkurang.
    DummyData.gabung(sirkel.id);
    setState(() {});
    await showGabungDialog(context, DummyData.cariSirkel(sirkel.id) ?? sirkel);
  }

  // Status simpan disimpan di DummyData, jadi tetap sama saat Detail dibuka lagi.
  void _toggleSimpan(String id) {
    DummyData.toggleSimpanSirkel(id);
    setState(() {});
    _snack(
      DummyData.sirkelDisimpan(id)
          ? SirkelStrings.disimpan
          : SirkelStrings.dihapusDariSimpanan,
    );
  }

  @override
  Widget build(BuildContext context) {
    final id = _id;
    final sirkel = id == null ? null : DummyData.cariSirkel(id);
    if (sirkel == null) return const _TidakDitemukan();

    final sudahGabung = DummyData.sudahGabung(sirkel.id);
    final mentorSendiri = DummyData.adalahMentorSirkel(sirkel.id);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(
              sirkel: sirkel,
              disimpan: DummyData.sirkelDisimpan(sirkel.id),
              onSimpan: () => _toggleSimpan(sirkel.id),
            ),
            // P7: di layar lebar konten dibatasi 560 px dan ditengahkan,
            // sedangkan header di atas tetap selebar layar.
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppSizes.maxContentWidth,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.pagePadding),
                  child: _Konten(
                    sirkel: sirkel,
                    sudahGabung: sudahGabung,
                    mentorSendiri: mentorSendiri,
                    onLihatAnggota: () => showAnggotaSheet(context, sirkel),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _BarBawah(
        sirkel: sirkel,
        sudahGabung: sudahGabung,
        mentorSendiri: mentorSendiri,
        onGabung: () => _gabung(sirkel),
      ),
    );
  }
}

/// Header: sampul (220 px, 140 px di landscape) dengan tombol kembali & bookmark.
class _Header extends StatelessWidget {
  const _Header({
    required this.sirkel,
    required this.disimpan,
    required this.onSimpan,
  });

  final Sirkel sirkel;
  final bool disimpan;
  final VoidCallback onSimpan;

  @override
  Widget build(BuildContext context) {
    // P7: di HP landscape (tinggi ±360 px) header dipendekkan agar tidak
    // memakan lebih dari setengah layar.
    final landscape =
        MediaQuery.orientationOf(context) == Orientation.landscape;
    final tinggi =
        landscape ? AppSizes.detailHeaderLandscape : AppSizes.detailHeader;

    // P6: Stack menumpuk tombol di atas gambar sampul.
    return SizedBox(
      height: tinggi,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CoverImage(
            path: sirkel.cover,
            width: double.infinity,
            height: tinggi,
            radius: 0,
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.sm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TombolBulat(
                    icon: Icons.arrow_back,
                    tooltip: SirkelStrings.kembali,
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  _TombolBulat(
                    icon: disimpan ? Icons.bookmark : Icons.bookmark_border,
                    tooltip: disimpan
                        ? SirkelStrings.hapusSimpanan
                        : SirkelStrings.simpan,
                    onPressed: onSimpan,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TombolBulat extends StatelessWidget {
  const _TombolBulat({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // P5: Container bulat berlatar surface 90% agar ikon terbaca di atas gambar.
    return Container(
      width: AppSizes.circleButton,
      height: AppSizes.circleButton,
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.9),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        tooltip: tooltip,
        icon: Icon(icon, color: scheme.onSurface),
        onPressed: onPressed,
      ),
    );
  }
}

class _Konten extends StatelessWidget {
  const _Konten({
    required this.sirkel,
    required this.sudahGabung,
    required this.mentorSendiri,
    required this.onLihatAnggota,
  });

  final Sirkel sirkel;
  final bool sudahGabung;
  final bool mentorSendiri;
  final VoidCallback onLihatAnggota;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final online = sirkel.mode == ModeBelajar.online;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          sirkel.mataKuliah.toUpperCase(),
          style: text.labelMedium?.copyWith(color: scheme.primary),
        ),
        const SizedBox(height: AppSizes.xs),
        Text(sirkel.judul, style: text.headlineSmall),
        const SizedBox(height: AppSizes.sm),
        Wrap(
          spacing: AppSizes.s,
          runSpacing: AppSizes.s,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ModeBadge(mode: sirkel.mode),
            Chip(
              avatar: const Icon(Icons.school_outlined),
              label: Text(sirkel.level),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.l),
        _KartuMentor(sirkel: sirkel),
        const SizedBox(height: AppSizes.xl),
        Text(SirkelStrings.tentang, style: text.titleMedium),
        const SizedBox(height: AppSizes.s),
        Text(
          sirkel.deskripsi,
          style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: AppSizes.l),
        // P5: Container bergaris sudut 16 sebagai kotak informasi.
        Container(
          padding: const EdgeInsets.all(AppSizes.m),
          decoration: BoxDecoration(
            border: Border.all(color: scheme.outlineVariant),
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
          ),
          child: Column(
            children: [
              InfoRow(
                icon: Icons.calendar_today_outlined,
                label: SirkelStrings.jadwal,
                value: SirkelStrings.jadwalLengkap(
                  sirkel.hari,
                  sirkel.jam,
                  jamSelesai(sirkel.jam),
                ),
              ),
              const SizedBox(height: AppSizes.m),
              InfoRow(
                icon: online ? Icons.videocam : Icons.place,
                label: SirkelStrings.lokasi,
                value: sirkel.lokasi,
                subtitle: _keteranganLokasi(online),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.xl),
        SectionHeader(
          title: SirkelStrings.anggota(sirkel.anggota.length, sirkel.kuota),
          actionLabel: SirkelStrings.lihat,
          onAction: onLihatAnggota,
        ),
        const SizedBox(height: AppSizes.sm),
        if (sirkel.anggota.isEmpty)
          Text(
            SirkelStrings.belumAdaAnggota,
            style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
        // P6: Wrap agar avatar anggota pindah baris otomatis bila tidak muat.
        Wrap(
          spacing: AppSizes.m,
          runSpacing: AppSizes.m,
          children: [
            for (final a in sirkel.anggota)
              SizedBox(
                width: AppSizes.avatarAnggota + AppSizes.m,
                child: Column(
                  children: [
                    UserAvatar(
                      imagePath: a.avatar,
                      size: AppSizes.avatarAnggota,
                    ),
                    const SizedBox(height: AppSizes.xs),
                    Text(
                      a.nama.split(' ').first,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: text.bodySmall,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }

  // Keterangan tautan hanya untuk sirkel online; isinya mengikuti peran pengguna.
  String? _keteranganLokasi(bool online) {
    if (!online) return null;
    if (mentorSendiri) return SirkelStrings.tautanUntukMentor;
    return sudahGabung
        ? SirkelStrings.tautanDariMentor
        : SirkelStrings.tautanSetelahGabung;
  }
}

class _KartuMentor extends StatelessWidget {
  const _KartuMentor({required this.sirkel});

  final Sirkel sirkel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final mentor = sirkel.mentor;
    final rating = mentor.rating;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.m),
        child: Row(
          children: [
            UserAvatar(imagePath: mentor.avatar, size: AppSizes.avatarM),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(mentor.nama, style: text.titleSmall),
                  Text(
                    SirkelStrings.mentorProdi(mentor.prodi, mentor.angkatan),
                    style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            if (rating != null) ...[
              const SizedBox(width: AppSizes.s),
              Icon(Icons.star, size: AppSizes.l, color: scheme.tertiary),
              const SizedBox(width: AppSizes.xs),
              // Format desimal Indonesia: 4.9 → "4,9".
              Text(
                rating.toStringAsFixed(1).replaceAll('.', ','),
                style: text.titleSmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Bar bawah tetap: sisa kursi + tombol Gabung, atau info mentor + "Lihat jadwal"
/// bila pengguna adalah mentor sirkel ini.
class _BarBawah extends StatelessWidget {
  const _BarBawah({
    required this.sirkel,
    required this.sudahGabung,
    required this.mentorSendiri,
    required this.onGabung,
  });

  final Sirkel sirkel;
  final bool sudahGabung;
  final bool mentorSendiri;
  final VoidCallback onGabung;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    // Tombol hanya aktif bila belum bergabung dan masih ada kursi.
    final bisaGabung = !sudahGabung && !sirkel.penuh;

    return Container(
      color: scheme.surfaceContainer,
      child: SafeArea(
        top: false,
        // P7: isi bar ikut dibatasi 560 px; heightFactor 1 agar tinggi bar mengikuti isinya.
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppSizes.maxContentWidth,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.pagePadding,
                vertical: AppSizes.sm,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mentorSendiri
                              ? SirkelStrings.kamuMentor
                              : SirkelStrings.kuota,
                          style: text.bodySmall
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                        Text(
                          sirkel.penuh
                              ? SirkelStrings.kursiPenuh
                              : SirkelStrings.kursiTersisa(sirkel.sisaKursi),
                          style: text.titleMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSizes.m),
                  // Mentor tidak perlu bergabung ke sirkelnya sendiri.
                  if (mentorSendiri)
                    OutlinedButton(
                      onPressed: () =>
                          Navigator.of(context).pushNamed(AppRoutes.sirkelSaya),
                      child: const Text(SirkelStrings.lihatJadwal),
                    )
                  else
                    FilledButton(
                      onPressed: bisaGabung ? onGabung : null,
                      child: Text(
                        sudahGabung
                            ? SirkelStrings.sudahGabung
                            : SirkelStrings.gabung,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Ditampilkan bila id sirkel kosong atau tidak ada di data.
class _TidakDitemukan extends StatelessWidget {
  const _TidakDitemukan();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.pagePadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                SirkelStrings.tidakDitemukan,
                textAlign: TextAlign.center,
                style: text.titleMedium,
              ),
              const SizedBox(height: AppSizes.s),
              Text(
                SirkelStrings.tidakDitemukanPesan,
                textAlign: TextAlign.center,
                style: text.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
