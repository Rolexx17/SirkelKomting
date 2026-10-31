import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../data/dummy/dummy_data.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../auth/auth_strings.dart';
import '../../auth/auth_validator.dart';
import '../profil_strings.dart';

/// Membuka form Ubah profil (nama & prodi). Mengembalikan true bila disimpan.
Future<bool?> showUbahProfilSheet(BuildContext context) {
  return showModalBottomSheet<bool>(
    context: context,
    // isScrollControlled: sheet bisa naik di atas keyboard.
    isScrollControlled: true,
    useSafeArea: true,
    constraints: const BoxConstraints(maxWidth: AppSizes.sheetMaxWidth),
    builder: (_) => const _UbahProfilSheet(),
  );
}

class _UbahProfilSheet extends StatefulWidget {
  const _UbahProfilSheet();

  @override
  State<_UbahProfilSheet> createState() => _UbahProfilSheetState();
}

class _UbahProfilSheetState extends State<_UbahProfilSheet> {
  final _formKey = GlobalKey<FormState>();
  final _namaController =
      TextEditingController(text: DummyData.penggunaAktif.nama);

  // Prodi lama dipakai sebagai pilihan awal hanya bila ada di daftar dropdown.
  String? _prodi = AuthStrings.daftarProdi.contains(DummyData.penggunaAktif.prodi)
      ? DummyData.penggunaAktif.prodi
      : null;
  String? _prodiError;

  @override
  void dispose() {
    _namaController.dispose();
    super.dispose();
  }

  void _simpan() {
    final formValid = _formKey.currentState!.validate();
    // DropdownMenu bukan FormField, jadi divalidasi manual lewat errorText.
    setState(() => _prodiError = _prodi == null ? AuthStrings.prodiWajib : null);
    if (!formValid || _prodi == null) return;

    // mentor tidak dikirim, jadi peran pengguna tidak berubah.
    DummyData.ubahProfil(nama: _namaController.text.trim(), prodi: _prodi!);
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        AppSizes.pagePadding,
        0,
        AppSizes.pagePadding,
        AppSizes.pagePadding + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(ProfilStrings.ubahProfil, style: text.titleLarge),
            const SizedBox(height: AppSizes.l),
            AppTextField(
              label: AuthStrings.labelNama,
              icon: Icons.person,
              controller: _namaController,
              keyboardType: TextInputType.name,
              validator: AuthValidator.nama,
            ),
            const SizedBox(height: AppSizes.m),
            DropdownMenu<String>(
              expandedInsets: EdgeInsets.zero,
              requestFocusOnTap: false,
              label: const Text(AuthStrings.labelProdi),
              leadingIcon: const Icon(Icons.school),
              initialSelection: _prodi,
              errorText: _prodiError,
              onSelected: (nilai) => setState(() {
                _prodi = nilai;
                _prodiError = null;
              }),
              dropdownMenuEntries: [
                for (final prodi in AuthStrings.daftarProdi)
                  DropdownMenuEntry(value: prodi, label: prodi),
              ],
            ),
            const SizedBox(height: AppSizes.l),
            FilledButton(
              onPressed: _simpan,
              child: const Text(ProfilStrings.simpan),
            ),
          ],
        ),
      ),
    );
  }
}
