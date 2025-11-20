import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:inward_outward_management/services/company_services.dart';
import 'package:inward_outward_management/utils/app_colors.dart';
import 'package:inward_outward_management/utils/responsive.dart';
import 'package:inward_outward_management/widgets/app_scaffold.dart';
import 'package:inward_outward_management/widgets/app_form_field.dart';
import 'package:inward_outward_management/widgets/primary_button.dart';

class SupplierIntimationFormScreen extends StatefulWidget {
  final String requestId;
  final String materialName;
  final String companyId;
  final String? baseQuantity;
  final String? baseWeight;

  const SupplierIntimationFormScreen({
    super.key,
    required this.requestId,
    required this.materialName,
    required this.companyId,
    this.baseQuantity,
    this.baseWeight,
  });

  @override
  State<SupplierIntimationFormScreen> createState() =>
      _SupplierIntimationFormScreenState();
}

class _SupplierIntimationFormScreenState
    extends State<SupplierIntimationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _rateCtr = TextEditingController();
  int _selectedUnits = 0;
  double? _perUnitWeight;
  int _maxUnits = 100;

  bool _submitting = false;

  @override
  void dispose() {
    _rateCtr.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final baseQty = double.tryParse(widget.baseQuantity ?? '0') ?? 0;
    final baseWeight = double.tryParse(widget.baseWeight ?? '0') ?? 0;
    if (baseQty > 0 && baseWeight > 0) {
      _perUnitWeight = baseWeight / baseQty;
    } else {
      _perUnitWeight = null;
    }

    // Limit dropdown range to requested quantity (option B)
    _maxUnits = baseQty > 0 ? baseQty.toInt() : 100;
  }

  double get _totalDispatchWeight {
    if (_perUnitWeight == null) return 0;
    return _perUnitWeight! * _selectedUnits;
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    return AppScaffold(
      title: 'Dispatch Intimation',
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(r.wp(4)),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Material: ${widget.materialName}',
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontSize: r.sp(14),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (widget.baseQuantity != null ||
                    widget.baseWeight != null) ...[
                  SizedBox(height: r.hp(0.6)),
                  Text(
                    'Requested: qty ${widget.baseQuantity ?? '-'}, weight ${widget.baseWeight ?? '-'} kg',
                    style: TextStyle(
                      color: AppColors.textLight,
                      fontSize: r.sp(11),
                    ),
                  ),
                ],
                SizedBox(height: r.hp(2)),
                DropdownButtonFormField<int>(
                  value: _selectedUnits,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.greyBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: AppColors.greyBackground,
                        width: 1,
                      ),
                    ),
                  ),
                  items: List.generate(_maxUnits + 1, (index) => index)
                      .map(
                        (v) => DropdownMenuItem<int>(
                          value: v,
                          child: Text(
                            v.toString(),
                            // style: TextStyle(color: AppColors.textLight),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedUnits = val ?? 0;
                    });
                  },
                  validator: (val) {
                    if (val == null || val == 0) {
                      return 'Select dispatch units';
                    }
                    return null;
                  },
                ),
                SizedBox(height: r.hp(1.2)),
                AppFormField(
                  controller: _rateCtr,
                  label: 'Rate per unit',
                  isNumber: true,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                SizedBox(height: r.hp(1.2)),
                Text(
                  'Per unit weight: '
                  '${_perUnitWeight != null ? _perUnitWeight!.toStringAsFixed(2) : '-'} kg',
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontSize: r.sp(11),
                  ),
                ),
                SizedBox(height: r.hp(0.6)),
                Text(
                  'Total dispatch quantity: $_selectedUnits',
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontSize: r.sp(11),
                  ),
                ),
                SizedBox(height: r.hp(0.6)),
                Text(
                  'Total dispatch weight: ${_totalDispatchWeight.toStringAsFixed(2)} kg',
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontSize: r.sp(11),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: r.hp(2)),
                PrimaryButton(
                  label: 'Submit Intimation',
                  loading: _submitting,
                  onTap: () {
                    // Guard inside the callback so type stays VoidCallback
                    if (_submitting) return;
                    _submit();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final supplier = FirebaseAuth.instance.currentUser;
    if (supplier == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not authenticated as supplier')),
      );
      return;
    }

    setState(() => _submitting = true);

    try {
      final rate = double.tryParse(_rateCtr.text.trim()) ?? 0.0;
      final qty = _selectedUnits.toDouble();
      final materialKg = _totalDispatchWeight;
      const plasticKg = 0.0;

      final items = <String, dynamic>{
        widget.materialName: {
          'qty': qty,
          'rate': rate,
          'materialKg': materialKg,
          'plasticKg': plasticKg,
        },
      };

      final intimation = <String, dynamic>{
        'supplierId': supplier.uid,
        'companyId': widget.companyId,
        'items': items,
      };

      final service = CompanyService();
      await service.addSupplierIntimation(widget.requestId, intimation);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dispatch intimation submitted')),
      );
      Navigator.of(context).pop();
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
  }
}
