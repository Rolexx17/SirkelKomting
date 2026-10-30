import 'package:flutter/material.dart';

/// Kolom isian outlined (Material 3) dengan label dan ikon di depan.
/// Jika [obscure] bernilai true, isi disembunyikan dan muncul tombol mata.
/// Dipakai di Masuk, Daftar, dan Buat Sirkel.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.label,
    required this.icon,
    this.controller,
    this.obscure = false,
    this.validator,
    this.keyboardType,
  });

  final String label;
  final IconData icon;
  final TextEditingController? controller;
  final bool obscure;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _tersembunyi;

  @override
  void initState() {
    super.initState();
    _tersembunyi = widget.obscure;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      obscureText: _tersembunyi,
      autocorrect: !widget.obscure,
      enableSuggestions: !widget.obscure,
      // Bentuk garis, warna, dan pesan error merah diambil dari inputDecorationTheme.
      decoration: InputDecoration(
        labelText: widget.label,
        prefixIcon: Icon(widget.icon),
        // Tombol mata hanya untuk kolom rahasia; setState menukar tampil/sembunyi.
        suffixIcon: widget.obscure
            ? IconButton(
                icon: Icon(
                  _tersembunyi ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () => setState(() => _tersembunyi = !_tersembunyi),
              )
            : null,
      ),
    );
  }
}
