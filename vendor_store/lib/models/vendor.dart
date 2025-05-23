import 'dart:convert';

class Vendor {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String address;
  final String role;
  final String password;
  final String token;
  final String? storeImage;
  final String? storeDescription;

  Vendor({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.address,
    required this.role,
    required this.password,
    required this.token,
     this.storeImage,
    this.storeDescription,
  });

  // Chuyển đổi từ Object sang Map (Gửi API)
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      '_id': id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'address': address,
      'role': role,
      'password': password,
      'token':token,
      'storeImage':storeImage,
      'storeDescription':storeDescription,
    };
  }

  // Chuyển đổi từ Map sang JSON (Gửi API)
  String toJson() => json.encode(toMap());

  // Chuyển đổi từ Map sang Object (Nhận API)
  factory Vendor.fromJson(Map<String, dynamic> map) {
    return Vendor(
      id: map['_id'] as String? ?? '',
      fullName: map['fullName'] as String? ?? '',
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      address: map['address'] as String? ?? '',
      role: map['role'] as String? ?? '',
      password: map['password'] as String? ?? '',
      token: map['token'] as String? ?? '',
      storeImage: map['storeImage'] as String? ?? '',
      storeDescription: map['storeDescription'] as String? ?? '',



    );
  }

  // Chuyển đổi từ JSON sang Object (Nhận API)
  factory Vendor.fromJsonString(String source) => Vendor.fromJson(json.decode(source) as Map<String, dynamic>);
}
