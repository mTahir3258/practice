import 'package:flutter/material.dart';
import 'package:inward_outward_management/core/models/material_model.dart';
import 'package:provider/provider.dart';
import '../../providers/company_provider.dart';

class MaterialFormScreen extends StatefulWidget {
  final MaterialModel? material;
  const MaterialFormScreen({this.material, Key? key}) : super(key: key);

  @override
  _MaterialFormScreenState createState() => _MaterialFormScreenState();
}

class _MaterialFormScreenState extends State<MaterialFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _code;
  String _unit = 'unit';
  double _plasticQty = 0.0;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.material != null) {
      _name = widget.material!.name;
      _code = widget.material!.code;
      _unit = widget.material!.unit;
      _plasticQty = widget.material!.plasticQty;
    } else {
      _name = '';
      _code = '';
      _unit = 'unit';
      _plasticQty = 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<CompanyProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.material != null ? 'Edit Material' : 'Add Material'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _name,
                decoration: InputDecoration(labelText: 'Material name'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Enter name' : null,
                onSaved: (v) => _name = v!.trim(),
              ),
              TextFormField(
                initialValue: _code,
                decoration: InputDecoration(labelText: 'Code (optional)'),
                onSaved: (v) => _code = v?.trim() ?? '',
              ),
              DropdownButtonFormField<String>(
                value: _unit,
                items: ['unit', 'kg']
                    .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                    .toList(),
                onChanged: (v) => setState(() => _unit = v ?? 'unit'),
                decoration: InputDecoration(labelText: 'Unit'),
              ),
              TextFormField(
                initialValue: _plasticQty.toString(),
                decoration: InputDecoration(
                  labelText: 'Plastic Qty per item (if any)',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onSaved: (v) => _plasticQty = double.tryParse(v ?? '0') ?? 0.0,
              ),
              SizedBox(height: 16),
              _saving
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      child: Text('Save'),
                      onPressed: () async {
                        if (!_formKey.currentState!.validate()) return;
                        _formKey.currentState!.save();
                        setState(() => _saving = true);
                        final mat = MaterialModel(
                          id: widget.material?.id ?? '',
                          name: _name,
                          code: _code,
                          unit: _unit,
                          plasticQty: _plasticQty,
                        );
                        try {
                          if (widget.material == null) {
                            await prov.addMaterial(mat);
                          } else {
                            await prov.updateMaterial(mat);
                          }
                          Navigator.pop(context);
                        } catch (e) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text('Error: $e')));
                        } finally {
                          setState(() => _saving = false);
                        }
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
