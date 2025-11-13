class SupplierBill {
  String id;
  String challanId;
  String supplierId;
  String companyId;
  double amount;
  int createdAt;
  String status; // unpaid, paid, partially_paid
  Map<String, dynamic>? metadata;

  SupplierBill({
    required this.id,
    required this.challanId,
    required this.supplierId,
    required this.companyId,
    required this.amount,
    required this.createdAt,
    this.status = 'unpaid',
    this.metadata,
  });

  factory SupplierBill.fromMap(String id, Map<dynamic, dynamic> map) {
    return SupplierBill(
      id: id,
      challanId: map['challanId'] ?? '',
      supplierId: map['supplierId'] ?? '',
      companyId: map['companyId'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      createdAt: map['createdAt'] ?? 0,
      status: map['status'] ?? 'unpaid',
      metadata: map['metadata'] != null
          ? Map<String, dynamic>.from(map['metadata'])
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
    'challanId': challanId,
    'supplierId': supplierId,
    'companyId': companyId,
    'amount': amount,
    'createdAt': createdAt,
    'status': status,
    'metadata': metadata ?? {},
  };
}
