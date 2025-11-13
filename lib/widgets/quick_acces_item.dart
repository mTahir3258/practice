// lib/widgets/quick_access_item.dart
import 'package:flutter/material.dart';
import '../utils/responsive.dart';

class QuickAccessItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  const QuickAccessItem({
    super.key,
    required this.icon,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);
    return ListTile(
      tileColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      leading: CircleAvatar(
        backgroundColor: Colors.grey.shade200,
        child: Icon(icon, color: Colors.black54),
      ),
      title: Text(title),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(
        vertical: r.hp(1),
        horizontal: r.wp(4),
      ),
    );
  }
}
