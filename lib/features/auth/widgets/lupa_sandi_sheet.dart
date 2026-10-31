import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../auth_strings.dart';
import '../auth_validator.dart';

/// Membuka bottom sheet "Atur ulang kata sandi". Mengembalikan email yang valid
/// bila tombol Kirim tautan ditekan, atau null bila sheet ditutup.
Future<String?> showLupaSandiSheet(BuildContext context, {String emailAwal = ''}) {
  return showModalBottomSheet<String>(
    context: context,
    // isScrollControlled: sheet boleh naik lebih tinggi agar tidak tertutup keyboard.
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _LupaSandiSheet(emailAwal: emailAwal),
  );
}

class _LupaSandiSheet extends StatefulWidget {
  const _LupaSandiSheet({required this.emailAwal});

  final String emailAwal;

  @override
  State<_LupaSandiSheet> createState() => _LupaSandiSheetState();
}

class _LupaSandiSheetState extends State<_LupaSandiSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _emailController = TextEditingController(text: widget.emailAwal);

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _kirim() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(_emailController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return SingleChildScrollView(
      // Padding bawah setinggi keyboard, supaya kolom email tetap terlihat.
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
            Text(AuthStrings.lupaSandiJudul, style: text.titleLarge),
            const SizedBox(height: AppSizes.s),
            Text(
              AuthStrings.lupaSandiPesan,
              style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: AppSizes.l),
            AppTextField(
              label: AuthStrings.labelEmail,
              icon: Icons.mail_outline,
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              validator: AuthValidator.email,
            ),
            const SizedBox(height: AppSizes.l),
            FilledButton(
              onPressed: _kirim,
              child: const Text(AuthStrings.kirimTautan),
            ),
          ],
        ),
      ),
    );
  }
}
