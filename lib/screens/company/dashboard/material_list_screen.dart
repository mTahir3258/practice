import 'package:flutter/material.dart';
import 'package:inward_outward_management/core/models/material_model.dart';
import 'package:inward_outward_management/providers/company_provider.dart';
import 'package:inward_outward_management/utils/app_colors.dart';
import 'package:inward_outward_management/widgets/app_form_field.dart';
import 'package:inward_outward_management/widgets/app_scaffold.dart';
import 'package:provider/provider.dart';

class MaterialListScreen extends StatefulWidget {
  const MaterialListScreen({super.key});

  @override
  State<MaterialListScreen> createState() => _MaterialListScreenState();
}

class _MaterialListScreenState extends State<MaterialListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final provider =
          Provider.of<CompanyProvider>(context, listen: false);
      provider.loadMaterials();
      provider.loadUnits();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CompanyProvider>(context);

    return AppScaffold(
      title: 'Material Master',
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Card(
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
                            Icons.category_outlined,
                            color: AppColors.textDark,
                          ),
                        ),
                        title: const Text(
                          'Material Master',
                          style: TextStyle(
                            color: AppColors.textLight,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: const Text(
                          'Manage materials and perform Add / Edit / View / Delete',
                          style: TextStyle(
                            color: AppColors.textLight,
                            fontSize: 12,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.add,
                            color: AppColors.primaryGreen,
                          ),
                          onPressed: () => _showAddMaterialDialog(context),
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (provider.materials.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'No Materials Added Yet',
                            style: TextStyle(color: AppColors.textLight),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: provider.materials.length,
                          itemBuilder: (context, index) {
                            final material = provider.materials[index];
                            return Card(
                              color: AppColors.greyBackground,
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          material.name,
                                          style: const TextStyle(
                                            color: AppColors.textLight,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Type: ${material.type.isNotEmpty ? material.type : '-'}',
                                          style: const TextStyle(
                                            color: AppColors.textLight,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Status: ${material.status.isNotEmpty ? material.status : '-'}',
                                          style: const TextStyle(
                                            color: AppColors.textLight,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Unit: ${material.unit.isNotEmpty ? material.unit : '-'}',
                                          style: const TextStyle(
                                            color: AppColors.textLight,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        TextButton(
                                          onPressed: () {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Submitted material: ${material.name}',
                                                ),
                                              ),
                                            );
                                          },
                          child: const Text('Submit' ,style: TextStyle(fontSize: 14,fontWeight: FontWeight.w600,color: AppColors.primaryGreen),),
                                          
                                        ),
                                      ],
                                    ),

                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                            Icons.edit,
                                            color: AppColors.primaryGreen,
                                          ),
                                          onPressed: () =>
                                              _showEditMaterialDialog(
                                                context,
                                                material,
                                              ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.visibility,
                                            color: AppColors.textLight,
                                          ),
                                          onPressed: () =>
                                              _showViewMaterialDialog(
                                                context,
                                                material,
                                              ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: AppColors.errorRed,
                                          ),
                                          onPressed: () =>
                                              _showDeleteConfirmation(
                                                context,
                                                material,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),
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

  void _showAddMaterialDialog(BuildContext context) {
    final nameController = TextEditingController();
    final typeController = TextEditingController();
    final statusController = TextEditingController(text: 'active');
    String? selectedUnitId;

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            final provider =
                Provider.of<CompanyProvider>(context, listen: false);

            return AlertDialog(
              title: const Text('Add Material'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _customTextField(nameController, 'Material Name'),
                    const SizedBox(height: 10),
                    _customTextField(typeController, 'Type'),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: selectedUnitId,
                      decoration: InputDecoration(
                        labelText: 'Unit',
                        labelStyle:
                            const TextStyle(color: AppColors.textLight),
                        filled: true,
                        fillColor: AppColors.greyBackground,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.primaryGreen,
                            width: 1.5,
                          ),
                        ),
                      ),
                      style: const TextStyle(color: AppColors.textLight),
                      dropdownColor: AppColors.greyBackground,
                      items: provider.units
                          .map(
                            (u) => DropdownMenuItem<String>(
                              value: u.id ?? u.name,
                              child: Text(u.name),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        setState(() => selectedUnitId = val);
                      },
                    ),
                    const SizedBox(height: 10),
                    _customTextField(
                      statusController,
                      'Status (e.g. active/inactive)',
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.pop(ctx),
                ),
                ElevatedButton(
                  child: const Text('Save'),
                  onPressed: () {
                    if (selectedUnitId == null || selectedUnitId!.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please select a unit'),
                        ),
                      );
                      return;
                    }

                    String unitName = '';
                    for (final u in provider.units) {
                      final key = u.id ?? u.name;
                      if (key == selectedUnitId) {
                        unitName = u.name;
                        break;
                      }
                    }

                    final material = MaterialModel(
                      name: nameController.text.trim(),
                      unit: unitName,
                      rate: 0,
                      type: typeController.text.trim(),
                      status: statusController.text.trim(),
                    );

                    Provider.of<CompanyProvider>(
                      context,
                      listen: false,
                    ).addMaterial(material);

                    Navigator.pop(ctx);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditMaterialDialog(BuildContext context, MaterialModel material) {
    final nameController = TextEditingController(text: material.name);
    final typeController = TextEditingController(text: material.type);
    final statusController = TextEditingController(
      text: material.status.isNotEmpty ? material.status : 'active',
    );
    final unitController = TextEditingController(text: material.unit);

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Edit Material'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _customTextField(nameController, 'Material Name'),
                const SizedBox(height: 10),
                _customTextField(typeController, 'Type'),
                const SizedBox(height: 10),
                _customTextField(
                  statusController,
                  'Status (e.g. active/inactive)',
                ),
                const SizedBox(height: 10),
                _customTextField(unitController, 'Unit'),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text('Update'),
              onPressed: () {
                final updatedMaterial = MaterialModel(
                  id: material.id,
                  name: nameController.text.trim(),
                  unit: unitController.text.trim(),
                  rate: material.rate,
                  type: typeController.text.trim(),
                  status: statusController.text.trim(),
                );

                Provider.of<CompanyProvider>(
                  context,
                  listen: false,
                ).updateMaterial(material.id!, updatedMaterial);

                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, MaterialModel material) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Delete Material'),
          content: Text("Are you sure you want to delete '${material.name}'?"),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text('Delete'),
              onPressed: () {
                Provider.of<CompanyProvider>(
                  context,
                  listen: false,
                ).deleteMaterial(material.id!);

                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _showViewMaterialDialog(BuildContext context, MaterialModel material) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('View Material'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Name: ${material.name}'),
              const SizedBox(height: 8),
              Text('Type: ${material.type.isNotEmpty ? material.type : '-'}'),
              const SizedBox(height: 8),
              Text(
                'Status: ${material.status.isNotEmpty ? material.status : '-'}',
              ),
              const SizedBox(height: 8),
              Text('Unit: ${material.unit}'),
              const SizedBox(height: 8),
              Text('Rate: ${material.rate}'),
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
}
