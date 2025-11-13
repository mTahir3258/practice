class MaterialRequest {
  String id;
  String supplierId;
  String companyId;
  String status; // requested, confirmed, rejected
  Map<String, dynamic> items; // materialId -> { qty, unit, remarks }
  int createdAt;

  MaterialRequest({
    required this.id,
    required this.supplierId,
    required this.companyId,
    required this.status,
    required this.items,
    required this.createdAt,
  });

  factory MaterialRequest.fromMap(String id, Map<dynamic, dynamic> map) {
    return MaterialRequest(
      id: id,
      supplierId: map['supplierId'] ?? '',
      companyId: map['companyId'] ?? '',
      status: map['status'] ?? 'requested',
      items: Map<String, dynamic>.from(map['items'] ?? {}),
      createdAt: map['createdAt'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
    'supplierId': supplierId,
    'companyId': companyId,
    'status': status,
    'items': items,
    'createdAt': createdAt,
  };
}
