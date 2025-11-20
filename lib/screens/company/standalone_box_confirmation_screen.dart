import 'package:flutter/material.dart';
import 'package:inward_outward_management/providers/company_provider.dart';
import 'package:inward_outward_management/utils/app_colors.dart';
import 'package:inward_outward_management/utils/responsive.dart';
import 'package:inward_outward_management/widgets/app_scaffold.dart';
import 'package:inward_outward_management/widgets/primary_button.dart';
import 'package:provider/provider.dart';

class StandaloneBoxConfirmationScreen extends StatefulWidget {
  final Map<String, dynamic> intimation;

  const StandaloneBoxConfirmationScreen({
    super.key,
    required this.intimation,
  });

  @override
  State<StandaloneBoxConfirmationScreen> createState() =>
      _StandaloneBoxConfirmationScreenState();
}

class _StandaloneBoxConfirmationScreenState
    extends State<StandaloneBoxConfirmationScreen> {
  late final int _boxes;
  late List<bool> _confirmed;
  late final List<double> _boxValues;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final boxesVal = widget.intimation['boxes'];
    final boxes = boxesVal is num
        ? boxesVal.toInt()
        : int.tryParse(boxesVal?.toString() ?? '') ?? 0;
    _boxes = boxes > 0 ? boxes : 0;

    // Load per-box values from intimation (if present)
    final dynamic rawBoxValues = widget.intimation['boxValues'];
    if (rawBoxValues is List) {
      _boxValues = rawBoxValues
          .map((v) => v is num ? v.toDouble() : double.tryParse('$v') ?? 0.0)
          .toList();
    } else {
      _boxValues = List<double>.filled(_boxes, 0.0);
    }

    // Ensure lists have consistent length
    if (_boxValues.length < _boxes) {
      _boxValues.addAll(
        List<double>.filled(_boxes - _boxValues.length, 0.0),
      );
    } else if (_boxValues.length > _boxes && _boxes > 0) {
      _boxValues.removeRange(_boxes, _boxValues.length);
    }

    _confirmed = List<bool>.filled(_boxes, false);
  }

  Future<void> _confirm() async {
    if (_submitting) return;
    setState(() => _submitting = true);

    try {
      final prov = Provider.of<CompanyProvider>(context, listen: false);
      final companyId = prov.companyId;
      final intimationId = widget.intimation['id']?.toString() ?? '';
      if (companyId.isEmpty || intimationId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Missing company or intimation id')),
        );
        setState(() => _submitting = false);
        return;
      }

      await prov.updateStandaloneIntimationStatusOnly(
        intimationId: intimationId,
        status: 'confirmed',
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Standalone intimation confirmed')),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);
    final supplierName = widget.intimation['supplierName']?.toString() ?? '';
    final materialName = widget.intimation['materialName']?.toString() ?? '';
    final unitName = widget.intimation['unitName']?.toString() ?? '';
    final totalVal = (widget.intimation['entriesTotalWeight'] ??
        widget.intimation['totalWeightField']);
    final total = totalVal?.toString();
    final totalUnits =
        _boxValues.fold<double>(0, (sum, v) => sum + (v.isFinite ? v : 0));

    return AppScaffold(
      title: 'Box Confirmation',
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(r.wp(4)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(r.wp(3)),
                decoration: BoxDecoration(
                  color: AppColors.greyBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Supplier',
                              style: TextStyle(
                                color: AppColors.textLight,
                                fontSize: r.sp(10),
                              ),
                            ),
                            Text(
                              supplierName,
                              style: TextStyle(
                                color: AppColors.textLight,
                                fontSize: r.sp(12),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Material',
                              style: TextStyle(
                                color: AppColors.textLight,
                                fontSize: r.sp(10),
                              ),
                            ),
                            Text(
                              materialName,
                              style: TextStyle(
                                color: AppColors.textLight,
                                fontSize: r.sp(12),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: r.hp(0.8)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Unit',
                              style: TextStyle(
                                color: AppColors.textLight,
                                fontSize: r.sp(10),
                              ),
                            ),
                            Text(
                              unitName,
                              style: TextStyle(
                                color: AppColors.textLight,
                                fontSize: r.sp(12),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total',
                              style: TextStyle(
                                color: AppColors.textLight,
                                fontSize: r.sp(10),
                              ),
                            ),
                            Text(
                              total != null
                                  ? '$total ${unitName.isNotEmpty ? unitName : ''}'
                                  : '-',
                              style: TextStyle(
                                color: AppColors.textLight,
                                fontSize: r.sp(12),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: r.hp(2)),

              // Boxes list
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Confirm Boxes',
                    style: TextStyle(
                      color: AppColors.textLight,
                      fontSize: r.sp(12),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Total: $_boxes',
                    style: TextStyle(
                      color: AppColors.textLight,
                      fontSize: r.sp(11),
                    ),
                  ),
                ],
              ),
              SizedBox(height: r.hp(1)),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.greyBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListView.builder(
                    itemCount: _boxes,
                    itemBuilder: (context, index) {
                      final label = 'Box ${index + 1}';
                      final value = index < _boxValues.length
                          ? _boxValues[index]
                          : 0.0;
                      final checked = _confirmed[index];
                      return ListTile(
                        leading: const Icon(
                          Icons.inventory_2_outlined,
                          color: AppColors.textLight,
                        ),
                        title: Text(
                          label,
                          style: TextStyle(
                            color: AppColors.textLight,
                            fontSize: r.sp(11),
                          ),
                        ),
                        subtitle: Text(
                          '${value.toStringAsFixed(1)} ${unitName.isNotEmpty ? unitName : ''}',
                          style: TextStyle(
                            color: AppColors.textLight,
                            fontSize: r.sp(10),
                          ),
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            checked
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            color: checked
                                ? AppColors.primaryGreen
                                : Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _confirmed[index] = !checked;
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: r.hp(1.5)),

              // Bottom summary: total boxes and total units
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(bottom: r.hp(0.5)),
                  child: Text(
                    'Total boxes: $_boxes, Total unit: ${totalUnits.toStringAsFixed(1)} ${unitName.isNotEmpty ? unitName : ''}',
                    style: TextStyle(
                      color: AppColors.textLight,
                      fontSize: r.sp(11),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              PrimaryButton(
                label: 'Confirm',
                loading: _submitting,
                onTap: _confirm,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
