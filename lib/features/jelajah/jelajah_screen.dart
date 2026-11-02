import 'package:flutter/material.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/utils/responsive.dart';
import '../../data/dummy/dummy_data.dart';
import '../../data/models/sirkel.dart';
import '../../routes/app_routes.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/sirkel_card.dart';
import '../buat_sirkel/buka_buat_sirkel.dart';
import '../sirkel/sirkel_strings.dart';
import '../sirkel/sirkel_waktu.dart';
import 'filter_sheet.dart';
import 'jelajah_strings.dart';

/// Menyaring daftar sirkel untuk Jelajah. Dipisah dari widget agar mudah diuji.
///
/// - [kataKunci]: dicocokkan ke mata kuliah atau judul, tidak peka huruf besar/kecil.
/// - [filter]: pilihan dari chip mode dan bottom sheet Filter.
/// - [mingguIni]: hanya sirkel yang punya hari sesi dari hari ini sampai Minggu
///   (memakai semua hari di `daftarNomorHari`), diurutkan dari sesi terdekat.
///   [hariIni] bisa diisi tanggal tetap saat pengujian.
/// - `filter.urutan`: urutan hasil (jadwal terdekat, kursi terbanyak, rating mentor).
///   Bila "Paling sesuai" dan [mingguIni] aktif, hasil diurutkan dari sesi terdekat.
List<Sirkel> saringSirkel(
  List<Sirkel> sumber, {
  String kataKunci = '',
  FilterSirkel filter = const FilterSirkel(),
  bool mingguIni = false,
  DateTime? hariIni,
}) {
  final kunci = kataKunci.trim().toLowerCase();
  final nomorHariIni = (hariIni ?? DateTime.now()).weekday;

  final hasil = sumber.where((s) {
    if (kunci.isNotEmpty &&
        !s.mataKuliah.toLowerCase().contains(kunci) &&
        !s.judul.toLowerCase().contains(kunci)) {
      return false;
    }
    if (mingguIni && !s.daftarNomorHari.any((n) => n >= nomorHariIni)) {
      return false;
    }
    return filter.cocok(s);
  }).toList();

  // Nilai pengurut tiap sirkel: makin kecil, makin atas. null = urutan data apa adanya.
  final int Function(Sirkel)? nilaiUrut = switch (filter.urutan) {
    UrutanSirkel.relevan =>
      mingguIni ? (Sirkel s) => _menitMenujuSesi(s, nomorHariIni) : null,
    UrutanSirkel.terdekat =>
      (Sirkel s) => _menitKeSesiBerikutnya(s, nomorHariIni),
    // Dinegatifkan agar yang terbesar (kursi/rating) berada di atas.
    UrutanSirkel.kursiTerbanyak => (Sirkel s) => -s.sisaKursi,
    UrutanSirkel.ratingMentor =>
      (Sirkel s) => -((s.mentor.rating ?? 0) * 10).round(),
  };
  if (nilaiUrut == null) return hasil;

  // Indeks asal dipakai sebagai penentu terakhir supaya sirkel dengan nilai sama
  // selalu tampil dengan urutan yang sama (List.sort tidak dijamin stabil).
  final urut = [
    for (var i = 0; i < hasil.length; i++)
      (sirkel: hasil[i], nilai: nilaiUrut(hasil[i]), asal: i),
  ]..sort((a, b) => a.nilai != b.nilai
      ? a.nilai.compareTo(b.nilai)
      : a.asal.compareTo(b.asal));
  return [for (final u in urut) u.sirkel];
}

/// Jarak (menit) dari awal hari ini ke sesi berikutnya [s], berputar ke minggu
/// depan bila harinya sudah lewat: selisih hari (0–6) × 1440 + jam mulai.
/// Operator % di Dart selalu positif untuk pembagi positif, jadi Senin dari
/// Kamis = (1 − 4) % 7 = 4 hari lagi.
int _menitKeSesiBerikutnya(Sirkel s, int nomorHariIni) {
  var selisihHari = DateTime.daysPerWeek;
  for (final n in s.daftarNomorHari) {
    final selisih = (n - nomorHariIni) % DateTime.daysPerWeek;
    if (selisih < selisihHari) selisihHari = selisih;
  }
  return selisihHari * Duration.minutesPerDay + (bacaJam(s.jam) ?? 0);
}

/// Jarak (menit) dari awal hari ini ke sesi terdekat [s] di minggu ini:
/// selisih hari × 1440 + jam mulai. Makin kecil, makin dekat.
int _menitMenujuSesi(Sirkel s, int nomorHariIni) {
  var selisihHari = DateTime.daysPerWeek;
  for (final n in s.daftarNomorHari) {
    if (n >= nomorHariIni && n - nomorHariIni < selisihHari) {
      selisihHari = n - nomorHariIni;
    }
  }
  return selisihHari * Duration.minutesPerDay + (bacaJam(s.jam) ?? 0);
}

/// Batas jumlah kata kunci yang disimpan di riwayat pencarian.
const maksRiwayatPencarian = 5;

/// Memperbarui riwayat pencarian dengan [kata] baru:
/// - spasi di awal/akhir dibuang, dan kata kosong diabaikan;
/// - kata yang sama (tidak peka huruf besar/kecil) tidak dobel, tetapi dipindah
///   ke paling atas memakai penulisan terbaru;
/// - hanya [maks] kata terbaru yang disimpan.
List<String> perbaruiRiwayat(
  List<String> lama,
  String kata, {
  int maks = maksRiwayatPencarian,
}) {
  final bersih = kata.trim();
  if (bersih.isEmpty) return List.of(lama);
  final lain = lama.where((k) => k.toLowerCase() != bersih.toLowerCase());
  return [bersih, ...lain].take(maks).toList();
}

/// Tab Jelajah: pencarian, chip filter cepat, filter lengkap, dan daftar/grid sirkel.
class JelajahScreen extends StatefulWidget {
  const JelajahScreen({super.key, this.kataKunciAwal = '', this.hariIni});

  /// Isi awal SearchBar, misalnya saat mata kuliah di Beranda diketuk
  /// (`MainShellState.bukaJelajah`).
  final String kataKunciAwal;

  /// Tanggal acuan chip "Minggu ini". null = hari ini; diisi tanggal tetap saat test.
  final DateTime? hariIni;

  @override
  State<JelajahScreen> createState() => _JelajahScreenState();
}

class _JelajahScreenState extends State<JelajahScreen> {
  final _cari = TextEditingController();
  FilterSirkel _filter = const FilterSirkel();
  bool _mingguIni = false;

  @override
  void initState() {
    super.initState();
    _cari.text = widget.kataKunciAwal;
  }

  @override
  void dispose() {
    _cari.dispose();
    super.dispose();
  }

  // Sumber untuk sheet Filter: sudah tersaring kata kunci & "Minggu ini",
  // sehingga angka "Tampilkan N sirkel" sama dengan hasil yang nanti tampil.
  List<Sirkel> get _sumberFilter => saringSirkel(
        DummyData.semuaSirkel,
        kataKunci: _cari.text,
        mingguIni: _mingguIni,
        hariIni: widget.hariIni,
      );

  Future<void> _bukaFilter() async {
    final hasil = await showFilterSheet(
      context,
      awal: _filter,
      sumber: _sumberFilter,
    );
    // null = sheet ditutup tanpa menekan "Tampilkan", filter tidak berubah.
    if (hasil != null && mounted) setState(() => _filter = hasil);
  }

  // Data bisa berubah setelah kembali (gabung/buat sirkel), jadi daftar dibangun ulang.
  void _buka(String route, {Object? arguments}) {
    Navigator.of(context).pushNamed(route, arguments: arguments).then((_) {
      if (mounted) setState(() {});
    });
  }

  /// FAB Buat Sirkel: form hanya terbuka untuk mentor (diperiksa bukaBuatSirkel).
  /// Grid dibangun ulang setelahnya agar sirkel baru langsung terlihat.
  Future<void> _bukaBuatSirkel() async {
    await bukaBuatSirkel(context);
    if (mounted) setState(() {});
  }

  /// Menyimpan kata kunci saat ini ke riwayat (dipanggil saat Enter ditekan
  /// atau saat kartu hasil pencarian dibuka).
  void _catatPencarian() {
    DummyData.aturRiwayatPencarian(
      perbaruiRiwayat(DummyData.riwayatPencarian, _cari.text),
    );
  }

  /// Mengetuk chip riwayat: kata kunci dipakai lagi dan naik ke paling atas.
  void _pakaiRiwayat(String kata) {
    setState(() {
      _cari.text = kata;
      _catatPencarian();
    });
  }

  void _hapusRiwayat(String kata) {
    setState(() {
      DummyData.aturRiwayatPencarian(
        DummyData.riwayatPencarian.where((k) => k != kata).toList(),
      );
    });
  }

  void _pilihSemua() => setState(() {
        _filter = const FilterSirkel();
        _mingguIni = false;
      });

  void _pilihMode(ModeBelajar mode, bool pilih) =>
      setState(() => _filter = _filter.denganMode(pilih ? mode : null));

  @override
  Widget build(BuildContext context) {
    final hasil = saringSirkel(
      DummyData.semuaSirkel,
      kataKunci: _cari.text,
      filter: _filter,
      mingguIni: _mingguIni,
      hariIni: widget.hariIni,
    );

    // Bila chip "Minggu ini" sendiri sudah membuat hasil kosong (misalnya hari
    // Minggu), tampilkan pesan khusus, bukan pesan pencarian biasa.
    final kosongKarenaMingguIni = _mingguIni &&
        saringSirkel(
          DummyData.semuaSirkel,
          mingguIni: true,
          hariIni: widget.hariIni,
        ).isEmpty;

    // P7: jumlah kolom grid 1 (< 600), 2 (600–839), 3 (≥ 840).
    final kolom = Responsive.columns(context, compact: 1, medium: 2, expanded: 3);
    final compactCard = kolom > 1;

    // P7: tinggi sel grid dihitung dari tinggi sampul + isi kartu, dikali skala
    // teks pengguna, agar kartu tidak terpotong saat ukuran huruf diperbesar.
    final skalaTeks = MediaQuery.textScalerOf(context).scale(AppSizes.m) / AppSizes.m;
    final tinggiKartu =
        (compactCard ? AppSizes.coverCardCompact : AppSizes.coverCard) +
            AppSizes.sirkelCardBody * skalaTeks;

    return Scaffold(
      // Di layar lebar FAB sudah ada di NavigationRail (MainShell), jadi di sini hanya untuk ponsel.
      floatingActionButton: context.isCompact
          ? FloatingActionButton.extended(
              onPressed: _bukaBuatSirkel,
              icon: const Icon(Icons.add),
              label: const Text(JelajahStrings.buatSirkel),
            )
          : null,
      body: SafeArea(
        bottom: false,
        // P6: CustomScrollView agar header, chip, dan grid ikut tergulir bersama
        // (aman di landscape 800×360).
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.pagePadding,
                AppSizes.pagePadding,
                AppSizes.pagePadding,
                AppSizes.m,
              ),
              sliver: SliverToBoxAdapter(child: _buildHeader(context)),
            ),
            // Riwayat hanya tampil saat kolom pencarian kosong.
            if (_cari.text.trim().isEmpty &&
                DummyData.riwayatPencarian.isNotEmpty)
              SliverToBoxAdapter(child: _buildRiwayat(context)),
            SliverToBoxAdapter(child: _buildChips()),
            const SliverToBoxAdapter(child: SizedBox(height: AppSizes.m)),
            if (hasil.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.pagePadding),
                  child: kosongKarenaMingguIni
                      ? const EmptyState(
                          title: JelajahStrings.kosongMingguIniJudul,
                          message: JelajahStrings.kosongMingguIniPesan,
                        )
                      : const EmptyState(
                          title: JelajahStrings.kosongJudul,
                          message: JelajahStrings.kosongPesan,
                        ),
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  AppSizes.pagePadding,
                  0,
                  AppSizes.pagePadding,
                  context.isCompact ? AppSizes.fabSpace : AppSizes.pagePadding,
                ),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: kolom,
                    mainAxisSpacing: AppSizes.m,
                    crossAxisSpacing: AppSizes.m,
                    mainAxisExtent: tinggiKartu,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => SirkelCard(
                      sirkel: hasil[i],
                      compact: compactCard,
                      // Kirim id sebagai argumen route; Detail mengambil datanya sendiri.
                      onTap: () {
                        // Kata kunci yang berhasil menemukan sirkel ikut dicatat.
                        _catatPencarian();
                        _buka(AppRoutes.detailSirkel, arguments: hasil[i].id);
                      },
                    ),
                    childCount: hasil.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final judul = Text(
      JelajahStrings.judul,
      style: Theme.of(context).textTheme.titleLarge,
    );
    final cari = SearchBar(
      controller: _cari,
      hintText: JelajahStrings.cariHint,
      leading: const Icon(Icons.search),
      trailing: [
        IconButton(
          tooltip: JelajahStrings.tooltipFilter,
          icon: const Icon(Icons.tune),
          onPressed: _bukaFilter,
        ),
      ],
      // Pencarian langsung: setiap ketikan membangun ulang daftar.
      onChanged: (_) => setState(() {}),
      onSubmitted: (_) => setState(_catatPencarian),
    );

    // P7: di layar lebar judul dan SearchBar sejajar (mockup 16_tablet).
    if (!context.isCompact) {
      return Row(
        children: [
          Expanded(child: judul),
          const SizedBox(width: AppSizes.l),
          Expanded(child: cari),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        judul,
        const SizedBox(height: AppSizes.m),
        cari,
      ],
    );
  }

  /// Deretan InputChip riwayat pencarian: ketuk untuk mencari lagi, × untuk menghapus.
  Widget _buildRiwayat(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.pagePadding,
        0,
        AppSizes.pagePadding,
        AppSizes.m,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            JelajahStrings.riwayatJudul,
            style: text.labelLarge?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: AppSizes.s),
          Wrap(
            spacing: AppSizes.s,
            runSpacing: AppSizes.s,
            children: [
              for (final kata in DummyData.riwayatPencarian)
                InputChip(
                  label: Text(kata),
                  onPressed: () => _pakaiRiwayat(kata),
                  onDeleted: () => _hapusRiwayat(kata),
                  deleteButtonTooltipMessage: JelajahStrings.hapusRiwayat,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChips() {
    final semua = !_filter.aktif && !_mingguIni;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.pagePadding),
      child: Row(
        spacing: AppSizes.s,
        children: [
          FilterChip(
            label: const Text(JelajahStrings.chipSemua),
            selected: semua,
            onSelected: (_) => _pilihSemua(),
          ),
          FilterChip(
            avatar: const Icon(Icons.videocam),
            label: const Text(SirkelStrings.online),
            selected: _filter.mode == ModeBelajar.online,
            onSelected: (v) => _pilihMode(ModeBelajar.online, v),
          ),
          FilterChip(
            avatar: const Icon(Icons.place),
            label: const Text(SirkelStrings.offline),
            selected: _filter.mode == ModeBelajar.offline,
            onSelected: (v) => _pilihMode(ModeBelajar.offline, v),
          ),
          FilterChip(
            avatar: const Icon(Icons.calendar_today_outlined),
            label: const Text(JelajahStrings.chipMingguIni),
            selected: _mingguIni,
            onSelected: (v) => setState(() => _mingguIni = v),
          ),
        ],
      ),
    );
  }
}
