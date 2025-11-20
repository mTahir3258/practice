class CustomerModel {
  final String? id;
  final String name;
  final String address;
  final String mobile;
  final String password;

  CustomerModel({
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

  factory CustomerModel.fromMap(Map<String, dynamic> data, String id) {
    return CustomerModel(
      id: id,
      name: data['name']?.toString() ?? '',
      address: data['address']?.toString() ?? '',
      mobile: data['mobile']?.toString() ?? '',
      password: data['password']?.toString() ?? '',
    );
  }
}
