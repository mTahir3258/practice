import 'package:flutter/material.dart';
import 'package:inward_outward_management/core/models/material_model.dart';
import 'package:provider/provider.dart';
import '../../providers/company_provider.dart';
import '../../widgets/material_tile.dart';
import 'material_form_screen.dart';

class MaterialsListScreen extends StatelessWidget {
  static const routeName = '/company/materials';
  const MaterialsListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<CompanyProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Materials'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => MaterialFormScreen()),
            ),
          ),
        ],
      ),
      body: prov.loading
          ? Center(child: CircularProgressIndicator())
          : prov.materials.isEmpty
          ? Center(child: Text('No materials yet'))
          : ListView.builder(
              itemCount: prov.materials.length,
              itemBuilder: (context, i) {
                final m = prov.materials[i];
                return MaterialTile(
                  material: m,
                  onEdit: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MaterialFormScreen(material: m),
                    ),
                  ),
                  onDelete: () => _confirmDelete(context, prov, m),
                );
              },
            ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    CompanyProvider prov,
    MaterialModel m,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete ${m.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await prov.deleteMaterial(m.id);
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }
}
