import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class MarketScreen extends StatelessWidget {
  const MarketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,

      appBar: AppBar(title: const Text('Market Prices')),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: ListView(
          children: [
            _buildMarketCard(
              product: 'Rice',
              price: '\$250 / ton',
              icon: Icons.grass,
            ),

            _buildMarketCard(
              product: 'Corn',
              price: '\$180 / ton',
              icon: Icons.agriculture,
            ),

            _buildMarketCard(
              product: 'Potato',
              price: '\$120 / ton',
              icon: Icons.eco,
            ),

            _buildMarketCard(
              product: 'Tomato',
              price: '\$90 / ton',
              icon: Icons.local_florist,
            ),

            _buildMarketCard(
              product: 'Mango',
              price: '\$300 / ton',
              icon: Icons.energy_savings_leaf,
            ),
          ],
        ),
      ),
    );
  }

  // Market Card
  Widget _buildMarketCard({
    required String product,
    required String price,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),

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

      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.green.shade100,

            child: Icon(icon, size: 35, color: AppColors.primaryColor),
          ),

          const SizedBox(width: 20),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  product,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  'Updated Today',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),

          Text(
            price,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}
