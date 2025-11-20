import 'package:flutter/material.dart';
import 'package:inward_outward_management/screens/company/dashboard/material_list_screen.dart';
import 'package:inward_outward_management/screens/company/dashboard/unit_master_screen.dart';
import 'package:inward_outward_management/screens/company/dashboard/supplier_master_screen.dart';
import 'package:inward_outward_management/screens/company/dashboard/customer_master_screen.dart';
import 'package:inward_outward_management/utils/app_colors.dart';
import 'package:inward_outward_management/widgets/app_scaffold.dart';

class MaterialMasterScreen extends StatefulWidget {
  const MaterialMasterScreen({super.key});

  @override
  State<MaterialMasterScreen> createState() => _MaterialMasterScreenState();
}

class _MaterialMasterScreenState extends State<MaterialMasterScreen> {
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Master Data',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _masterTile(
              context,
              icon: Icons.straighten,
              title: 'Unit Master',
              subtitle:
                  'Manage units, status and perform Add / Edit / View / Delete',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const UnitMasterScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _masterTile(
              context,
              icon: Icons.category_outlined,
              title: 'Material Master',
              subtitle:
                  'Manage materials and perform Add / Edit / Delete operations',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const MaterialListScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _masterTile(
              context,
              icon: Icons.person,
              title: 'Supplier Master',
              subtitle:
                  'Manage suppliers and perform Add / Edit / View / Delete operations',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const SupplierMasterScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _masterTile(
              context,
              icon: Icons.person_outline,
              title: 'Customer Master',
              subtitle:
                  'Manage customers and perform Add / Edit / View / Delete operations',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const CustomerMasterScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
  Widget _masterTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      color: AppColors.greyBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryGreen,
          child: Icon(icon, color: AppColors.textDark),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: AppColors.textLight,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color: AppColors.textLight,
            fontSize: 12,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textLight),
        onTap: onTap,
      ),
    );
  }
}
