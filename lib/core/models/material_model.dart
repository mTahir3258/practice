class MaterialModel {
  String id;
  String name;
  String code; // optional short code
  String unit; // "kg" or "unit" etc.
  double plasticQty; // plastic qty per item (if applicable)
  Map<String, dynamic>? metadata; // extensible fields

  MaterialModel({
    required this.id,
    required this.name,
    required this.code,
    required this.unit,
    this.plasticQty = 0.0,
    this.metadata,
  });

  factory MaterialModel.fromMap(String id, Map<dynamic, dynamic> map) {
    return MaterialModel(
      id: id,
      name: map['name'] ?? '',
      code: map['code'] ?? '',
      unit: map['unit'] ?? 'unit',
      plasticQty: (map['plasticQty'] ?? 0).toDouble(),
      metadata: map['metadata'] != null
          ? Map<String, dynamic>.from(map['metadata'])
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'code': code,
    'unit': unit,
    'plasticQty': plasticQty,
    'metadata': metadata ?? {},
  };
}
