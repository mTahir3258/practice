class UnitModel {
  final String? id;
  final String name;
  final String status; // e.g. active / inactive

  UnitModel({
    this.id,
    required this.name,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'status': status,
    };
  }

  factory UnitModel.fromMap(Map<String, dynamic> data, String id) {
    return UnitModel(
      id: id,
      name: data['name'] ?? '',
      status: data['status'] ?? '',
    );
  }
}
