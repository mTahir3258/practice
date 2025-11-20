import 'package:flutter/material.dart';
import '../utils/responsive.dart';
import '../utils/app_colors.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool loading;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onTap,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);
    return SizedBox(
      width: double.infinity,
      height: r.hp(6.5),
      child: ElevatedButton(
        onPressed: loading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: loading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                label,
                style: TextStyle(fontSize: r.sp(12), color: AppColors.textDark),
              ),
      ),
    );
  }
}
