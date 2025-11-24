import 'package:flutter/material.dart';
import 'package:inward_outward_management/utils/app_colors.dart';

class AppFormField extends StatelessWidget {
  final TextEditingController controller;
  final String? label;
  final bool isNumber;
  final String? hint;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final String? suffixText;

  const AppFormField({
    super.key,
    required this.controller,
    this.label,
    this.isNumber = false,
    this.hint,
    this.validator,
    this.onChanged,
    this.suffixText,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: AppColors.textLight),
      validator: validator,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixText: suffixText,
        suffixStyle: const TextStyle(color: AppColors.textLight),
        labelStyle: const TextStyle(color: AppColors.textLight),
        hintStyle: const TextStyle(color: AppColors.textLight),
        filled: true,
        fillColor: AppColors.greyBackground,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.primaryGreen,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}
