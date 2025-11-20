import 'package:flutter/material.dart';
import 'package:inward_outward_management/providers/company_provider.dart';
import 'package:inward_outward_management/utils/app_colors.dart';
import 'package:inward_outward_management/utils/responsive.dart';
import 'package:inward_outward_management/widgets/app_scaffold.dart';
import 'package:provider/provider.dart';

class InwardHistoryScreen extends StatelessWidget {
  const InwardHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    return AppScaffold(
      title: 'Inward History',
      body: SafeArea(
        child: Consumer<CompanyProvider>(
          builder: (context, prov, _) {
            if (!prov.loadingInwardHistory && prov.inwardHistory.isEmpty) {
              prov.loadInwardHistory();
            }

            if (prov.loadingInwardHistory) {
              return const Center(child: CircularProgressIndicator());
            }

            if (prov.inwardHistory.isEmpty) {
              return Center(
                child: Text(
                  'No inward entries yet.',
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontSize: r.sp(12),
                  ),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: prov.loadInwardHistory,
              child: ListView.builder(
                padding: EdgeInsets.all(r.wp(4)),
                itemCount: prov.inwardHistory.length,
                itemBuilder: (context, index) {
                  final item = prov.inwardHistory[index];
                  return _buildInwardCard(r, item);
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInwardCard(Responsive r, Map<String, dynamic> item) {
    final challanId = item['challanId']?.toString() ?? '-';
    final qty = item['quantity']?.toString() ?? '-';
    final weight = item['weight']?.toString() ?? '-';
    final status = item['status']?.toString() ?? '-';
    final createdAt = item['createdAt'];

    DateTime? created;
    if (createdAt is int) {
      created = DateTime.fromMillisecondsSinceEpoch(createdAt);
    }
    final dateStr = created != null
        ? '${created.day.toString().padLeft(2, '0')}-${created.month.toString().padLeft(2, '0')}-${created.year}'
        : '';

    return Card(
      color: AppColors.greyBackground,
      margin: EdgeInsets.only(bottom: r.hp(1.2)),
      child: Padding(
        padding: EdgeInsets.all(r.wp(3)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Challan: $challanId',
              style: const TextStyle(color: AppColors.textLight),
            ),
            SizedBox(height: r.hp(0.4)),
            if (dateStr.isNotEmpty)
              Text(
                dateStr,
                style: TextStyle(
                  color: AppColors.textLight.withOpacity(0.7),
                  fontSize: r.sp(10),
                ),
              ),
            SizedBox(height: r.hp(0.4)),
            Text(
              'Qty: $qty  |  Weight: ${weight}kg',
              style: const TextStyle(color: AppColors.textLight),
            ),
            SizedBox(height: r.hp(0.6)),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primaryGreen.withOpacity(0.6),
                  ),
                ),
                child: Text(
                  status,
                  style: const TextStyle(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
