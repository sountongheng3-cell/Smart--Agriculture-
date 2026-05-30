import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class WeatherScreen extends StatelessWidget {
  const WeatherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,

      appBar: AppBar(title: const Text('Weather')),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
            // Weather Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),

              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.blue, Colors.lightBlueAccent],
                ),

                borderRadius: BorderRadius.circular(25),
              ),

              child: Column(
                children: const [
                  Icon(Icons.cloud, size: 80, color: Colors.white),

                  SizedBox(height: 15),

                  Text(
                    '28°C',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 10),

                  Text(
                    'Cloudy Weather',
                    style: TextStyle(color: Colors.white70, fontSize: 20),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // Weather Details
            Row(
              children: [
                Expanded(
                  child: _buildWeatherItem(
                    icon: Icons.water_drop,
                    title: 'Humidity',
                    value: '70%',
                  ),
                ),

                const SizedBox(width: 15),

                Expanded(
                  child: _buildWeatherItem(
                    icon: Icons.air,
                    title: 'Wind',
                    value: '12 km/h',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                  child: _buildWeatherItem(
                    icon: Icons.thermostat,
                    title: 'Feels Like',
                    value: '30°C',
                  ),
                ),

                const SizedBox(width: 15),

                Expanded(
                  child: _buildWeatherItem(
                    icon: Icons.wb_sunny,
                    title: 'UV Index',
                    value: '5',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Weather Item
  Widget _buildWeatherItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(20),

        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),

            blurRadius: 5,

            offset: const Offset(0, 3),
          ),
        ],
      ),

      child: Column(
        children: [
          Icon(icon, size: 40, color: AppColors.primaryColor),

          const SizedBox(height: 10),

          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 5),

          Text(title, style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }
}
