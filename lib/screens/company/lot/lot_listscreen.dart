import 'package:flutter/material.dart';
import 'package:inward_outward_management/providers/lot_provider.dart';
import 'package:inward_outward_management/screens/company/lot/add_edit_lotscreen.dart';
import 'package:inward_outward_management/utils/app_colors.dart';
import 'package:inward_outward_management/utils/responsive.dart';
import 'package:inward_outward_management/widgets/app_scaffold.dart';
import 'package:provider/provider.dart';

class LotListScreen extends StatefulWidget {
  const LotListScreen({super.key});

  @override
  State<LotListScreen> createState() => _LotListScreenState();
}

class _LotListScreenState extends State<LotListScreen> {
  @override
  void initState() {
    super.initState();

    // Load lots
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LotProvider>(context, listen: false).loadLots();
    });
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<LotProvider>(context);
    final r = Responsive(context);

    return AppScaffold(
      title: 'Lot Master',
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryGreen,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChangeNotifierProvider.value(
                value: prov,
                child: const AddEditLotScreen(),
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
              itemCount: prov.lots.length,
              itemBuilder: (context, i) {
                final lot = prov.lots[i];

                return Card(
                  color: AppColors.greyBackground,
                  margin: EdgeInsets.only(bottom: r.hp(1.5)),
                  child: ListTile(
                    title: Text(
                      'Lot: ${lot['lotName']}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: r.sp(12),
                        color: AppColors.textLight,
                      ),
                    ),
                    subtitle: Text(
                      'Material: ${lot['materialName']}\n'
                      'Boxes: ${lot['boxCount']}  |  Weight: ${lot['weight']} kg',
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
                                child: AddEditLotScreen(existing: lot),
                              ),
                            ),
                          );
                        } else {
                          prov.deleteLot(lot['lotId']);
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
