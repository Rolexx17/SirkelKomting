import 'package:flutter/material.dart';

import '../../core/constants/app_sizes.dart';
import '../../data/dummy/dummy_data.dart';
import '../../routes/app_routes.dart';
import '../../shared/widgets/app_text_field.dart';
import 'auth_strings.dart';
import 'auth_validator.dart';
import 'widgets/auth_form_layout.dart';

enum _Peran { peserta, mentor }

/// Halaman Daftar: nama, email, program studi, kata sandi, peran, dan persetujuan.
class DaftarScreen extends StatefulWidget {
  const DaftarScreen({super.key});

  @override
  State<DaftarScreen> createState() => _DaftarScreenState();
}

class _DaftarScreenState extends State<DaftarScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _sandiController = TextEditingController();

  String? _prodi;
  String? _prodiError;
  _Peran _peran = _Peran.peserta;
  bool _setuju = false;
  AutovalidateMode _modeValidasi = AutovalidateMode.disabled;

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _sandiController.dispose();
    super.dispose();
  }

  void _pilihProdi(String? nilai) {
    setState(() {
      _prodi = nilai;
      _prodiError = null;
    });
  }

  void _buatAkun() {
    final formValid = _formKey.currentState!.validate();
    // DropdownMenu bukan FormField, jadi program studi divalidasi manual lewat errorText.
    setState(() {
      _prodiError = _prodi == null ? AuthStrings.prodiWajib : null;
      _modeValidasi = AutovalidateMode.onUserInteraction;
    });
    if (!formValid || _prodi == null) return;

    // Data pendaftaran disimpan sebagai pengguna aktif, sehingga Beranda dan Profil
    // langsung menampilkan nama dan prodi yang baru. akunBaru: avatar dikosongkan,
    // jadi UserAvatar menampilkan inisial, bukan foto Nadia.
    DummyData.ubahProfil(
      nama: _namaController.text.trim(),
      prodi: _prodi!,
      mentor: false,
      akunBaru: true,
    );
    // Memilih Mentor tidak langsung menjadi mentor: sama seperti "Daftar jadi mentor"
    // di Profil, statusnya menjadi "menunggu" (sedang ditinjau) + notifikasi mentor.
    if (_peran == _Peran.mentor) DummyData.ajukanMentor();

    // Messenger diambil sebelum pindah halaman; SnackBar tetap tampil di MainShell.
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.home,
      (route) => false,
    );
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text(AuthStrings.akunDibuat)));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      body: AuthFormLayout(
        isi: Form(
          key: _formKey,
          autovalidateMode: _modeValidasi,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Tombol kembali ada di dalam form (bukan AppBar) supaya ikut
              // berada di panel kanan saat tampilan dua panel di layar lebar.
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  tooltip: AuthStrings.kembali,
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ),
              const SizedBox(height: AppSizes.s),
              Text(AuthStrings.daftarJudul, style: text.headlineSmall),
              const SizedBox(height: AppSizes.s),
              Text(
                AuthStrings.daftarSubjudul,
                style: text.bodyLarge?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSizes.xl),
              AppTextField(
                label: AuthStrings.labelNama,
                icon: Icons.person,
                controller: _namaController,
                keyboardType: TextInputType.name,
                validator: AuthValidator.nama,
              ),
              const SizedBox(height: AppSizes.m),
              AppTextField(
                label: AuthStrings.labelEmail,
                icon: Icons.mail_outline,
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: AuthValidator.email,
              ),
              const SizedBox(height: AppSizes.m),
              DropdownMenu<String>(
                expandedInsets: EdgeInsets.zero,
                requestFocusOnTap: false,
                label: const Text(AuthStrings.labelProdi),
                leadingIcon: const Icon(Icons.school),
                initialSelection: _prodi,
                errorText: _prodiError,
                onSelected: _pilihProdi,
                dropdownMenuEntries: [
                  for (final prodi in AuthStrings.daftarProdi)
                    DropdownMenuEntry(value: prodi, label: prodi),
                ],
              ),
              const SizedBox(height: AppSizes.m),
              AppTextField(
                label: AuthStrings.labelSandi,
                icon: Icons.lock_outline,
                controller: _sandiController,
                obscure: true,
                validator: AuthValidator.kataSandi,
              ),
              const SizedBox(height: AppSizes.l),
              Text(
                AuthStrings.daftarSebagai,
                style: text.titleSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSizes.s),
              // Lebar penuh: Column stretch memberi lebar tetap, segmen dibagi rata.
              SegmentedButton<_Peran>(
                segments: const [
                  ButtonSegment(
                    value: _Peran.peserta,
                    label: Text(AuthStrings.peserta),
                  ),
                  ButtonSegment(
                    value: _Peran.mentor,
                    label: Text(AuthStrings.mentor),
                  ),
                ],
                selected: {_peran},
                onSelectionChanged: (pilihan) =>
                    setState(() => _peran = pilihan.first),
              ),
              const SizedBox(height: AppSizes.s),
              InkWell(
                onTap: () => setState(() => _setuju = !_setuju),
                borderRadius: const BorderRadius.all(
                  Radius.circular(AppSizes.radiusS),
                ),
                child: Row(
                  children: [
                    Checkbox(
                      value: _setuju,
                      onChanged: (nilai) =>
                          setState(() => _setuju = nilai ?? false),
                    ),
                    Expanded(
                      child: Text(
                        AuthStrings.setuju,
                        style: text.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // onPressed null = tombol nonaktif sampai checkbox persetujuan dicentang.
        bawah: FilledButton(
          onPressed: _setuju ? _buatAkun : null,
          child: const Text(AuthStrings.buatAkun),
        ),
      ),
    );
  }
}
