import 'package:flutter/material.dart';

import '../../core/constants/app_sizes.dart';
import '../../data/dummy/dummy_data.dart';
import '../../data/models/sirkel.dart';
import '../sirkel/sirkel_strings.dart';
import '../sirkel/sirkel_waktu.dart';
import 'jelajah_strings.dart';

/// Pilihan urutan hasil Jelajah. [relevan] = urutan bawaan data (sirkel yang baru
/// diterbitkan di atas), kecuali chip "Minggu ini" aktif yang mengurutkan dari sesi terdekat.
enum UrutanSirkel { relevan, terdekat, kursiTerbanyak, ratingMentor }

/// Pilihan filter sirkel. Kosong/null berarti "tidak menyaring" untuk bagian itu.
class FilterSirkel {
  const FilterSirkel({
    this.mataKuliah = const {},
    this.mode,
    this.hari = const {},
    this.hanyaAdaKursi = false,
    this.urutan = UrutanSirkel.relevan,
  });

  final Set<String> mataKuliah;
  final ModeBelajar? mode;

  /// Kode hari, misalnya {'Kam', 'Sab'} (lihat [JelajahStrings.daftarHari]).
  final Set<String> hari;
  final bool hanyaAdaKursi;

  /// Urutan hasil; bukan penyaring, jadi tidak dihitung di [aktif].
  final UrutanSirkel urutan;

  bool get aktif =>
      mataKuliah.isNotEmpty || mode != null || hari.isNotEmpty || hanyaAdaKursi;

  /// Salinan dengan mode baru (null = semua mode). Dipakai chip Online/Offline di Jelajah.
  FilterSirkel denganMode(ModeBelajar? modeBaru) => FilterSirkel(
        mataKuliah: mataKuliah,
        mode: modeBaru,
        hari: hari,
        hanyaAdaKursi: hanyaAdaKursi,
        urutan: urutan,
      );

  /// true bila [s] lolos semua syarat filter. Syarat yang kosong dilewati.
  bool cocok(Sirkel s) {
    if (mataKuliah.isNotEmpty && !mataKuliah.contains(s.mataKuliah)) return false;
    if (mode != null && s.mode != mode) return false;
    // Semua hari sirkel ikut dicocokkan, jadi "Senin & Rabu" lolos filter Sen maupun Rab.
    if (hari.isNotEmpty &&
        !hari.any((h) => s.daftarNomorHari.contains(nomorHari(h)))) {
      return false;
    }
    if (hanyaAdaKursi && s.penuh) return false;
    return true;
  }
}

/// Membuka bottom sheet Filter. Mengembalikan filter baru bila "Tampilkan" ditekan,
/// atau null bila sheet ditutup (geser ke bawah / ketuk di luar) sehingga filter tidak berubah.
Future<FilterSirkel?> showFilterSheet(
  BuildContext context, {
  required FilterSirkel awal,
  required List<Sirkel> sumber,
}) {
  return showModalBottomSheet<FilterSirkel>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    // P7: di layar lebar sheet tidak melebar penuh, maksimum 640 px.
    constraints: const BoxConstraints(maxWidth: AppSizes.sheetMaxWidth),
    builder: (_) => _FilterSheet(awal: awal, sumber: sumber),
  );
}

enum _PilihanMode { semua, online, offline }

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({required this.awal, required this.sumber});

  final FilterSirkel awal;
  final List<Sirkel> sumber;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late Set<String> _mataKuliah;
  late _PilihanMode _mode;
  late Set<String> _hari;
  late bool _hanyaAdaKursi;
  late UrutanSirkel _urutan;

  @override
  void initState() {
    super.initState();
    // Salin pilihan awal agar perubahan di sheet tidak langsung mengubah Jelajah.
    _mataKuliah = {...widget.awal.mataKuliah};
    _hari = {...widget.awal.hari};
    _hanyaAdaKursi = widget.awal.hanyaAdaKursi;
    _urutan = widget.awal.urutan;
    _mode = switch (widget.awal.mode) {
      ModeBelajar.online => _PilihanMode.online,
      ModeBelajar.offline => _PilihanMode.offline,
      null => _PilihanMode.semua,
    };
  }

  FilterSirkel get _filter => FilterSirkel(
        mataKuliah: _mataKuliah,
        mode: switch (_mode) {
          _PilihanMode.online => ModeBelajar.online,
          _PilihanMode.offline => ModeBelajar.offline,
          _PilihanMode.semua => null,
        },
        hari: _hari,
        hanyaAdaKursi: _hanyaAdaKursi,
        urutan: _urutan,
      );

  void _reset() {
    setState(() {
      _mataKuliah = {};
      _mode = _PilihanMode.semua;
      _hari = {};
      _hanyaAdaKursi = false;
      _urutan = UrutanSirkel.relevan;
    });
  }

  void _ubahSet(Set<String> set, String nilai, bool pilih) {
    setState(() {
      if (pilih) {
        set.add(nilai);
      } else {
        set.remove(nilai);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final labelStyle = text.titleSmall?.copyWith(color: scheme.onSurfaceVariant);

    // N dihitung ulang setiap setState, jadi angka di tombol selalu terbaru.
    final jumlah = widget.sumber.where(_filter.cocok).length;

    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Flexible + scroll: isi sheet tetap bisa digulir di landscape,
          // sedangkan tombol di bawah selalu terlihat.
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.pagePadding,
                0,
                AppSizes.pagePadding,
                AppSizes.m,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(JelajahStrings.filterJudul, style: text.titleLarge),
                  const SizedBox(height: AppSizes.l),
                  Text(JelajahStrings.urutkan, style: labelStyle),
                  const SizedBox(height: AppSizes.s),
                  // ChoiceChip: hanya satu urutan yang bisa dipilih.
                  Wrap(
                    spacing: AppSizes.s,
                    runSpacing: AppSizes.s,
                    children: [
                      for (final u in UrutanSirkel.values)
                        ChoiceChip(
                          label: Text(JelajahStrings.labelUrutan(u)),
                          selected: _urutan == u,
                          onSelected: (_) => setState(() => _urutan = u),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.l),
                  Text(JelajahStrings.mataKuliah, style: labelStyle),
                  const SizedBox(height: AppSizes.s),
                  Wrap(
                    spacing: AppSizes.s,
                    runSpacing: AppSizes.s,
                    children: [
                      for (final mk in DummyData.daftarMataKuliah)
                        FilterChip(
                          label: Text(mk),
                          selected: _mataKuliah.contains(mk),
                          onSelected: (v) => _ubahSet(_mataKuliah, mk, v),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.l),
                  Text(JelajahStrings.modeBelajar, style: labelStyle),
                  const SizedBox(height: AppSizes.s),
                  SegmentedButton<_PilihanMode>(
                    expandedInsets: EdgeInsets.zero,
                    segments: const [
                      ButtonSegment(
                        value: _PilihanMode.semua,
                        label: Text(JelajahStrings.modeSemua),
                      ),
                      ButtonSegment(
                        value: _PilihanMode.online,
                        label: Text(SirkelStrings.online),
                      ),
                      ButtonSegment(
                        value: _PilihanMode.offline,
                        label: Text(SirkelStrings.offline),
                      ),
                    ],
                    selected: {_mode},
                    onSelectionChanged: (pilihan) =>
                        setState(() => _mode = pilihan.first),
                  ),
                  const SizedBox(height: AppSizes.l),
                  Text(JelajahStrings.hari, style: labelStyle),
                  const SizedBox(height: AppSizes.s),
                  Wrap(
                    spacing: AppSizes.s,
                    runSpacing: AppSizes.s,
                    children: [
                      for (final h in JelajahStrings.daftarHari)
                        FilterChip(
                          label: Text(h),
                          selected: _hari.contains(h),
                          onSelected: (v) => _ubahSet(_hari, h, v),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.l),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              JelajahStrings.hanyaAdaKursi,
                              style: text.bodyLarge,
                            ),
                            Text(
                              JelajahStrings.hanyaAdaKursiSub,
                              style: text.bodySmall
                                  ?.copyWith(color: scheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSizes.m),
                      Switch(
                        value: _hanyaAdaKursi,
                        onChanged: (v) => setState(() => _hanyaAdaKursi = v),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.pagePadding,
              AppSizes.s,
              AppSizes.pagePadding,
              AppSizes.pagePadding,
            ),
            child: Row(
              children: [
                OutlinedButton(
                  onPressed: _reset,
                  child: const Text(JelajahStrings.reset),
                ),
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(_filter),
                    child: Text(JelajahStrings.tampilkan(jumlah)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
