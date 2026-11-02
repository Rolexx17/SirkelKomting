import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/utils/responsive.dart';
import '../../routes/app_routes.dart';
import '../../shared/widgets/app_logo.dart';
import '../../shared/widgets/app_text_field.dart';
import 'auth_strings.dart';
import 'auth_validator.dart';
import 'widgets/auth_form_layout.dart';
import 'widgets/lupa_sandi_sheet.dart';

/// Halaman Masuk: form email kampus + kata sandi dengan validasi, lalu ke MainShell.
class MasukScreen extends StatefulWidget {
  const MasukScreen({super.key});

  @override
  State<MasukScreen> createState() => _MasukScreenState();
}

class _MasukScreenState extends State<MasukScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _sandiController = TextEditingController();

  // Pengenal ketukan khusus untuk kata "Daftar" di RichText.
  late final TapGestureRecognizer _ketukDaftar;

  // Sebelum tombol Masuk ditekan, error tidak ditampilkan; sesudahnya diperbarui saat mengetik.
  AutovalidateMode _modeValidasi = AutovalidateMode.disabled;

  @override
  void initState() {
    super.initState();
    _ketukDaftar = TapGestureRecognizer()..onTap = _keDaftar;
  }

  @override
  void dispose() {
    // Recognizer tidak dibuang otomatis oleh RichText, jadi wajib di-dispose di sini.
    _ketukDaftar.dispose();
    _emailController.dispose();
    _sandiController.dispose();
    super.dispose();
  }

  void _keDaftar() => Navigator.of(context).pushNamed(AppRoutes.daftar);

  void _masuk() {
    // validate() menjalankan validator setiap kolom dan menampilkan pesannya.
    if (!_formKey.currentState!.validate()) {
      setState(() => _modeValidasi = AutovalidateMode.onUserInteraction);
      return;
    }
    // Riwayat dihapus agar tombol kembali di Beranda tidak membuka Masuk lagi.
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.home,
      (route) => false,
    );
  }

  Future<void> _lupaSandi() async {
    // Email yang sudah diketik di form ikut diisikan ke sheet.
    final email = await showLupaSandiSheet(
      context,
      emailAwal: _emailController.text.trim(),
    );
    if (email == null || !mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(AuthStrings.tautanTerkirim(email))),
      );
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
              const SizedBox(height: AppSizes.l),
              // P7: di layar ≥ 840 logo sudah tampil di panel brand (kiri),
              // jadi logo di atas form disembunyikan agar tidak muncul dua kali.
              if (!context.isExpanded) ...const [
                Align(
                  alignment: Alignment.centerLeft,
                  child: AppLogo(),
                ),
                SizedBox(height: AppSizes.xxl),
              ],
              Text(AuthStrings.masukJudul, style: text.headlineSmall),
              const SizedBox(height: AppSizes.s),
              Text(
                AuthStrings.masukSubjudul,
                style: text.bodyLarge?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSizes.xxl),
              AppTextField(
                label: AuthStrings.labelEmail,
                icon: Icons.mail_outline,
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: AuthValidator.email,
              ),
              const SizedBox(height: AppSizes.m),
              AppTextField(
                label: AuthStrings.labelSandi,
                icon: Icons.lock_outline,
                controller: _sandiController,
                obscure: true,
                validator: AuthValidator.kataSandi,
              ),
              const SizedBox(height: AppSizes.s),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _lupaSandi,
                  child: const Text(AuthStrings.lupaSandi),
                ),
              ),
              const SizedBox(height: AppSizes.m),
              FilledButton(
                onPressed: _masuk,
                child: const Text(AuthStrings.masuk),
              ),
            ],
          ),
        ),
        bawah: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.s),
            // P3: RichText = satu paragraf dengan beberapa TextSpan bergaya berbeda.
            // Berbeda dengan Text.rich, RichText tidak mewarisi DefaultTextStyle dan
            // skala teks, jadi gaya dasar dan textScaler diisi manual dari tema.
            child: RichText(
              textAlign: TextAlign.center,
              textScaler: MediaQuery.textScalerOf(context),
              text: TextSpan(
                style: text.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
                children: [
                  const TextSpan(text: AuthStrings.belumPunyaAkun),
                  // Hanya span ini yang punya recognizer, jadi hanya "Daftar" yang bisa diketuk.
                  TextSpan(
                    text: AuthStrings.daftar,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: scheme.primary,
                    ),
                    recognizer: _ketukDaftar,
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
