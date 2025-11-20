import 'package:flutter/material.dart';
import 'package:inward_outward_management/providers/company_provider.dart';
import 'package:inward_outward_management/utils/app_colors.dart';
import 'package:inward_outward_management/utils/responsive.dart';
import 'package:inward_outward_management/widgets/app_scaffold.dart';
import 'package:inward_outward_management/widgets/app_form_field.dart';
import 'package:inward_outward_management/widgets/primary_button.dart';
import 'package:inward_outward_management/screens/company/supplier_intimation_screen.dart';
import 'package:provider/provider.dart';

class SupplierRequestScreen extends StatefulWidget {
  const SupplierRequestScreen({super.key});

  @override
  State<SupplierRequestScreen> createState() => _SupplierRequestScreenState();
}

class _SupplierRequestScreenState extends State<SupplierRequestScreen> {
  final _formKey = GlobalKey<FormState>();

  final _materialCtr = TextEditingController();
  final _quantityCtr = TextEditingController();
  final _weightCtr = TextEditingController();
  final _supplierCtr = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prov = Provider.of<CompanyProvider>(context, listen: false);
      prov.loadMaterialRequests();
    });
  }

  @override
  void dispose() {
    _materialCtr.dispose();
    _quantityCtr.dispose();
    _weightCtr.dispose();
    _supplierCtr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    return AppScaffold(
      title: 'Supplier Requests',
      body: SafeArea(
        child: Consumer<CompanyProvider>(
          builder: (context, prov, _) {
            return RefreshIndicator(
              onRefresh: () async => prov.loadMaterialRequests(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: r.wp(4),
                  vertical: r.hp(2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recent Requests',
                      style: TextStyle(
                        color: AppColors.textLight,
                        fontSize: r.sp(14),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: r.hp(1)),
                    if (prov.loadingRequests)
                      const Center(child: CircularProgressIndicator())
                    else if (prov.requests.isEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: r.hp(2)),
                        child: Text(
                          'No requests created yet.',
                          style: TextStyle(
                            color: AppColors.textLight,
                            fontSize: r.sp(11),
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: prov.requests.length,
                        itemBuilder: (context, index) {
                          final req = prov.requests[index];
                          return _buildRequestTile(r, req);
                        },
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildForm(Responsive r, CompanyProvider prov) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          AppFormField(
            controller: _materialCtr,
            label: 'Material Name',
            validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
          ),
          SizedBox(height: r.hp(1.2)),
          AppFormField(
            controller: _quantityCtr,
            label: 'Quantity',
            isNumber: true,
            validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
          ),
          SizedBox(height: r.hp(1.2)),
          AppFormField(
            controller: _weightCtr,
            label: 'Weight (kg)',
            isNumber: true,
            validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
          ),
          SizedBox(height: r.hp(1.2)),
          AppFormField(
            controller: _supplierCtr,
            label: 'Supplier ID',
            validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
          ),
          SizedBox(height: r.hp(2)),
          PrimaryButton(
            label: 'Submit Request',
            loading: prov.loadingRequests,
            onTap: () async {
              if (!_formKey.currentState!.validate()) return;

              final map = {
                'materialName': _materialCtr.text.trim(),
                'quantity': int.tryParse(_quantityCtr.text.trim()) ?? 0,
                'weight': double.tryParse(_weightCtr.text.trim()) ?? 0.0,
                'supplierId': _supplierCtr.text.trim(),
              };

              try {
                await prov.createMaterialRequest(map);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Material request created')),
                );
                _formKey.currentState!.reset();
                _materialCtr.clear();
                _quantityCtr.clear();
                _weightCtr.clear();
                _supplierCtr.clear();
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Failed: $e')));
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRequestTile(Responsive r, Map<String, dynamic> req) {
    final status = req['status']?.toString() ?? 'requested';
    final material = req['materialName']?.toString() ?? '-';
    final qty = req['quantity']?.toString() ?? '-';
    final weight = req['weight']?.toString() ?? '-';
    final supplierId = req['supplierId']?.toString() ?? '-';
    final supplierEmail = req['supplierEmail']?.toString() ?? '';
    final id = req['id']?.toString() ?? '';

    return Card(
      color: AppColors.greyBackground,
      margin: EdgeInsets.only(bottom: r.hp(1.2)),
      child: ListTile(
        onTap: id.isEmpty
            ? null
            : () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => SupplierIntimationScreen(
                      requestId: id,
                      materialName: material,
                    ),
                  ),
                );
              },
        title: Text(
          material,
          style: const TextStyle(color: AppColors.textLight),
        ),
        subtitle: Text(
          'Qty: $qty  |  Weight: ${weight}kg\nSupplier email: ${supplierEmail.isNotEmpty ? supplierEmail : '-'}  |  Supplier ID: $supplierId',
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
