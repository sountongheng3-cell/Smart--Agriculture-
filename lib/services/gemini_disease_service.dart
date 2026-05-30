class DiseaseModel {
  final int id;
  final String diseaseName;
  final String description;
  final String solution;
  final String image;

  // ── AI-enriched fields (populated by GeminiDiseaseService) ──────────
  final String? aiExplanation; // Simple plain-language explanation
  final String? aiSeverity; // "Low" | "Moderate" | "High" | "Critical"
  final List<String>? aiSymptoms;
  final List<String>? aiTips;
  final String? aiPreventionSummary;

  DiseaseModel({
    required this.id,
    required this.diseaseName,
    required this.description,
    required this.solution,
    required this.image,
    this.aiExplanation,
    this.aiSeverity,
    this.aiSymptoms,
    this.aiTips,
    this.aiPreventionSummary,
  });

  // Convert JSON to Object
  factory DiseaseModel.fromJson(Map<String, dynamic> json) {
    return DiseaseModel(
      id: json['id'] ?? 0,
      diseaseName: json['disease_name'] ?? '',
      description: json['description'] ?? '',
      solution: json['solution'] ?? '',
      image: json['image'] ?? '',
    );
  }

  // Convert Object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'disease_name': diseaseName,
      'description': description,
      'solution': solution,
      'image': image,
    };
  }

  // Copy with AI data
  DiseaseModel copyWithAI({
    String? aiExplanation,
    String? aiSeverity,
    List<String>? aiSymptoms,
    List<String>? aiTips,
    String? aiPreventionSummary,
  }) {
    return DiseaseModel(
      id: id,
      diseaseName: diseaseName,
      description: description,
      solution: solution,
      image: image,
      aiExplanation: aiExplanation ?? this.aiExplanation,
      aiSeverity: aiSeverity ?? this.aiSeverity,
      aiSymptoms: aiSymptoms ?? this.aiSymptoms,
      aiTips: aiTips ?? this.aiTips,
      aiPreventionSummary: aiPreventionSummary ?? this.aiPreventionSummary,
    );
  }
}
