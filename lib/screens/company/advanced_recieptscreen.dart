import 'package:flutter/material.dart';
import 'package:inward_outward_management/providers/company_provider.dart';
import 'package:inward_outward_management/utils/app_colors.dart';
import 'package:inward_outward_management/utils/responsive.dart';
import 'package:inward_outward_management/widgets/app_form_field.dart';
import 'package:inward_outward_management/widgets/app_scaffold.dart';
import 'package:inward_outward_management/widgets/primary_button.dart';
import 'package:provider/provider.dart';

class AdvancedRecieptscreen extends StatefulWidget {
  const AdvancedRecieptscreen({super.key});

  @override
  State<AdvancedRecieptscreen> createState() => _AdvancedRecieptscreenState();
}

class _AdvancedRecieptscreenState extends State<AdvancedRecieptscreen> {
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _submitting = false;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    return AppScaffold(
      title: 'Advance Receipts',
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryGreen,
        onPressed: () {
          _showAddReceiptSheet(context);
        },
        child: const Icon(Icons.add, color: AppColors.textDark),
      ),
      body: SafeArea(
        child: Consumer<CompanyProvider>(
          builder: (context, prov, _) {
            if (!prov.dashboardLoading && prov.advanceReceiptsTotal == 0.0) {
              prov.loadDashboardSummary();
            }

            if (!prov.loadingAdvanceReceipts && prov.advanceReceipts.isEmpty) {
              prov.loadAdvanceReceipts();
            }

            if (prov.dashboardLoading && prov.loadingAdvanceReceipts) {
              return const Center(child: CircularProgressIndicator());
            }

            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: r.wp(6),
                vertical: r.hp(2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Advance Amount',
                    style: TextStyle(
                      color: AppColors.textLight,
                      fontSize: r.sp(13),
                    ),
                  ),
                  SizedBox(height: r.hp(0.8)),
                  Text(
                    '₹${prov.advanceReceiptsTotal.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: AppColors.primaryGreen,
                      fontSize: r.sp(22),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: r.hp(2.5)),
                  Text(
                    'Detail listing of individual receipts can be added here later.',
                    style: TextStyle(
                      color: AppColors.textLight,
                      fontSize: r.sp(11),
                    ),
                  ),
                  SizedBox(height: r.hp(1.5)),
                  Expanded(
                    child: prov.loadingAdvanceReceipts
                        ? const Center(child: CircularProgressIndicator())
                        : prov.advanceReceipts.isEmpty
                        ? Center(
                            child: Text(
                              'No advance receipts yet. Tap + to add one.',
                              style: TextStyle(
                                color: AppColors.textLight,
                                fontSize: r.sp(11),
                              ),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: prov.loadAdvanceReceipts,
                            child: ListView.builder(
                              itemCount: prov.advanceReceipts.length,
                              itemBuilder: (context, index) {
                                final rec = prov.advanceReceipts[index];
                                return _buildReceiptTile(r, rec);
                              },
                            ),
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildReceiptTile(Responsive r, Map<String, dynamic> rec) {
    final amount = (rec['amount'] ?? 0).toString();
    final note = (rec['note'] ?? '').toString();
    final dateRaw = rec['date'];
    DateTime? date;
    if (dateRaw is int) {
      date = DateTime.fromMillisecondsSinceEpoch(dateRaw);
    }

    final dateStr = date != null
        ? '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}'
        : '';

    return Card(
      color: AppColors.greyBackground,
      margin: EdgeInsets.only(bottom: r.hp(1.2)),
      child: ListTile(
        title: Text(
          '₹$amount',
          style: const TextStyle(
            color: AppColors.primaryGreen,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          [
            if (dateStr.isNotEmpty) dateStr,
            if (note.isNotEmpty) note,
          ].join(' • '),
          style: const TextStyle(color: AppColors.textLight),
        ),
      ),
    );
  }

  void _showAddReceiptSheet(BuildContext context) {
    final r = Responsive(context);
    final prov = Provider.of<CompanyProvider>(context, listen: false);

    _amountCtrl.clear();
    _noteCtrl.clear();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.primaryDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: r.wp(6),
            right: r.wp(6),
            top: r.hp(2),
            bottom: MediaQuery.of(ctx).viewInsets.bottom + r.hp(2),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add Advance Receipt',
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontSize: r.sp(14),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: r.hp(1.5)),
                AppFormField(
                  controller: _amountCtrl,
                  label: 'Amount',
                  isNumber: true,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                SizedBox(height: r.hp(1.2)),
                AppFormField(controller: _noteCtrl, label: 'Note (optional)'),
                SizedBox(height: r.hp(2)),
                PrimaryButton(
                  label: 'Save Receipt',
                  loading: _submitting,
                  onTap: () async {
                    if (_submitting) return;
                    if (!_formKey.currentState!.validate()) return;
                    setState(() => _submitting = true);
                    try {
                      final amt =
                          double.tryParse(_amountCtrl.text.trim()) ?? 0.0;
                      final data = {
                        'amount': amt,
                        'note': _noteCtrl.text.trim(),
                      };
                      await prov.createAdvanceReceipt(data);
                      if (mounted) Navigator.of(ctx).pop();
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('Failed: $e')));
                    } finally {
                      if (mounted) {
                        setState(() => _submitting = false);
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
