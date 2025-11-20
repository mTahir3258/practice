import 'package:flutter/material.dart';
import 'package:inward_outward_management/providers/company_provider.dart';
import 'package:inward_outward_management/utils/app_colors.dart';
import 'package:inward_outward_management/utils/responsive.dart';
import 'package:inward_outward_management/widgets/app_scaffold.dart';
import 'package:provider/provider.dart';

class PendingOutwardScreen extends StatelessWidget {
  const PendingOutwardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    return AppScaffold(
      title: 'Pending Outward',
      body: SafeArea(
        child: Consumer<CompanyProvider>(
          builder: (context, prov, _) {
            if (prov.loadingPendingOutward) {
              return const Center(child: CircularProgressIndicator());
            }

            if (prov.pendingOutwardList.isEmpty) {
              return Center(
                child: Text(
                  'No pending outward requests.',
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontSize: r.sp(12),
                  ),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async => prov.loadPendingOutward(),
              child: ListView.builder(
                padding: EdgeInsets.all(r.wp(4)),
                itemCount: prov.pendingOutwardList.length,
                itemBuilder: (context, index) {
                  final item = prov.pendingOutwardList[index];
                  return _buildOutwardTile(r, item);
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildOutwardTile(Responsive r, Map<String, dynamic> item) {
    final material = item['materialName']?.toString() ?? '-';
    final qty = item['quantity']?.toString() ?? '-';
    final weight = item['weight']?.toString() ?? '-';
    final status = item['status']?.toString() ?? 'pending';

    return Card(
      color: AppColors.greyBackground,
      margin: EdgeInsets.only(bottom: r.hp(1.2)),
      child: ListTile(
        title: Text(
          material,
          style: const TextStyle(color: AppColors.textLight),
        ),
        subtitle: Text(
          'Qty: $qty  |  Weight: ${weight}kg',
          style: const TextStyle(color: AppColors.textLight),
        ),
        trailing: Text(
          status,
          style: const TextStyle(
            color: AppColors.primaryGreen,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
