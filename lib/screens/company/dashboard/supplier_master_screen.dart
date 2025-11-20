import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:inward_outward_management/core/models/supplier_model.dart';
import 'package:inward_outward_management/providers/company_provider.dart';
import 'package:inward_outward_management/utils/app_colors.dart';
import 'package:inward_outward_management/widgets/app_form_field.dart';
import 'package:inward_outward_management/widgets/app_scaffold.dart';
import 'package:provider/provider.dart';

class SupplierMasterScreen extends StatefulWidget {
  const SupplierMasterScreen({super.key});

  @override
  State<SupplierMasterScreen> createState() => _SupplierMasterScreenState();
}

class _SupplierMasterScreenState extends State<SupplierMasterScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () =>
          Provider.of<CompanyProvider>(context, listen: false).loadSuppliers(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CompanyProvider>(context);

    return AppScaffold(
      title: 'Supplier Master',
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    color: AppColors.greyBackground,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const CircleAvatar(
                              backgroundColor: AppColors.primaryGreen,
                              child: Icon(
                                Icons.person,
                                color: AppColors.textDark,
                              ),
                            ),
                            title: const Text(
                              'Supplier Master',
                              style: TextStyle(
                                color: AppColors.textLight,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: const Text(
                              'Manage suppliers and perform Add / Edit / View / Delete',
                              style: TextStyle(
                                color: AppColors.textLight,
                                fontSize: 12,
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.add,
                                  color: AppColors.primaryGreen),
                              onPressed: () => _showAddSupplierDialog(context),
                            ),
                          ),
                          const SizedBox(height: 8),
                          _supplierList(provider),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _supplierList(CompanyProvider provider) {
    if (provider.suppliers.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text(
          'No Suppliers Added Yet',
          style: TextStyle(color: AppColors.textLight),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: provider.suppliers.length,
      itemBuilder: (context, index) {
        final supplier = provider.suppliers[index];
        return Card(
          color: AppColors.greyBackground,
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: Padding(
            padding: const EdgeInsets.all(12.0),

            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [


                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      supplier.name,
                      style: const TextStyle(
                        color: AppColors.textLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Mobile: ${supplier.mobile}',
                      style: const TextStyle(color: AppColors.textLight),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Address: ${supplier.address}',
                      style: const TextStyle(color: AppColors.textLight),
                    ),
                    const SizedBox(height: 8),
                
                
                
                  ]
                ),
           
           
                
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                 IconButton( icon: Icon(Icons.visibility,color: AppColors.textLight,),
                 onPressed: () =>
                          _showViewSupplierDialog(context, supplier),),
                    IconButton(
                      icon: const Icon(
                        Icons.edit,
                        color: AppColors.primaryGreen,
                      ),
                      onPressed: () =>
                          _showEditSupplierDialog(context, supplier),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete,
                        color: AppColors.errorRed,
                      ),
                      onPressed: () => _showDeleteSupplierConfirmation(
                        context,
                        supplier,
                      ),
                    ),
                  ],
                ),
           
              ],
            ),

          ),
        );
      },
    );
  }

  Widget _customTextField(
    TextEditingController controller,
    String hint, {
    bool isNumber = false,
  }) {
    return AppFormField(
      controller: controller,
      label: hint,
      isNumber: isNumber,
    );
  }

  void _showAddSupplierDialog(BuildContext context) {
    final nameController = TextEditingController();
    final addressController = TextEditingController();
    final mobileController = TextEditingController();
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Add Supplier'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _customTextField(nameController, 'Supplier Name'),
                const SizedBox(height: 10),
                _customTextField(addressController, 'Address'),
                const SizedBox(height: 10),
                _customTextField(mobileController, 'Mobile No', isNumber: true),
                const SizedBox(height: 10),
                _customTextField(passwordController, 'Password'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final address = addressController.text.trim();
                final mobile = mobileController.text.trim();
                final password = passwordController.text.trim();

                final supplier = SupplierModel(
                  name: name,
                  address: address,
                  mobile: mobile,
                  password: password,
                );

                await Provider.of<CompanyProvider>(context, listen: false)
                    .addSupplier(supplier);

                // Also create an auth user so supplier can log in with mobile + password
                final syntheticEmail = '$mobile@supplier.local';
                try {
                  final cred = await FirebaseAuth.instance
                      .createUserWithEmailAndPassword(
                    email: syntheticEmail,
                    password: password,
                  );

                  final uid = cred.user?.uid;
                  if (uid != null) {
                    // Update auth display name for supplier convenience
                    await cred.user?.updateDisplayName(name);

                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(uid)
                        .set({
                      'uid': uid,
                      'name': name,
                      'email': syntheticEmail,
                      'role': 'supplier',
                      'createdAt':
                          DateTime.now().millisecondsSinceEpoch,
                    });
                  }
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to create supplier login: $e'),
                    ),
                  );
                }

                if (!mounted) return;
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showEditSupplierDialog(BuildContext context, SupplierModel supplier) {
    final nameController = TextEditingController(text: supplier.name);
    final addressController = TextEditingController(text: supplier.address);
    final mobileController = TextEditingController(text: supplier.mobile);

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Edit Supplier'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _customTextField(nameController, 'Supplier Name'),
                const SizedBox(height: 10),
                _customTextField(addressController, 'Address'),
                const SizedBox(height: 10),
                _customTextField(mobileController, 'Mobile No', isNumber: true),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (supplier.id == null) {
                  Navigator.pop(context);
                  return;
                }
                final updated = SupplierModel(
                  id: supplier.id,
                  name: nameController.text.trim(),
                  address: addressController.text.trim(),
                  mobile: mobileController.text.trim(),
                  password: supplier.password,
                );
                Provider.of<CompanyProvider>(context, listen: false)
                    .updateSupplier(supplier.id!, updated);
                Navigator.pop(context);
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _showViewSupplierDialog(BuildContext context, SupplierModel supplier) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('View Supplier'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Name: ${supplier.name}'),
              const SizedBox(height: 8),
              Text('Address: ${supplier.address}'),
              const SizedBox(height: 8),
              Text('Mobile: ${supplier.mobile}'),
              const SizedBox(height: 8),
              Text('Password: ${supplier.password}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (supplier.id == null) {
                  Navigator.pop(context);
                  return;
                }
                final newPassword = _generatePassword();
                final updated = SupplierModel(
                  id: supplier.id,
                  name: supplier.name,
                  address: supplier.address,
                  mobile: supplier.mobile,
                  password: newPassword,
                );
                await Provider.of<CompanyProvider>(context, listen: false)
                    .updateSupplier(supplier.id!, updated);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Password reset to: $newPassword'),
                  ),
                );
                Navigator.pop(context);
              },
              child: const Text('Reset Password'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteSupplierConfirmation(
    BuildContext context,
    SupplierModel supplier,
  ) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Delete Supplier'),
          content: Text("Are you sure you want to delete '${supplier.name}'?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (supplier.id != null) {
                  Provider.of<CompanyProvider>(context, listen: false)
                      .deleteSupplier(supplier.id!);
                }
                Navigator.pop(context);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  String _generatePassword() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rand = Random();
    return List.generate(8, (_) => chars[rand.nextInt(chars.length)]).join();
  }
}
