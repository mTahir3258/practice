class SupplierModel {
  final String? id;
  final String name;
  final String address;
  final String mobile;
  final String password;

  SupplierModel({
    this.id,
    required this.name,
    required this.address,
    required this.mobile,
    required this.password,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'mobile': mobile,
      'password': password,
    };
  }

  factory SupplierModel.fromMap(Map<String, dynamic> data, String id) {
    return SupplierModel(
      id: id,
      name: data['name']?.toString() ?? '',
      address: data['address']?.toString() ?? '',
      mobile: data['mobile']?.toString() ?? '',
      password: data['password']?.toString() ?? '',
    );
  }
}
