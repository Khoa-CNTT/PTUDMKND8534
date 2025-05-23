class Product {
  final String id;
  final String productName;
  final double productPrice;
  final int quantity;
  final String description;
  final String category;
  final String vendorId;
  final String fullName;
  final String subCategory;
  final List<String> images;
  final bool popular;
  final bool recommend;
  final double averageRating;
  final int totalRatings;

  Product({
    required this.id,
    required this.productName,
    required this.productPrice,
    required this.quantity,
    required this.description,
    required this.category,
    required this.vendorId,
    required this.fullName,
    required this.subCategory,
    required this.images,
    required this.popular,
    required this.recommend,
    required this.averageRating,
    required this.totalRatings,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'],
      productName: json['productName'],
      productPrice: json['productPrice'].toDouble(),
      quantity: json['quantity'],
      description: json['description'],
      category: json['category'],
      vendorId: json['vendorId'],
      fullName: json['fullName'],
      subCategory: json['subCategory'],
      images: List<String>.from(json['images']),
      popular: json['popular'] ?? false,
      recommend: json['recommend'] ?? false,
      averageRating: (json['averageRating'] ?? 0).toDouble(),
      totalRatings: json['totalRatings'] ?? 0,
    );
  }
}