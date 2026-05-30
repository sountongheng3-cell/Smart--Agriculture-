import '../core/constants/api_urls.dart';
import '../models/weather_model.dart';
import 'api_service.dart';

class WeatherService {
  static Future<WeatherModel> getWeather() async {
    final response = await ApiService.getRequest(ApiUrls.weather);

    return WeatherModel(
      cityName: response['name'] ?? '',
      temperature: (response['main']['temp'] ?? 0).toDouble(),
      description: response['weather'][0]['description'] ?? '',
      windSpeed: (response['wind']['speed'] ?? 0).toDouble(),
      humidity: response['main']['humidity'] ?? 0,
    );
  }
}
