import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,

      appBar: AppBar(title: const Text('Settings')),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
            _buildSettingItem(
              icon: Icons.language,
              title: 'Language',
              subtitle: 'English / Khmer',
            ),

            _buildSettingItem(
              icon: Icons.notifications,
              title: 'Notifications',
              subtitle: 'Manage app alerts',
            ),

            _buildSettingItem(
              icon: Icons.dark_mode,
              title: 'Dark Mode',
              subtitle: 'Enable dark theme',
            ),

            _buildSettingItem(
              icon: Icons.security,
              title: 'Privacy & Security',
              subtitle: 'Manage account security',
            ),

            _buildSettingItem(
              icon: Icons.info,
              title: 'About App',
              subtitle: 'Version 1.0.0',
            ),
          ],
        ),
      ),
    );
  }

  // Setting Item
  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),

      padding: const EdgeInsets.all(18),

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

      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.green.shade100,

            child: Icon(icon, color: AppColors.primaryColor),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(subtitle, style: const TextStyle(color: Colors.black54)),
              ],
            ),
          ),

          const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
        ],
      ),
    );
  }
}
