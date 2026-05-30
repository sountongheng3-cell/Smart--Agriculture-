import 'package:flutter/material.dart';

import '../models/weather_model.dart';
import '../services/weather_service.dart';

class WeatherProvider extends ChangeNotifier {
  bool _isLoading = false;

  WeatherModel? _weather;

  bool get isLoading => _isLoading;

  WeatherModel? get weather => _weather;

  // Get Weather Data
  Future<void> fetchWeather() async {
    _isLoading = true;
    notifyListeners();

    try {
      _weather = await WeatherService.getWeather();
    } catch (e) {
      debugPrint(e.toString());
    }

    _isLoading = false;
    notifyListeners();
  }
}
