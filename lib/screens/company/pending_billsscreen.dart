import 'package:flutter/material.dart';
import 'package:inward_outward_management/providers/company_provider.dart';
import 'package:inward_outward_management/utils/app_colors.dart';
import 'package:inward_outward_management/utils/responsive.dart';
import 'package:inward_outward_management/widgets/app_scaffold.dart';
import 'package:provider/provider.dart';

class PendingBillsscreen extends StatefulWidget {
  const PendingBillsscreen({super.key});

  @override
  State<PendingBillsscreen> createState() => _PendingBillsscreenState();
}

class _PendingBillsscreenState extends State<PendingBillsscreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prov = Provider.of<CompanyProvider>(context, listen: false);
      prov.loadSupplierBills();
    });
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    return AppScaffold(
      title: 'Pending Bills',
      body: SafeArea(
        child: Consumer<CompanyProvider>(
          builder: (context, prov, _) {
            if (prov.loadingBills) {
              return const Center(child: CircularProgressIndicator());
            }

            if (prov.bills.isEmpty) {
              return Center(
                child: Text(
                  'No bills found.',
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontSize: r.sp(12),
                  ),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async => prov.loadSupplierBills(),
              child: ListView.builder(
                padding: EdgeInsets.all(r.wp(4)),
                itemCount: prov.bills.length,
                itemBuilder: (context, index) {
                  final bill = prov.bills[index];
                  return _buildBillTile(r, prov, bill);
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBillTile(
    Responsive r,
    CompanyProvider prov,
    Map<String, dynamic> bill,
  ) {
    final amount = bill['amount']?.toString() ?? '0';
    final billNo = bill['billNo']?.toString() ?? '-';
    final challanId = bill['challanId']?.toString() ?? '-';
    final status = bill['status']?.toString() ?? 'unpaid';
    final billId = bill['id']?.toString() ?? '';

    return Card(
      color: AppColors.greyBackground,
      margin: EdgeInsets.only(bottom: r.hp(1.2)),
      child: ListTile(
        title: Text(
          'Bill #$billNo',
          style: const TextStyle(color: AppColors.textLight),
        ),
        subtitle: Text(
          'Challan: $challanId\nAmount: \u20b9$amount',
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
