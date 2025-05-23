import 'dart:convert';

class BannerModel {
  final String id;
  final String image;

  BannerModel({required this.id, required this.image});

  // Chuyển đổi từ Object sang Map
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      // Không gửi 'id' vì backend tự tạo '_id'
      'image': image,
    };
  }

  // Chuyển đổi từ Map sang Object
  factory BannerModel.fromMap(Map<String, dynamic> map) {
    print('BannerModel: Parsing map: $map'); // Log dữ liệu thô
    return BannerModel(
      id: map['_id']?.toString() ?? '', // Ánh xạ '_id' thay vì 'id'
      image: map['image']?.toString() ?? '',
    );
  }

  // Chuyển đổi từ Object sang chuỗi JSON
  String toJson() => json.encode(toMap());

  // Chuyển đổi từ chuỗi JSON hoặc Map sang Object
  factory BannerModel.fromJson(dynamic source) {
    print('BannerModel: Parsing JSON: $source'); // Log dữ liệu JSON
    if (source is String) {
      return BannerModel.fromMap(json.decode(source) as Map<String, dynamic>);
    } else if (source is Map<String, dynamic>) {
      return BannerModel.fromMap(source);
    } else {
      throw Exception("Invalid JSON format for BannerModel");
    }
  }
}