import 'package:flutter/material.dart';

class RoundedProgressBar extends StatelessWidget {
  final double progress; // 0..1
  final double height;
  final EdgeInsetsGeometry margin;

  const RoundedProgressBar({
    super.key,
    required this.progress,
    this.height = 8,
    this.margin = const EdgeInsets.symmetric(horizontal: 24.0),
  });

  @override
  Widget build(BuildContext context) {
    final clamped = progress.clamp(0.0, 1.0);
    return Container(
      margin: margin,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade700,
        borderRadius: BorderRadius.circular(20),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: clamped,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}
