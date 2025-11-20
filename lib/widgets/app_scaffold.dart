import 'package:flutter/material.dart';
import 'package:inward_outward_management/utils/app_colors.dart';

class AppScaffold extends StatelessWidget {
  final String? title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final bool? resizeToAvoidBottomInset;

  const AppScaffold({
    super.key,
    this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
    this.resizeToAvoidBottomInset,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar: title == null
          ? null
          : AppBar(
              title: Text(title!),
              backgroundColor: AppColors.primaryDark,
              foregroundColor: AppColors.textLight,
              elevation: 0,
              actions: actions,
            ),
      floatingActionButton: floatingActionButton,
      body: body,
    );
  }
}
