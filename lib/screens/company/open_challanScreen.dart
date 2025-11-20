import 'package:flutter/material.dart';
import 'package:inward_outward_management/providers/company_provider.dart';
import 'package:inward_outward_management/utils/app_colors.dart';
import 'package:inward_outward_management/utils/responsive.dart';
import 'package:inward_outward_management/widgets/app_scaffold.dart';
import 'package:provider/provider.dart';

class OpenChallanscreen extends StatefulWidget {
  const OpenChallanscreen({super.key});

  @override
  State<OpenChallanscreen> createState() => _OpenChallanscreenState();
}

class _OpenChallanscreenState extends State<OpenChallanscreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prov = Provider.of<CompanyProvider>(context, listen: false);
      prov.loadChallans();
    });
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    return AppScaffold(
      title: 'Open Challans',
      body: SafeArea(
        child: Consumer<CompanyProvider>(
          builder: (context, prov, _) {
            if (prov.loadingChallans) {
              return const Center(child: CircularProgressIndicator());
            }

            if (prov.challans.isEmpty) {
              return Center(
                child: Text(
                  'No challans found.',
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontSize: r.sp(12),
                  ),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async => prov.loadChallans(),
              child: ListView.builder(
                padding: EdgeInsets.all(r.wp(4)),
                itemCount: prov.challans.length,
                itemBuilder: (context, index) {
                  final challan = prov.challans[index];
                  return _buildChallanTile(r, prov, challan);
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildChallanTile(
    Responsive r,
    CompanyProvider prov,
    Map<String, dynamic> challan,
  ) {
    final id = challan['id']?.toString() ?? '';
    final challanNo = challan['challanNo']?.toString() ?? '-';
    final supplierId = challan['supplierId']?.toString() ?? '-';
    final supplierName = challan['supplierName']?.toString() ?? '';
    final supplierDisplay =
        supplierName.isNotEmpty ? supplierName : supplierId;
    final amount = challan['totalAmount']?.toString() ?? '0';
    final status = challan['status']?.toString() ?? 'open';

    return Card(
      color: AppColors.greyBackground,
      margin: EdgeInsets.only(bottom: r.hp(1.2)),
      child: ListTile(
        isThreeLine: true,
        title: Text(
          'Challan #$challanNo',
          style: const TextStyle(color: AppColors.textLight),
        ),
        subtitle: Text(
          'Supplier: $supplierDisplay\nAmount: ₹$amount\nStatus: $status',
          style: const TextStyle(color: AppColors.textLight),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (status == 'open')
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: AppColors.textLight),
                onSelected: (value) async {
                  if (value == 'close') {
                    try {
                      await prov.updateChallanStatus(id, 'closed');
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Challan marked as closed'),
                        ),
                      );
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed: $e')),
                      );
                    }
                  } else if (value == 'bill') {
                    try {
                      await prov.generateBillFromChallan(id);
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Supplier bill generated from challan'),
                        ),
                      );
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to generate bill: $e'),
                        ),
                      );
                    }
                  }
                },
                itemBuilder: (ctx) => const [
                  PopupMenuItem(
                    value: 'close',
                    child: Text('Mark Closed'),
                  ),
                  PopupMenuItem(
                    value: 'bill',
                    child: Text('Generate Bill'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
