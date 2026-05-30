import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,

      appBar: AppBar(title: const Text('Profile')),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),

              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryColor, Colors.green],
                ),

                borderRadius: BorderRadius.circular(25),
              ),

              child: const Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,

                    child: Icon(
                      Icons.person,
                      size: 60,
                      color: AppColors.primaryColor,
                    ),
                  ),

                  SizedBox(height: 15),

                  Text(
                    'Farmer Sokha',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 8),

                  Text(
                    'Smart Agriculture User',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // Menu Items
            _buildMenuItem(icon: Icons.person, title: 'Edit Profile'),

            _buildMenuItem(icon: Icons.history, title: 'Detection History'),

            _buildMenuItem(icon: Icons.favorite, title: 'Saved Posts'),

            _buildMenuItem(icon: Icons.settings, title: 'Settings'),

            _buildMenuItem(icon: Icons.logout, title: 'Logout'),
          ],
        ),
      ),
    );
  }

  // Menu Item
  Widget _buildMenuItem({required IconData icon, required String title}) {
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
            child: Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),

          const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
        ],
      ),
    );
  }
}
