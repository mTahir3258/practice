// import 'package:flutter/material.dart';
// import 'package:inward_outward_management/core/models/material_model.dart';
// import 'package:provider/provider.dart';
// import 'dart:math';

// class MaterialInputScreen extends StatefulWidget {
//   @override
//   State<MaterialInputScreen> createState() => _MaterialInputScreenState();
// }

// class _MaterialInputScreenState extends State<MaterialInputScreen> {
//   MaterialModel? selectedMaterial;
//   List<TextEditingController> qtyControllers = [TextEditingController()];

//   double totalQty = 0;
//   double totalWeight = 0;

//   @override
//   Widget build(BuildContext context) {
//     final materialProvider = Provider.of<MaterialProvider>(context);

//     return Scaffold(
//       appBar: AppBar(title: const Text("Material Entry")),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             // ==============================
//             //     MATERIAL DROPDOWN
//             // ==============================
//             Row(
//               children: [
//                 Expanded(
//                   child: DropdownButtonFormField<MaterialModel>(
//                     decoration: const InputDecoration(
//                       labelText: "Select Material",
//                     ),
//                     items: materialProvider.materials.map((m) {
//                       return DropdownMenuItem(value: m, child: Text(m.name));
//                     }).toList(),
//                     onChanged: (value) {
//                       setState(() {
//                         selectedMaterial = value;
//                         calculateTotal();
//                       });
//                     },
//                   ),
//                 ),

//                 // ADD MATERIAL BUTTON
//                 IconButton(
//                   icon: const Icon(Icons.add_circle, color: Colors.green),
//                   onPressed: () => openAddEditMaterialDialog(context),
//                 ),

//                 // EDIT MATERIAL BUTTON
//                 if (selectedMaterial != null)
//                   IconButton(
//                     icon: const Icon(Icons.edit, color: Colors.blue),
//                     onPressed: () => openAddEditMaterialDialog(
//                       context,
//                       material: selectedMaterial,
//                     ),
//                   ),
//               ],
//             ),

//             const SizedBox(height: 20),

//             const Text(
//               "Enter Quantity in Parts",
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//             ),

//             const SizedBox(height: 10),

//             // ==============================
//             //     QUANTITY SPLIT FIELDS
//             // ==============================
//             Expanded(
//               child: ListView.builder(
//                 itemCount: qtyControllers.length,
//                 itemBuilder: (context, index) {
//                   return Row(
//                     children: [
//                       Expanded(
//                         child: TextField(
//                           controller: qtyControllers[index],
//                           keyboardType: TextInputType.number,
//                           decoration: InputDecoration(
//                             labelText: "Quantity ${index + 1}",
//                           ),
//                           onChanged: (_) => calculateTotal(),
//                         ),
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.delete, color: Colors.red),
//                         onPressed: () {
//                           qtyControllers.removeAt(index);
//                           calculateTotal();
//                         },
//                       ),
//                     ],
//                   );
//                 },
//               ),
//             ),

//             // ADD NEW QUANTITY FIELD
//             ElevatedButton.icon(
//               onPressed: () {
//                 qtyControllers.add(TextEditingController());
//                 setState(() {});
//               },
//               icon: const Icon(Icons.add),
//               label: const Text("Add More Quantity"),
//             ),

//             const SizedBox(height: 20),

//             // ==============================
//             //     TOTAL DISPLAY
//             // ==============================
//             Text(
//               "Total Quantity: $totalQty",
//               style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             Text(
//               "Total Weight: $totalWeight ${selectedMaterial?.unit ?? ''}",
//               style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Calculate Sum & Weight
//   void calculateTotal() {
//     totalQty = 0;

//     for (var controller in qtyControllers) {
//       final value = double.tryParse(controller.text) ?? 0;
//       totalQty += value;
//     }

//     if (selectedMaterial != null) {
//       totalWeight = selectedMaterial!.weightPerUnit * totalQty;
//     } else {
//       totalWeight = 0;
//     }

//     setState(() {});
//   }

//   // ==============================
//   //      ADD / EDIT MATERIAL FORM
//   // ==============================
//   void openAddEditMaterialDialog(
//     BuildContext context, {
//     MaterialModel? material,
//   }) {
//     final nameController = TextEditingController(text: material?.name ?? "");
//     final weightController = TextEditingController(
//       text: material?.weightPerUnit.toString() ?? "",
//     );
//     final unitController = TextEditingController(text: material?.unit ?? "");

//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text(material == null ? "Add Material" : "Edit Material"),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               TextField(
//                 controller: nameController,
//                 decoration: const InputDecoration(labelText: "Name"),
//               ),
//               TextField(
//                 controller: weightController,
//                 decoration: const InputDecoration(labelText: "Weight Per Unit"),
//                 keyboardType: TextInputType.number,
//               ),
//               TextField(
//                 controller: unitController,
//                 decoration: const InputDecoration(labelText: "Unit"),
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text("Cancel"),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 final model = MaterialModel(
//                   id: material?.id ?? Random().nextInt(99999).toString(),
//                   name: nameController.text,
//                   weightPerUnit: double.tryParse(weightController.text) ?? 0,
//                   unit: unitController.text,
//                 );

//                 final provider = Provider.of<MaterialProvider>(
//                   context,
//                   listen: false,
//                 );

//                 if (material == null) {
//                   provider.addMaterial(model);
//                 } else {
//                   provider.updateMaterial(material!.id, model);
//                 }

//                 Navigator.pop(context);
//               },
//               child: const Text("Save"),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
