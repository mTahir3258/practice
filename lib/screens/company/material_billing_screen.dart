import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inward_outward_management/core/models/customer_model.dart';
import 'package:inward_outward_management/providers/company_provider.dart';
import 'package:inward_outward_management/utils/app_colors.dart';
import 'package:inward_outward_management/utils/responsive.dart';
import 'package:inward_outward_management/widgets/app_scaffold.dart';
import 'package:inward_outward_management/widgets/app_form_field.dart';
import 'package:inward_outward_management/widgets/primary_button.dart';
import 'package:provider/provider.dart';

class MaterialBillingScreen extends StatefulWidget {
  final String materialName;
  final String unitName;
  final double totalQuantity;
  final String? intimationId;

  const MaterialBillingScreen({
    super.key,
    required this.materialName,
    required this.unitName,
    required this.totalQuantity,
    this.intimationId,
  });

  @override
  State<MaterialBillingScreen> createState() => _MaterialBillingScreenState();
}

class _MaterialBillingScreenState extends State<MaterialBillingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _rateCtr = TextEditingController();
  final _qtyCtr = TextEditingController();

  CustomerModel? _selectedCustomer;

  bool _submitting = false;

  @override
  void dispose() {
    _rateCtr.dispose();
    _qtyCtr.dispose();
    super.dispose();
  }

  double get _billTotal {
    final rate = double.tryParse(_rateCtr.text.trim()) ?? 0.0;
    final qty = double.tryParse(_qtyCtr.text.trim()) ?? 0.0;
    return rate * qty;
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);
    final companyProv = Provider.of<CompanyProvider>(context);

    return AppScaffold(
      title: 'Create Bill',
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(r.wp(4)),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primaryDark,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.all(r.wp(4)),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Customer',
                        style: TextStyle(
                          color: AppColors.textLight,
                          fontSize: r.sp(11),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: r.hp(0.8)),
                      DropdownButtonFormField<CustomerModel>(
                        value: _selectedCustomer,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.greyBackground,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppColors.greyBackground,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppColors.greyBackground,
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: r.wp(3),
                            vertical: r.hp(1),
                          ),
                        ),
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: AppColors.textLight,
                        ),
                        dropdownColor: AppColors.greyBackground,
                        items: companyProv.customers
                            .map(
                              (c) => DropdownMenuItem<CustomerModel>(
                                value: c,
                                child: Text(
                                  c.name,
                                  style: TextStyle(
                                    color: AppColors.textLight,
                                    fontSize: r.sp(9),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedCustomer = val;
                          });
                        },
                        validator: (val) {
                          if (val == null) {
                            return 'Select a customer';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: r.hp(2)),
                      Text(
                        'Material: ${widget.materialName}',
                        style: TextStyle(
                          color: AppColors.textLight,
                          fontSize: r.sp(14),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: r.hp(0.6)),
                      Text(
                        'Unit: ${widget.unitName}',
                        style: TextStyle(
                          color: AppColors.textLight,
                          fontSize: r.sp(11),
                        ),
                      ),
                      SizedBox(height: r.hp(0.6)),
                      Text(
                        'Total: ${widget.totalQuantity.toStringAsFixed(2)} ${widget.unitName}',
                        style: TextStyle(
                          color: AppColors.textLight,
                          fontSize: r.sp(11),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: r.hp(2)),
                      AppFormField(
                        controller: _qtyCtr,
                        label: 'Quantity (${widget.unitName})',
                        isNumber: true,
                        validator: (v) {
                          final text = v?.trim() ?? '';
                          if (text.isEmpty) return 'Required';
                          final val = double.tryParse(text);
                          if (val == null || val <= 0) {
                            return 'Enter a valid quantity';
                          }
                          if (val > widget.totalQuantity) {
                            return 'Cannot exceed available ${widget.totalQuantity.toStringAsFixed(2)} ${widget.unitName}';
                          }
                          return null;
                        },
                        onChanged: (_) {
                          setState(() {});
                        },
                      ),
                      SizedBox(height: r.hp(2)),
                      AppFormField(
                        controller: _rateCtr,
                        label: 'Rate per ${widget.unitName}',
                        isNumber: true,
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Required' : null,
                        onChanged: (_) {
                          setState(() {});
                        },
                      ),
                      SizedBox(height: r.hp(2)),
                      Center(
                        child: Text(
                          'Bill Amount Rs : ${_billTotal.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: AppColors.textLight,
                            fontSize: r.sp(14),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      SizedBox(height: r.hp(3)),
                      PrimaryButton(
                        label: 'Generate Invoice',
                        loading: _submitting,
                        onTap: () {
                          if (_submitting) return;
                          _createBill();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _createBill() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);

    try {
      if (!mounted) return;
      final customer = _selectedCustomer;
      if (customer == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Select a customer')),
        );
        return;
      }

      final rate = double.tryParse(_rateCtr.text.trim()) ?? 0.0;
      final qty = double.tryParse(_qtyCtr.text.trim()) ?? 0.0;
      final amount = _billTotal;
      final remaining = (widget.totalQuantity - qty).clamp(0.0, widget.totalQuantity);

      final invoiceData = <String, dynamic>{
        'customerId': customer.mobile,
        'customerName': customer.name,
        'materialName': widget.materialName,
        'quantity': qty,
        'unitName': widget.unitName,
        'ratePerUnit': rate,
        'amount': amount,
        'availableQuantity': widget.totalQuantity,
        'remainingQuantity': remaining,
        'status': 'pending',
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      };

      await FirebaseFirestore.instance
          .collection('customers')
          .doc(customer.mobile)
          .collection('invoices')
          .add(invoiceData);

      final companyProv = Provider.of<CompanyProvider>(context, listen: false);
      final companyId = companyProv.companyId;
      final intimationId = widget.intimationId;
      if (companyId.isNotEmpty && intimationId != null && intimationId.isNotEmpty) {
        try {
          await FirebaseFirestore.instance
              .collection('companies')
              .doc(companyId)
              .collection('standalone_intimations')
              .doc(intimationId)
              .update({'remainingWeight': remaining});
          await companyProv.loadStandaloneIntimations();
        } catch (e) {
          // best-effort; ignore if inventory update fails
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invoice generated for ${customer.name}'),
        ),
      );

      Navigator.of(context).pop();
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }
}
