import 'dart:convert';

class Vendor {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String address;
  final String? storeImage;
  final String password;

  Vendor({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.address,
     this.storeImage,
    required this.password,
  });

  // Chuyen doi doi tuong Vendor thanh Map<String, dynamic>
  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'address': address,
      'storeImage': storeImage,
      'password': password,
    };
  }

  // Tao doi tuong Vendor tu Map<String, dynamic>
  factory Vendor.fromMap(Map<String, dynamic> map) {
    return Vendor(
      id: map['_id']?.toString() ?? '',
      fullName: map['fullName']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      storeImage: map['storeImage']?.toString() ?? '',
      address: map['address']?.toString() ?? '',
      password: map['password']?.toString() ?? '',
    );
  }

  // Chuyen doi doi tuong Vendor thanh chuoi JSON
  String toJson() => jsonEncode(toMap());

  // Tao doi tuong Vendor tu chuoi JSON
  factory Vendor.fromJson(String source) =>
      Vendor.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
