import 'package:flutter/material.dart';
import '../utils/responsive.dart';

class AppLogo extends StatelessWidget {
  final double diameterPercent; // percent of width, e.g., 24
  final String assetPath;
  const AppLogo({
    super.key,
    required this.assetPath,
    this.diameterPercent = 24,
  });

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);
    final size = r.wp(diameterPercent);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.12),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Image.asset(
          'assets/images/logo.jpg',
          width: size * 0.55,
          height: size * 0.55,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
