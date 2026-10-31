import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../beranda_strings.dart';

/// Membuka bottom sheet "Atur mata kuliah". Mengembalikan pilihan baru (urut
/// sesuai [semua]) saat "Simpan" ditekan, atau null bila sheet ditutup begitu saja.
Future<List<String>?> showAturMataKuliahSheet(
  BuildContext context, {
  required List<String> semua,
  required List<String> terpilih,
}) {
  return showModalBottomSheet<List<String>>(
    context: context,
    // Tinggi sheet mengikuti isi dan boleh digulir (aman di landscape 800×360).
    isScrollControlled: true,
    builder: (context) => _AturMataKuliahSheet(semua: semua, terpilih: terpilih),
  );
}

class _AturMataKuliahSheet extends StatefulWidget {
  const _AturMataKuliahSheet({required this.semua, required this.terpilih});

  final List<String> semua;
  final List<String> terpilih;

  @override
  State<_AturMataKuliahSheet> createState() => _AturMataKuliahSheetState();
}

class _AturMataKuliahSheetState extends State<_AturMataKuliahSheet> {
  late final Set<String> _pilihan = widget.terpilih.toSet();

  void _ubah(String mataKuliah, bool pilih) {
    setState(() {
      if (pilih) {
        _pilihan.add(mataKuliah);
      } else {
        _pilihan.remove(mataKuliah);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.pagePadding,
          0,
          AppSizes.pagePadding,
          AppSizes.pagePadding,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(BerandaStrings.aturJudul, style: text.titleLarge),
            const SizedBox(height: AppSizes.xs),
            Text(
              BerandaStrings.aturPesan,
              style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: AppSizes.m),
            // P6: Wrap memindahkan chip ke baris baru bila tidak muat.
            Wrap(
              spacing: AppSizes.s,
              runSpacing: AppSizes.s,
              children: [
                for (final mk in widget.semua)
                  FilterChip(
                    label: Text(mk),
                    selected: _pilihan.contains(mk),
                    onSelected: (pilih) => _ubah(mk, pilih),
                  ),
              ],
            ),
            const SizedBox(height: AppSizes.xl),
            FilledButton(
              // Validasi: minimal satu mata kuliah; tombol nonaktif bila kosong.
              onPressed: _pilihan.isEmpty
                  ? null
                  : () => Navigator.of(context).pop([
                        for (final mk in widget.semua)
                          if (_pilihan.contains(mk)) mk,
                      ]),
              child: const Text(BerandaStrings.simpan),
            ),
          ],
        ),
      ),
    );
  }
}
