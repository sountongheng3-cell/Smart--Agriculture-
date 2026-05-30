import 'package:flutter/material.dart';

import '../models/disease_model.dart';
import '../services/disease_service.dart';

class DiseaseProvider extends ChangeNotifier {
  bool _isLoading = false;

  List<DiseaseModel> _diseases = [];

  bool get isLoading => _isLoading;

  List<DiseaseModel> get diseases => _diseases;

  // Fetch Diseases
  Future<void> fetchDiseases() async {
    _isLoading = true;
    notifyListeners();

    try {
      _diseases = await DiseaseService.getDiseases();
    } catch (e) {
      debugPrint(e.toString());
    }

    _isLoading = false;
    notifyListeners();
  }
}
