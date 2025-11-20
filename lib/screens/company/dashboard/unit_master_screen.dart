import 'package:flutter/material.dart';
import 'package:inward_outward_management/core/models/unit_model.dart';
import 'package:inward_outward_management/providers/company_provider.dart';
import 'package:inward_outward_management/utils/app_colors.dart';
import 'package:inward_outward_management/widgets/app_form_field.dart';
import 'package:inward_outward_management/widgets/app_scaffold.dart';
import 'package:inward_outward_management/widgets/primary_button.dart';
import 'package:provider/provider.dart';

class UnitMasterScreen extends StatefulWidget {
  const UnitMasterScreen({super.key});

  @override
  State<UnitMasterScreen> createState() => _UnitMasterScreenState();
}

class _UnitMasterScreenState extends State<UnitMasterScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => Provider.of<CompanyProvider>(context, listen: false).loadUnits(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CompanyProvider>(context);

    return AppScaffold(
      title: 'Unit Master',
      body: SingleChildScrollView(
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
                          Icons.straighten,
                          color: AppColors.textDark,
                        ),
                      ),
                      title: const Text(
                        'Unit Master',
                        style: TextStyle(
                          color: AppColors.textLight,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: const Text(
                        'Manage units, status and perform Add / Edit / View / Delete',
                        style: TextStyle(
                          color: AppColors.textLight,
                          fontSize: 12,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.add,
                            color: AppColors.primaryGreen),
                        onPressed: () => _showAddUnitDialog(context),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _unitList(provider),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _unitList(CompanyProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.units.isEmpty) {
      return const Text(
        'No Units Added Yet',
        style: TextStyle(color: AppColors.textLight),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: provider.units.length,
      itemBuilder: (context, index) {
        final unit = provider.units[index];
        return Card(
          color: AppColors.greyBackground,
          margin: const EdgeInsets.symmetric(vertical: 4),
          
          child: Padding(
            padding: const EdgeInsets.all(12.0),


            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [


                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          unit.name,
                          style: const TextStyle(
                            color: AppColors.textLight,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Status: ${unit.status}',
                          style: const TextStyle(color: AppColors.textLight),
                        ),
                        const SizedBox(height: 8),


                        TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text('Submitted unit: ${unit.name}'),
                              ),
                            );
                          },
                          child: const Text('Submit' ,style: TextStyle(fontSize: 14,fontWeight: FontWeight.w600,color: AppColors.primaryGreen),),
                        ),

                      
                                
                        
                        


                      ]
                    
                    ),
                  ],
                ),
                                    
                    Row(
                      children: [
                        Column(
                          
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: AppColors.primaryGreen,
                              ),
                              onPressed: () =>
                                  _showEditUnitDialog(context, unit),
                            ),
                        
                              IconButton(
                          icon: const Icon(
                            Icons.visibility,
                            color: AppColors.textLight,
                          ),
                          onPressed: () =>
                              _showViewUnitDialog(context, unit),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: AppColors.errorRed,
                          ),
                          onPressed: () => _showDeleteUnitConfirmation(
                            context,
                            unit,
                          ),
                        ),
                                        
                        
                          ],
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

  void _showAddUnitDialog(BuildContext context) {
    final nameController = TextEditingController();
    String status = 'active';

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              title: const Text('Add Unit'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _customTextField(nameController, 'Unit Name'),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: status,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: const [
                      DropdownMenuItem(value: 'active', child: Text('Active')),
                      DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                    ],
                    onChanged: (val) {
                      if (val == null) return;
                      setState(() => status = val);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final unit = UnitModel(
                      name: nameController.text.trim(),
                      status: status,
                    );
                    Provider.of<CompanyProvider>(context, listen: false)
                        .addUnit(unit);
                    Navigator.pop(ctx);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditUnitDialog(BuildContext context, UnitModel unit) {
    final nameController = TextEditingController(text: unit.name);
    String status = unit.status.isNotEmpty ? unit.status : 'active';

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              title: const Text('Edit Unit'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _customTextField(nameController, 'Unit Name'),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: status,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: const [
                      DropdownMenuItem(value: 'active', child: Text('Active')),
                      DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                    ],
                    onChanged: (val) {
                      if (val == null) return;
                      setState(() => status = val);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (unit.id == null) {
                      Navigator.pop(ctx);
                      return;
                    }
                    final updated = UnitModel(
                      id: unit.id,
                      name: nameController.text.trim(),
                      status: status,
                    );
                    Provider.of<CompanyProvider>(context, listen: false)
                        .updateUnit(unit.id!, updated);
                    Navigator.pop(ctx);
                  },
                  child: const Text('Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showViewUnitDialog(BuildContext context, UnitModel unit) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('View Unit'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Name: ${unit.name}'),
              const SizedBox(height: 8),
              Text('Status: ${unit.status}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteUnitConfirmation(BuildContext context, UnitModel unit) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Delete Unit'),
          content: Text("Are you sure you want to delete '${unit.name}'?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (unit.id != null) {
                  Provider.of<CompanyProvider>(context, listen: false)
                      .deleteUnit(unit.id!);
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
}
