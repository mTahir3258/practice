import 'package:flutter/material.dart';
import '../utils/responsive.dart';

class RoundedTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final TextInputType keyboardType;
  final Widget? prefixIcon;

  const RoundedTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.obscure = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);
    return SizedBox(
      height: r.hp(6.5),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          filled: true,
          // fillColor: Colors.grey.shade800,
          hintText: hint,
          prefixIcon: prefixIcon,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 0,
            horizontal: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
        style: TextStyle(fontSize: r.sp(12), color: Colors.green),
      ),
    );
  }
}
