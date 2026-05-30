import 'package:flutter/material.dart';

import '../models/disease_model.dart';

class DiseaseCard extends StatelessWidget {
  final DiseaseModel disease;

  const DiseaseCard({super.key, required this.disease});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),

      padding: const EdgeInsets.all(15),

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
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          // Disease Image
          ClipRRect(
            borderRadius: BorderRadius.circular(15),

            child: Image.network(
              disease.image,
              width: double.infinity,
              height: 180,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(height: 15),

          // Disease Name
          Text(
            disease.diseaseName,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          // Description
          Text(
            disease.description,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),

          const SizedBox(height: 10),

          // Solution
          Text(
            'Solution: ${disease.solution}',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
