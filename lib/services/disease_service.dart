import '../core/constants/api_urls.dart';
import '../models/disease_model.dart';
import 'api_service.dart';

class DiseaseService {
  static Future<List<DiseaseModel>> getDiseases() async {
    final response = await ApiService.getRequest(ApiUrls.diseases);

    // dummyjson wraps results: { "products": [...], "total": 194, ... }
    // If your real backend returns a plain list [], it still works.
    List data;
    if (response is Map && response.containsKey('products')) {
      data = response['products'] as List;
    } else if (response is List) {
      data = response;
    } else {
      data = [];
    }

    return data.map((json) => DiseaseModel.fromJson(json)).toList();
  }
}
