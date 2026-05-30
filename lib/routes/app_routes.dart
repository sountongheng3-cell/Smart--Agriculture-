import 'package:flutter/material.dart';

import '../screens/auth/register_screen.dart';
import '../screens/community/community_screen.dart';
import '../screens/disease/disease_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/home/main_screen.dart';
import '../screens/market/market_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/report/report_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/weather/weather_screen.dart';

class AppRoutes {
  // Route Names
  static const String home = '/home';

  static const String weather = '/weather';

  static const String market = '/market';

  static const String disease = '/disease';

  static const String community = '/community';

  static const String profile = '/profile';
  static const String register = '/register';
  static const String settings = '/settings';
  static const String report = '/report';

  // Routes
  static Map<String, WidgetBuilder> routes = {
    home: (context) => const MainScreen(),

    weather: (context) => const WeatherScreen(),

    market: (context) => const MarketScreen(),

    disease: (context) => const DiseaseScreen(),
    AppRoutes.community: (context) => const CommunityScreen(),
    report: (context) => const ReportScreen(),
    profile: (context) => const ProfileScreen(),
    register: (context) => const RegisterScreen(),

    settings: (context) => const SettingsScreen(),
  };
}
