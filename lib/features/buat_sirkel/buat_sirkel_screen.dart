import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/utils/responsive.dart';
import '../../data/dummy/dummy_data.dart';
import '../../data/models/sirkel.dart';
import '../../routes/app_routes.dart';
import '../../shared/widgets/app_text_field.dart';
import '../../shared/widgets/cover_image.dart';
import 'buat_sirkel_strings.dart';
import 'sampul_picker_sheet.dart';

/// Formulir mentor untuk menerbitkan sirkel baru.
class BuatSirkelScreen extends StatefulWidget {
  const BuatSirkelScreen({super.key});

  @override
  State<BuatSirkelScreen> createState() => _BuatSirkelScreenState();
}

class _BuatSirkelScreenState extends State<BuatSirkelScreen> {
  final _formKey = GlobalKey<FormState>();
  final _judul = TextEditingController();
  final _jam = TextEditingController();

  String? _sampul;
  String? _mataKuliah;
  ModeBelajar _mode = ModeBelajar.online;

  /// Kode hari terpilih, misalnya {'Rab'}.
  final Set<String> _hari = {};
  int _kuota = 6;

  /// true setelah "Terbitkan sirkel" pernah ditekan (untuk menyegarkan pesan validasi).
  bool _sudahKirim = false;

  static const _jamBawaan = TimeOfDay(hour: 16, minute: 0);

  static const _kuotaMin = 2;
  static const _kuotaMaks = 12;
  static const _tinggiSampul = 136.0;
  static const _tinggiSampulLebar = 280.0;
  static const _lebarKuota = 136.0;
  static const _tinggiIlustrasi = 64.0;

  // Validasi jam "HH.MM": jam 00–23, titik, menit 00–59.
  static final _polaJam = RegExp(r'^([01]\d|2[0-3])\.[0-5]\d$');

  @override
  void dispose() {
    _judul.dispose();
    _jam.dispose();
    super.dispose();
  }

  Future<void> _pilihSampul() async {
    final hasil = await showSampulPickerSheet(context, terpilih: _sampul);
    // Cek mounted: layar bisa saja sudah ditutup saat sheet selesai.
    if (hasil != null && mounted) setState(() => _sampul = hasil);
  }

  /// Membuka time picker Material 3 (format 24 jam) dan menulis hasilnya sebagai "HH.MM".
  Future<void> _pilihJam() async {
    final awal = _jamDariTeks(_jam.text) ?? _jamBawaan;
    final hasil = await showTimePicker(
      context: context,
      initialTime: awal,
      helpText: BuatSirkelStrings.pilihJam,
      // Paksa tampilan 24 jam walaupun pengaturan perangkat memakai AM/PM.
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (hasil == null || !mounted) return;

    final jj = hasil.hour.toString().padLeft(2, '0');
    final mm = hasil.minute.toString().padLeft(2, '0');
    setState(() => _jam.text = '$jj.$mm');
    // Bila tombol Terbitkan sudah pernah ditekan, segarkan pesan validasi.
    if (_sudahKirim) _formKey.currentState?.validate();
  }

  /// Teks "HH.MM" di kolom Jam menjadi TimeOfDay; null bila kosong atau formatnya salah.
  TimeOfDay? _jamDariTeks(String teks) {
    if (!_polaJam.hasMatch(teks.trim())) return null;
    final bagian = teks.trim().split('.');
    return TimeOfDay(hour: int.parse(bagian[0]), minute: int.parse(bagian[1]));
  }

  /// Gabungan nama hari terpilih sesuai urutan minggu, misalnya "Senin & Rabu".
  /// Kata pertama tetap nama hari agar fungsi `nomorHari` di fitur Jelajah bisa membacanya.
  String _hariTeks() {
    final nama = [
      for (var i = 0; i < BuatSirkelStrings.kodeHari.length; i++)
        if (_hari.contains(BuatSirkelStrings.kodeHari[i]))
          BuatSirkelStrings.namaHari[i],
    ];
    if (nama.length == 1) return nama.first;
    return '${nama.sublist(0, nama.length - 1).join(', ')} & ${nama.last}';
  }

  void _terbitkan() {
    _sudahKirim = true;
    // validate() menjalankan semua validator: mata kuliah, judul, hari, dan jam.
    if (!_formKey.currentState!.validate()) return;

    final mataKuliah = _mataKuliah!;
    // Bila sampul belum dipilih, pakai sampul bawaan mata kuliah tersebut
    // (urutan daftarMataKuliah sama dengan AppAssets.covers).
    final indeks = DummyData.daftarMataKuliah.indexOf(mataKuliah);
    final sampul = _sampul ?? AppAssets.covers[indeks];

    final id = DummyData.tambahSirkel(
      mataKuliah: mataKuliah,
      judul: _judul.text.trim(),
      mode: _mode,
      hari: _hariTeks(),
      jam: _jam.text.trim(),
      kuota: _kuota,
      cover: sampul,
    );

    // ScaffoldMessenger diambil sebelum pindah layar karena context ini akan dibuang.
    final messenger = ScaffoldMessenger.of(context);
    // Ganti layar Buat Sirkel dengan Detail sirkel baru, sehingga tombol kembali
    // tidak membuka formulir lagi. Id dikirim sebagai argumen route.
    Navigator.pushReplacementNamed(context, AppRoutes.detailSirkel, arguments: id);
    messenger.showSnackBar(
      const SnackBar(content: Text(BuatSirkelStrings.berhasil)),
    );
  }

  @override
  Widget build(BuildContext context) {
    // P7: ≥ 840 px pemilih sampul di kiri dan form di kanan; selain itu satu kolom.
    final lebar = context.isExpanded;

    final form = Form(
      key: _formKey,
      child: lebar
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildSampul(_tinggiSampulLebar)),
                const SizedBox(width: AppSizes.xl),
                Expanded(child: _buildIsiForm()),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSampul(_tinggiSampul),
                const SizedBox(height: AppSizes.l),
                _buildIsiForm(),
              ],
            ),
    );

    return Scaffold(
      appBar: AppBar(title: const Text(BuatSirkelStrings.judulHalaman)),
      body: SafeArea(
        top: false,
        // P6/P7: scroll agar form tetap bisa diisi di landscape 800×360.
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.pagePadding),
          child: Center(
            // P7: satu kolom dibatasi 560 px; dua kolom diberi ruang 2 × 560.
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: lebar
                    ? AppSizes.maxContentWidth * 2
                    : AppSizes.maxContentWidth,
              ),
              child: form,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSampul(double tinggi) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final sampul = _sampul;

    return InkWell(
      onTap: _pilihSampul,
      borderRadius: BorderRadius.circular(AppSizes.radiusM),
      // P5: kotak bergaris putus-putus digambar dengan CustomPainter.
      child: CustomPaint(
        painter: _GarisPutusPainter(
          color: scheme.outline,
          radius: AppSizes.radiusM,
        ),
        child: SizedBox(
          height: tinggi,
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.s),
            child: sampul == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        AppAssets.emptyState,
                        height: _tinggiIlustrasi,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.add_photo_alternate_outlined,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSizes.sm),
                      Text(
                        BuatSirkelStrings.pilihSampul,
                        style: text.titleSmall
                            ?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ],
                  )
                : Tooltip(
                    message: BuatSirkelStrings.gantiSampul,
                    child: CoverImage(path: sampul, radius: AppSizes.radiusS),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildIsiForm() {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // DropdownMenu bukan FormField, jadi dibungkus FormField agar ikut divalidasi Form.
        FormField<String>(
          validator: (_) =>
              _mataKuliah == null ? BuatSirkelStrings.mataKuliahWajib : null,
          builder: (field) => DropdownMenu<String>(
            expandedInsets: EdgeInsets.zero,
            requestFocusOnTap: false,
            label: const Text(BuatSirkelStrings.mataKuliah),
            leadingIcon: const Icon(Icons.menu_book),
            errorText: field.errorText,
            initialSelection: _mataKuliah,
            dropdownMenuEntries: [
              for (final mk in DummyData.daftarMataKuliah)
                DropdownMenuEntry(value: mk, label: mk),
            ],
            onSelected: (mk) {
              setState(() => _mataKuliah = mk);
              field.didChange(mk);
            },
          ),
        ),
        const SizedBox(height: AppSizes.m),
        AppTextField(
          label: BuatSirkelStrings.judulSirkel,
          icon: Icons.edit,
          controller: _judul,
          validator: (v) => (v == null || v.trim().isEmpty)
              ? BuatSirkelStrings.judulWajib
              : null,
        ),
        const SizedBox(height: AppSizes.l),
        Text(BuatSirkelStrings.modeBelajar, style: text.titleSmall),
        const SizedBox(height: AppSizes.s),
        SegmentedButton<ModeBelajar>(
          expandedInsets: EdgeInsets.zero,
          segments: const [
            ButtonSegment(
              value: ModeBelajar.online,
              label: Text(BuatSirkelStrings.online),
            ),
            ButtonSegment(
              value: ModeBelajar.offline,
              label: Text(BuatSirkelStrings.offline),
            ),
          ],
          selected: {_mode},
          onSelectionChanged: (pilihan) => setState(() => _mode = pilihan.first),
        ),
        const SizedBox(height: AppSizes.l),
        Text(BuatSirkelStrings.hari, style: text.titleSmall),
        const SizedBox(height: AppSizes.s),
        // Hari dibungkus FormField agar aturan "minimal satu hari" ikut validate().
        FormField<Set<String>>(
          validator: (_) => _hari.isEmpty ? BuatSirkelStrings.hariWajib : null,
          builder: (field) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // P6: Wrap memindahkan chip ke baris berikutnya bila tidak muat.
              Wrap(
                spacing: AppSizes.s,
                runSpacing: AppSizes.s,
                children: [
                  for (final kode in BuatSirkelStrings.kodeHari)
                    FilterChip(
                      label: Text(kode),
                      selected: _hari.contains(kode),
                      onSelected: (pilih) {
                        setState(() {
                          if (pilih) {
                            _hari.add(kode);
                          } else {
                            _hari.remove(kode);
                          }
                        });
                        field.didChange(_hari);
                      },
                    ),
                ],
              ),
              if (field.hasError)
                Padding(
                  padding: const EdgeInsets.only(
                    top: AppSizes.xs,
                    left: AppSizes.m,
                  ),
                  child: Text(
                    field.errorText!,
                    style: text.bodySmall?.copyWith(color: scheme.error),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.l),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              // AppTextField (milik Richie) tidak diubah: dibungkus dari luar.
              // AbsorbPointer menahan ketukan agar keyboard tidak muncul, lalu
              // GestureDetector di luarnya membuka time picker.
              child: GestureDetector(
                onTap: _pilihJam,
                child: AbsorbPointer(
                  child: AppTextField(
                    label: BuatSirkelStrings.jam,
                    icon: Icons.schedule,
                    controller: _jam,
                    validator: (v) {
                      final isi = v?.trim() ?? '';
                      if (isi.isEmpty) return BuatSirkelStrings.jamWajib;
                      if (!_polaJam.hasMatch(isi)) {
                        return BuatSirkelStrings.jamFormat;
                      }
                      return null;
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSizes.sm),
            SizedBox(width: _lebarKuota, child: _buildKuota()),
          ],
        ),
        const SizedBox(height: AppSizes.xl),
        FilledButton(
          onPressed: _terbitkan,
          child: const Text(BuatSirkelStrings.terbitkan),
        ),
      ],
    );
  }

  /// Stepper kuota (− angka +). Tombol dinonaktifkan (onPressed null) di batas 2 dan 12.
  Widget _buildKuota() {
    return InputDecorator(
      decoration: const InputDecoration(
        labelText: BuatSirkelStrings.kuota,
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSizes.xs,
          vertical: AppSizes.s,
        ),
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: BuatSirkelStrings.kurangiKuota,
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.remove),
            onPressed: _kuota > _kuotaMin ? () => setState(() => _kuota--) : null,
          ),
          Expanded(
            child: Text(
              '$_kuota',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          IconButton(
            tooltip: BuatSirkelStrings.tambahKuota,
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.add),
            onPressed: _kuota < _kuotaMaks ? () => setState(() => _kuota++) : null,
          ),
        ],
      ),
    );
  }
}

/// Menggambar garis tepi putus-putus bersudut bulat. Flutter tidak punya border
/// putus-putus bawaan, jadi garis RRect dipotong-potong dengan `computeMetrics`.
class _GarisPutusPainter extends CustomPainter {
  _GarisPutusPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  static const _tebal = 1.5;
  static const _panjangGaris = 6.0;
  static const _jeda = 4.0;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = _tebal;

    // deflate setengah tebal garis agar garis tidak terpotong di tepi kotak.
    final kotak = (Offset.zero & size).deflate(_tebal / 2);
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(kotak, Radius.circular(radius)));

    for (final metric in path.computeMetrics()) {
      var jarak = 0.0;
      while (jarak < metric.length) {
        canvas.drawPath(metric.extractPath(jarak, jarak + _panjangGaris), paint);
        jarak += _panjangGaris + _jeda;
      }
    }
  }

  @override
  bool shouldRepaint(_GarisPutusPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}
