class ChallanModel {
  String id;
  String supplierId;
  String companyId;
  Map<String, dynamic>
  items; // materialId -> { qty, unit, rate, materialKg, plasticKg, totalCost }
  double totalAmount;
  double totalMaterialKg;
  double totalPlasticKg;
  int createdAt;
  String status; // pending, delivered, billed

  ChallanModel({
    required this.id,
    required this.supplierId,
    required this.companyId,
    required this.items,
    required this.totalAmount,
    required this.totalMaterialKg,
    required this.totalPlasticKg,
    required this.createdAt,
    this.status = 'pending',
  });

  factory ChallanModel.fromMap(String id, Map<dynamic, dynamic> map) {
    return ChallanModel(
      id: id,
      supplierId: map['supplierId'] ?? '',
      companyId: map['companyId'] ?? '',
      items: Map<String, dynamic>.from(map['items'] ?? {}),
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      totalMaterialKg: (map['totalMaterialKg'] ?? 0).toDouble(),
      totalPlasticKg: (map['totalPlasticKg'] ?? 0).toDouble(),
      createdAt: map['createdAt'] ?? 0,
      status: map['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toMap() => {
    'supplierId': supplierId,
    'companyId': companyId,
    'items': items,
    'totalAmount': totalAmount,
    'totalMaterialKg': totalMaterialKg,
    'totalPlasticKg': totalPlasticKg,
    'createdAt': createdAt,
    'status': status,
  };
}
