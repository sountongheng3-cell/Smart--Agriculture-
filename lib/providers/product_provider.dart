import 'package:flutter/material.dart';

import '../models/product_model.dart';
import '../services/product_service.dart';

class ProductProvider extends ChangeNotifier {
  bool _isLoading = false;

  List<ProductModel> _products = [];

  bool get isLoading => _isLoading;

  List<ProductModel> get products => _products;

  // Fetch Products
  Future<void> fetchProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      _products = await ProductService.getProducts();
    } catch (e) {
      debugPrint(e.toString());
    }

    _isLoading = false;
    notifyListeners();
  }
}
