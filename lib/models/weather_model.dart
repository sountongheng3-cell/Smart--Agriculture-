class WeatherModel {
  final String cityName;
  final double temperature;
  final String description;
  final double windSpeed;
  final int humidity;

  WeatherModel({
    required this.cityName,
    required this.temperature,
    required this.description,
    required this.windSpeed,
    required this.humidity,
  });

  // Convert JSON to Object
  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      cityName: json['name'] ?? '',

      temperature: (json['main']['temp'] ?? 0).toDouble(),

      description: json['weather'][0]['description'] ?? '',

      windSpeed: (json['wind']['speed'] ?? 0).toDouble(),

      humidity: json['main']['humidity'] ?? 0,
    );
  }

  // Convert Object to JSON
  Map<String, dynamic> toJson() {
    return {
      'cityName': cityName,
      'temperature': temperature,
      'description': description,
      'windSpeed': windSpeed,
      'humidity': humidity,
    };
  }
}
