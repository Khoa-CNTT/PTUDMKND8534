import 'dart:convert';

class Buyer {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String image;
  final String address;
  final String password;

  Buyer({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.image,
    required this.address,
    required this.password,
  });

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'image': image,
      'address': address,
      'password': password,
    };
  }

  factory Buyer.fromMap(Map<String, dynamic> map) {
    return Buyer(
      id: map['_id']?.toString() ?? '',
      fullName: map['fullName']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      image: map['image']?.toString() ?? '',
      address: map['address']?.toString() ?? '',
      password: map['password']?.toString() ?? '',
    );
  }

  String toJson() => jsonEncode(toMap());

  factory Buyer.fromJson(String source) =>
      Buyer.fromMap(jsonDecode(source) as Map<String, dynamic>);
}