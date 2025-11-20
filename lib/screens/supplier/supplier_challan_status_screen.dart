import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:inward_outward_management/utils/app_colors.dart';
import 'package:inward_outward_management/utils/responsive.dart';
import 'package:inward_outward_management/widgets/app_scaffold.dart';

class SupplierChallanStatusScreen extends StatefulWidget {
  const SupplierChallanStatusScreen({super.key});

  @override
  State<SupplierChallanStatusScreen> createState() => _SupplierChallanStatusScreenState();
}

class _SupplierChallanStatusScreenState extends State<SupplierChallanStatusScreen> {
  bool _loading = false;
  List<Map<String, dynamic>> _challans = [];
  List<Map<String, dynamic>> _bills = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _challans = [];
          _bills = [];
        });
        return;
      }
      final supplierId = user.uid;
      final fs = FirebaseFirestore.instance;

      final results = await Future.wait([
        fs
            .collectionGroup('challans')
            .where('supplierId', isEqualTo: supplierId)
            .orderBy('createdAt', descending: true)
            .get(),
        fs
            .collectionGroup('bills')
            .where('supplierId', isEqualTo: supplierId)
            .orderBy('createdAt', descending: true)
            .get(),
      ]);

      final challanSnap = results[0] as QuerySnapshot<Map<String, dynamic>>;
      final billSnap = results[1] as QuerySnapshot<Map<String, dynamic>>;

      _challans = challanSnap.docs.map((d) {
        final m = Map<String, dynamic>.from(d.data());
        m['id'] = d.id;
        return m;
      }).toList();

      _bills = billSnap.docs.map((d) {
        final m = Map<String, dynamic>.from(d.data());
        m['id'] = d.id;
        return m;
      }).toList();
    } catch (e) {
      _challans = [];
      _bills = [];
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    return AppScaffold(
      title: 'Challan & Payment Status',
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadData,
                child: ListView(
                  padding: EdgeInsets.all(r.wp(4)),
                  children: [
                    if (_challans.isEmpty && _bills.isEmpty)
                      Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: r.hp(20)),
                          child: Text(
                            'No challans or bills found for you yet.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textLight,
                              fontSize: r.sp(12),
                            ),
                          ),
                        ),
                      )
                    else ...[
                      if (_challans.isNotEmpty) ...[
                        Text(
                          'Challans',
                          style: TextStyle(
                            color: AppColors.textLight,
                            fontSize: r.sp(14),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: r.hp(1)),
                        ..._challans.map((c) => _buildChallanCard(r, c)),
                        SizedBox(height: r.hp(2)),
                      ],
                      if (_bills.isNotEmpty) ...[
                        Text(
                          'Bills / Payments',
                          style: TextStyle(
                            color: AppColors.textLight,
                            fontSize: r.sp(14),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: r.hp(1)),
                        ..._bills.map((b) => _buildBillCard(r, b)),
                      ],
                    ],
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildChallanCard(Responsive r, Map<String, dynamic> challan) {
    final challanNo = challan['challanNo']?.toString() ?? '-';
    final companyId = challan['companyId']?.toString() ?? '-';
    final amount = challan['totalAmount']?.toString() ?? '0';
    final status = challan['status']?.toString() ?? 'open';

    return Card(
      color: AppColors.greyBackground,
      margin: EdgeInsets.only(bottom: r.hp(1.2)),
      child: ListTile(
        title: Text(
          'Challan #$challanNo',
          style: const TextStyle(color: AppColors.textLight),
        ),
        subtitle: Text(
          'Company: $companyId\nAmount: ₹$amount',
          style: const TextStyle(color: AppColors.textLight),
        ),
        trailing: _buildStatusChip(status),
      ),
    );
  }

  Widget _buildBillCard(Responsive r, Map<String, dynamic> bill) {
    final billNo = bill['billNo']?.toString() ?? '-';
    final challanId = bill['challanId']?.toString() ?? '-';
    final companyId = bill['companyId']?.toString() ?? '-';
    final amount = bill['amount']?.toString() ?? '0';
    final status = bill['status']?.toString() ?? 'unpaid';

    return Card(
      color: AppColors.greyBackground,
      margin: EdgeInsets.only(bottom: r.hp(1.2)),
      child: ListTile(
        title: Text(
          'Bill #$billNo',
          style: const TextStyle(color: AppColors.textLight),
        ),
        subtitle: Text(
          'Company: $companyId\nChallan: $challanId\nAmount: ₹$amount',
          style: const TextStyle(color: AppColors.textLight),
        ),
        trailing: _buildStatusChip(status),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'paid':
        color = Colors.greenAccent.shade400;
        break;
      case 'partially_paid':
      case 'partiallyPaid':
        color = Colors.orangeAccent.shade200;
        break;
      case 'closed':
        color = Colors.blueAccent.shade200;
        break;
      default:
        color = Colors.redAccent.shade200;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.6)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }
}
