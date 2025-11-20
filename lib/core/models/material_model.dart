class MaterialModel {
  final String? id;
  final String name;
  final String unit; // kg, pcs, box etc
  final double rate;
  final String type; // e.g. raw, finished etc
  final String status; // e.g. active / inactive

  MaterialModel({
    this.id,
    required this.name,
    required this.unit,
    required this.rate,
    this.type = '',
    this.status = '',
  });

  // Convert to Map (for Firebase)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'unit': unit,
      'rate': rate,
      'type': type,
      'status': status,
    };
  }

  // Convert From Firebase
  factory MaterialModel.fromMap(Map<String, dynamic> data, String id) {
    return MaterialModel(
      id: id,
      name: data['name'] ?? '',
      unit: data['unit'] ?? '',
      rate: (data['rate'] ?? 0).toDouble(),
      type: data['type']?.toString() ?? '',
      status: data['status']?.toString() ?? '',
    );
  }
}
