class DiseaseModel {
  final int id;
  final String diseaseName;
  final String description;
  final String solution;
  final String image;

  // ── AI-enriched fields ────────────────────────────────────────────────────
  final String? aiExplanation;
  final String? aiSeverity;
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

  // ── fromJson: maps dummyjson /products fields ─────────────────────────────
  // dummyjson product shape:
  // { "id": 1, "title": "...", "description": "...", "category": "...",
  //   "thumbnail": "...", "images": [...], "price": 9.99, ... }
  factory DiseaseModel.fromJson(Map<String, dynamic> json) {
    // Pick the first image from images[] or fall back to thumbnail
    String imageUrl = '';
    if (json['images'] != null &&
        json['images'] is List &&
        (json['images'] as List).isNotEmpty) {
      imageUrl = json['images'][0].toString();
    } else if (json['thumbnail'] != null) {
      imageUrl = json['thumbnail'].toString();
    }

    return DiseaseModel(
      id: json['id'] ?? 0,

      // title  → diseaseName
      diseaseName: json['title'] ?? json['disease_name'] ?? '',

      // description → description
      description: json['description'] ?? '',

      // category → solution (placeholder until you have a real backend)
      solution: json['category'] != null
          ? 'Treat with appropriate measures for: ${json['category']}'
          : json['solution'] ?? 'Consult an agricultural expert.',

      image: imageUrl,
    );
  }

  // ── toJson ────────────────────────────────────────────────────────────────
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'disease_name': diseaseName,
      'description': description,
      'solution': solution,
      'image': image,
    };
  }

  // ── copyWithAI ────────────────────────────────────────────────────────────
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
