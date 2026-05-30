class ProductModel {
  final int id;
  final String name;
  final String image;
  final double price;

  ProductModel({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? 0,
      name: json['title'] ?? '',
      image: json['thumbnail'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'title': name, 'thumbnail': image, 'price': price};
  }
}
