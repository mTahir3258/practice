import 'package:flutter/material.dart';
import 'package:inward_outward_management/providers/box_provider.dart';
import 'package:inward_outward_management/utils/app_colors.dart';
import 'package:inward_outward_management/utils/responsive.dart';
import 'package:inward_outward_management/widgets/app_form_field.dart';
import 'package:inward_outward_management/widgets/app_scaffold.dart';
import 'package:inward_outward_management/widgets/primary_button.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class AddEditBoxScreen extends StatefulWidget {
  final Map<String, dynamic>? existing;

  const AddEditBoxScreen({super.key, this.existing});

  @override
  State<AddEditBoxScreen> createState() => _AddEditBoxScreenState();
}

class _AddEditBoxScreenState extends State<AddEditBoxScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController materialName = TextEditingController();
  final TextEditingController boxType = TextEditingController();
  final TextEditingController boxWeight = TextEditingController();
  final TextEditingController plasticWeight = TextEditingController();
  final TextEditingController rate = TextEditingController();

  double totalWeight = 0;
  double amount = 0;

  @override
  void initState() {
    super.initState();

    if (widget.existing != null) {
      final e = widget.existing!;
      materialName.text = e["materialName"];
      boxType.text = e["boxType"];
      boxWeight.text = e["boxWeight"].toString();
      plasticWeight.text = e["plasticWeight"].toString();
      rate.text = e["rate"].toString();
      totalWeight = e["totalWeight"];
      amount = e["amount"];
    }

    boxWeight.addListener(_calculate);
    plasticWeight.addListener(_calculate);
    rate.addListener(_calculate);
  }

  void _calculate() {
    final w = double.tryParse(boxWeight.text) ?? 0;
    final p = double.tryParse(plasticWeight.text) ?? 0;
    final r = double.tryParse(rate.text) ?? 0;

    setState(() {
      totalWeight = w + p;
      amount = totalWeight * r;
    });
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<BoxProvider>(context, listen: false);
    final r = Responsive(context);

    return AppScaffold(
      title: widget.existing == null ? 'Add Box' : 'Edit Box',
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(r.wp(5)),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppFormField(
                  controller: materialName,
                  label: 'Material Name',
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                SizedBox(height: r.hp(1.2)),
                AppFormField(
                  controller: boxType,
                  label: 'Box Type',
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                SizedBox(height: r.hp(1.2)),
                AppFormField(
                  controller: boxWeight,
                  label: 'Box Weight (kg)',
                  isNumber: true,
                ),
                SizedBox(height: r.hp(1.2)),
                AppFormField(
                  controller: plasticWeight,
                  label: 'Plastic Weight (kg)',
                  isNumber: true,
                ),
                SizedBox(height: r.hp(1.2)),
                AppFormField(
                  controller: rate,
                  label: 'Rate (₹ per kg)',
                  isNumber: true,
                ),
                SizedBox(height: r.hp(2)),
                Text(
                  'Total Weight: ${totalWeight.toStringAsFixed(2)} kg',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: r.sp(12),
                    color: AppColors.textLight,
                  ),
                ),
                Text(
                  'Total Amount: ₹${amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: r.sp(12),
                    color: AppColors.textLight,
                  ),
                ),
                const Spacer(),
                PrimaryButton(
                  label: widget.existing == null ? 'Save' : 'Update',
                  onTap: () async {
                    if (!_formKey.currentState!.validate()) return;

                    final box = {
                      'boxId': widget.existing?['boxId'] ?? const Uuid().v4(),
                      'materialName': materialName.text,
                      'boxType': boxType.text,
                      'boxWeight': double.tryParse(boxWeight.text) ?? 0,
                      'plasticWeight': double.tryParse(plasticWeight.text) ?? 0,
                      'rate': double.tryParse(rate.text) ?? 0,
                      'totalWeight': totalWeight,
                      'amount': amount,
                      'createdAt': DateTime.now().millisecondsSinceEpoch,
                    };

                    await prov.saveBox(box);
                    if (mounted) Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
