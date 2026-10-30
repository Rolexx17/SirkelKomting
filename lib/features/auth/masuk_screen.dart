import 'package:flutter/material.dart';

import '../../core/constants/app_sizes.dart';
import '../../routes/app_routes.dart';
import '../../shared/widgets/app_logo.dart';
import '../../shared/widgets/app_text_field.dart';
import 'auth_strings.dart';
import 'auth_validator.dart';
import 'widgets/auth_form_layout.dart';

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

  // Sebelum tombol Masuk ditekan, error tidak ditampilkan; sesudahnya diperbarui saat mengetik.
  AutovalidateMode _modeValidasi = AutovalidateMode.disabled;

  @override
  void dispose() {
    _emailController.dispose();
    _sandiController.dispose();
    super.dispose();
  }

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

  void _lupaSandi() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text(AuthStrings.lupaSandiInfo)));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: AuthFormLayout(
          isi: Form(
            key: _formKey,
            autovalidateMode: _modeValidasi,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSizes.l),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: AppLogo(),
                ),
                const SizedBox(height: AppSizes.xxl),
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
            child: InkWell(
              onTap: () => Navigator.of(context).pushNamed(AppRoutes.daftar),
              borderRadius: const BorderRadius.all(
                Radius.circular(AppSizes.radiusS),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.s),
                // Text.rich: satu kalimat dengan dua gaya; "Daftar" tebal berwarna primary.
                child: Text.rich(
                  TextSpan(
                    text: AuthStrings.belumPunyaAkun,
                    style: text.bodyLarge?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                    children: [
                      TextSpan(
                        text: AuthStrings.daftar,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: scheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
