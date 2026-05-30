import '../core/constants/api_urls.dart';
import '../models/product_model.dart';
import 'api_service.dart';

class ProductService {
  static Future<List<ProductModel>> getProducts() async {
    final response = await ApiService.getRequest(ApiUrls.products);

    List data = response['products'];

    return data.map((json) {
      return ProductModel(
        id: json['id'],
        name: json['title'],
        image: json['thumbnail'],
        price: (json['price'] as num).toDouble(),
      );
    }).toList();
  }
}
