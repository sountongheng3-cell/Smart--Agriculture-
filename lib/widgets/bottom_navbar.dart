import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../screens/community/community_screen.dart';
import '../screens/disease/disease_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/market/market_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/report/report_screen.dart';
import '../screens/weather/weather_screen.dart';

class BottomNavbar extends StatefulWidget {
  const BottomNavbar({super.key});

  @override
  State<BottomNavbar> createState() => _BottomNavbarState();
}

class _BottomNavbarState extends State<BottomNavbar> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const WeatherScreen(),
    const MarketScreen(),
    const DiseaseScreen(),
    const CommunityScreen(),
    const ReportScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,

        unselectedItemColor: Colors.grey,

        type: BottomNavigationBarType.fixed,

        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },

        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),

          BottomNavigationBarItem(icon: Icon(Icons.cloud), label: 'Weather'),

          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Market'),

          BottomNavigationBarItem(
            icon: Icon(Icons.health_and_safety),
            label: 'Disease',
          ),

          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Community'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Report'),

          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
} // TODO Implement this library.
