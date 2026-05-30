import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'routes/app_routes.dart';
import 'screens/splash/splash_screen.dart';

void main() {
  runApp(const SmartAgricultureApp());
}

class SmartAgricultureApp extends StatelessWidget {
  const SmartAgricultureApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      theme: AppTheme.lightTheme,

      routes: AppRoutes.routes,

      home: const SplashScreen(),
    );
  }
}
