import 'dart:math';

import 'package:flutter/material.dart';
import 'package:inward_outward_management/core/models/customer_model.dart';
import 'package:inward_outward_management/providers/company_provider.dart';
import 'package:inward_outward_management/utils/app_colors.dart';
import 'package:inward_outward_management/widgets/app_form_field.dart';
import 'package:inward_outward_management/widgets/app_scaffold.dart';
import 'package:provider/provider.dart';

class CustomerMasterScreen extends StatefulWidget {
  const CustomerMasterScreen({super.key});

  @override
  State<CustomerMasterScreen> createState() => _CustomerMasterScreenState();
}

class _CustomerMasterScreenState extends State<CustomerMasterScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () =>
          Provider.of<CompanyProvider>(context, listen: false).loadCustomers(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CompanyProvider>(context);

    return AppScaffold(
      title: 'Customer Master',
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
                              'Customer Master',
                              style: TextStyle(
                                color: AppColors.textLight,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: const Text(
                              'Manage customers and perform Add / Edit / View / Delete',
                              style: TextStyle(
                                color: AppColors.textLight,
                                fontSize: 12,
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.add,
                                  color: AppColors.primaryGreen),
                              onPressed: () => _showAddCustomerDialog(context),
                            ),
                          ),
                          const SizedBox(height: 8),
                          _customerList(provider),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _customerList(CompanyProvider provider) {
    if (provider.customers.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text(
          'No Customers Added Yet',
          style: TextStyle(color: AppColors.textLight),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: provider.customers.length,
      itemBuilder: (context, index) {
        final customer = provider.customers[index];
        return Card(
          color: AppColors.greyBackground,
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: Padding(
            padding: const EdgeInsets.all(12.0),


            child:
             Row(

              mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: [

                 Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.name,
                      style: const TextStyle(
                        color: AppColors.textLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Mobile: ${customer.mobile}',
                      style: const TextStyle(color: AppColors.textLight),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Address: ${customer.address}',
                      style: const TextStyle(color: AppColors.textLight),
                    ),
                    const SizedBox(height: 8),

                  ]
                 ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                       IconButton( icon: Icon(Icons.visibility,color:AppColors.textLight,),
                            onPressed: () =>
                              _showViewCustomerDialog(context, customer),),
                        IconButton(
                          icon: const Icon(
                            Icons.edit,
                            color: AppColors.primaryGreen,
                          ),
                          onPressed: () =>
                              _showEditCustomerDialog(context, customer),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: AppColors.errorRed,
                          ),
                          onPressed: () => _showDeleteCustomerConfirmation(
                            context,
                            customer,
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

  void _showAddCustomerDialog(BuildContext context) {
    final nameController = TextEditingController();
    final addressController = TextEditingController();
    final mobileController = TextEditingController();
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Add Customer'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _customTextField(nameController, 'Customer Name'),
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
              onPressed: () {
                final customer = CustomerModel(
                  name: nameController.text.trim(),
                  address: addressController.text.trim(),
                  mobile: mobileController.text.trim(),
                  password: passwordController.text.trim(),
                );
                Provider.of<CompanyProvider>(context, listen: false)
                    .addCustomer(customer);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showEditCustomerDialog(BuildContext context, CustomerModel customer) {
    final nameController = TextEditingController(text: customer.name);
    final addressController = TextEditingController(text: customer.address);
    final mobileController = TextEditingController(text: customer.mobile);

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Edit Customer'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _customTextField(nameController, 'Customer Name'),
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
                if (customer.id == null) {
                  Navigator.pop(context);
                  return;
                }
                final updated = CustomerModel(
                  id: customer.id,
                  name: nameController.text.trim(),
                  address: addressController.text.trim(),
                  mobile: mobileController.text.trim(),
                  password: customer.password,
                );
                Provider.of<CompanyProvider>(context, listen: false)
                    .updateCustomer(customer.id!, updated);
                Navigator.pop(context);
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _showViewCustomerDialog(BuildContext context, CustomerModel customer) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('View Customer'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Name: ${customer.name}'),
              const SizedBox(height: 8),
              Text('Address: ${customer.address}'),
              const SizedBox(height: 8),
              Text('Mobile: ${customer.mobile}'),
              const SizedBox(height: 8),
              Text('Password: ${customer.password}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (customer.id == null) {
                  Navigator.pop(context);
                  return;
                }
                final newPassword = _generatePassword();
                final updated = CustomerModel(
                  id: customer.id,
                  name: customer.name,
                  address: customer.address,
                  mobile: customer.mobile,
                  password: newPassword,
                );
                await Provider.of<CompanyProvider>(context, listen: false)
                    .updateCustomer(customer.id!, updated);
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

  void _showDeleteCustomerConfirmation(
    BuildContext context,
    CustomerModel customer,
  ) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Delete Customer'),
          content: Text("Are you sure you want to delete '${customer.name}'?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (customer.id != null) {
                  Provider.of<CompanyProvider>(context, listen: false)
                      .deleteCustomer(customer.id!);
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
