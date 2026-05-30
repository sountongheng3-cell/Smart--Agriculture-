import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F7F2),

      appBar: AppBar(
        title: const Text('Agriculture Reports'),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dashboard
            const Text(
              'Farmer Dashboard',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,

              children: const [
                DashboardCard(
                  title: 'Total Farmers',
                  value: '1,250',
                  icon: Icons.people,
                  color: Colors.green,
                ),

                DashboardCard(
                  title: 'Crop Production',
                  value: '520 Ton',
                  icon: Icons.agriculture,
                  color: Colors.orange,
                ),

                DashboardCard(
                  title: 'Diseases Found',
                  value: '38',
                  icon: Icons.health_and_safety,
                  color: Colors.red,
                ),

                DashboardCard(
                  title: 'Market Price',
                  value: '\$350/Ton',
                  icon: Icons.store,
                  color: Colors.blue,
                ),
              ],
            ),

            const SizedBox(height: 30),

            const Text(
              'Monthly Crop Production',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            Container(
              height: 300,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),

              child: BarChart(
                BarChartData(
                  borderData: FlBorderData(show: false),

                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),

                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,

                        getTitlesWidget: (value, meta) {
                          switch (value.toInt()) {
                            case 0:
                              return const Text('Jan');
                            case 1:
                              return const Text('Feb');
                            case 2:
                              return const Text('Mar');
                            case 3:
                              return const Text('Apr');
                            case 4:
                              return const Text('May');
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),

                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [BarChartRodData(toY: 120, color: Colors.green)],
                    ),

                    BarChartGroupData(
                      x: 1,
                      barRods: [BarChartRodData(toY: 150, color: Colors.green)],
                    ),

                    BarChartGroupData(
                      x: 2,
                      barRods: [BarChartRodData(toY: 180, color: Colors.green)],
                    ),

                    BarChartGroupData(
                      x: 3,
                      barRods: [BarChartRodData(toY: 220, color: Colors.green)],
                    ),

                    BarChartGroupData(
                      x: 4,
                      barRods: [BarChartRodData(toY: 260, color: Colors.green)],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              'Weather Analysis',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            const WeatherCard(),

            const SizedBox(height: 30),

            const Text(
              'Production Statistics',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            const StatisticsTile(title: 'Rice Production', value: '320 Ton'),

            const StatisticsTile(title: 'Corn Production', value: '140 Ton'),

            const StatisticsTile(title: 'Vegetables', value: '60 Ton'),

            const StatisticsTile(title: 'Fruit Production', value: '90 Ton'),
          ],
        ),
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const DashboardCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),

      child: Padding(
        padding: const EdgeInsets.all(15),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Icon(icon, color: color, size: 40),

            const SizedBox(height: 10),

            Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 5),

            Text(title),
          ],
        ),
      ),
    );
  }
}

class WeatherCard extends StatelessWidget {
  const WeatherCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),

      child: const ListTile(
        leading: Icon(Icons.cloud, size: 40, color: Colors.blue),

        title: Text('Current Temperature'),

        subtitle: Text('28°C • Humidity 78% • Wind 12 km/h'),
      ),
    );
  }
}

class StatisticsTile extends StatelessWidget {
  final String title;
  final String value;

  const StatisticsTile({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.bar_chart, color: Colors.green),

        title: Text(title),

        trailing: Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}
