import 'package:flutter/material.dart';
import 'package:inward_outward_management/providers/box_provider.dart';
import 'package:inward_outward_management/screens/company/box/add_edit_boxscreen.dart';
import 'package:inward_outward_management/utils/app_colors.dart';
import 'package:inward_outward_management/utils/responsive.dart';
import 'package:inward_outward_management/widgets/app_scaffold.dart';
import 'package:provider/provider.dart';

class BoxListScreen extends StatefulWidget {
  const BoxListScreen({super.key});

  @override
  State<BoxListScreen> createState() => _BoxListScreenState();
}

class _BoxListScreenState extends State<BoxListScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BoxProvider>(context, listen: false).loadBoxes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<BoxProvider>(context);
    final r = Responsive(context);

    return AppScaffold(
      title: 'Box Master',
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryGreen,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChangeNotifierProvider.value(
                value: prov,
                child: const AddEditBoxScreen(),
              ),
            ),
          );
        },
        child: const Icon(Icons.add, color: AppColors.textDark),
      ),
      body: prov.loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: EdgeInsets.all(r.wp(4)),
              itemCount: prov.boxes.length,
              itemBuilder: (_, i) {
                final box = prov.boxes[i];

                return Card(
                  color: AppColors.greyBackground,
                  margin: EdgeInsets.only(bottom: r.hp(1.5)),
                  child: ListTile(
                    title: Text(
                      '${box['boxType']} Box',
                      style: TextStyle(
                        fontSize: r.sp(13),
                        fontWeight: FontWeight.bold,
                        color: AppColors.textLight,
                      ),
                    ),
                    subtitle: Text(
                      'Material: ${box['materialName']}\n'
                      'Weight: ${box['boxWeight']} kg + Plastic: ${box['plasticWeight']} kg\n'
                      'Total Weight: ${box['totalWeight']} kg',
                      style: const TextStyle(color: AppColors.textLight),
                    ),
                    trailing: PopupMenuButton(
                      color: AppColors.primaryDark,
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'edit', child: Text('Edit')),
                        PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'edit') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChangeNotifierProvider.value(
                                value: prov,
                                child: AddEditBoxScreen(existing: box),
                              ),
                            ),
                          );
                        } else {
                          prov.deleteBox(box['boxId']);
                        }
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
