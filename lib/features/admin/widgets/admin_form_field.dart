import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class AdminFormField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final TextInputType inputType;
  final int maxLines;
  final bool required;
  final String? Function(String?)? validator;

  const AdminFormField({
    super.key,
    required this.ctrl,
    required this.label,
    this.inputType = TextInputType.text,
    this.maxLines = 1,
    this.required = false,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller:  ctrl,
        keyboardType: inputType,
        maxLines:    maxLines,
        style:       AppTextStyles.body(),
        validator:   validator ?? (required
            ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null
            : null),
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}