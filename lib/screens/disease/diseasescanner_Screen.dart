import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

// ─────────────────────────────────────────────────────────────────────────────
// DiseaseScannerScreen
// Camera / Gallery → Gemini Vision → Disease result + solution
// ─────────────────────────────────────────────────────────────────────────────
class DiseaseScannerScreen extends StatefulWidget {
  const DiseaseScannerScreen({super.key});

  @override
  State<DiseaseScannerScreen> createState() => _DiseaseScannerScreenState();
}

class _DiseaseScannerScreenState extends State<DiseaseScannerScreen>
    with SingleTickerProviderStateMixin {
  File? _imageFile;
  bool _isAnalyzing = false;
  PlantDiseaseResult? _result;
  String? _error;

  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  // ── Pick image ────────────────────────────────────────────────────────────
  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1024,
    );
    if (picked == null) return;
    setState(() {
      _imageFile = File(picked.path);
      _result = null;
      _error = null;
    });
    await _analyzeImage();
  }

  // ── Analyze with Gemini Vision ────────────────────────────────────────────
  Future<void> _analyzeImage() async {
    if (_imageFile == null) return;
    setState(() {
      _isAnalyzing = true;
      _error = null;
    });

    try {
      final bytes = await _imageFile!.readAsBytes();
      final base64Image = base64Encode(bytes);

      const apiKey = 'YOUR_GEMINI_API_KEY_HERE'; // 🔑 Replace with your key
      const url =
          'https://generativelanguage.googleapis.com/v1beta/models/'
          'gemini-1.5-flash:generateContent?key=$apiKey';

      final prompt = '''
You are an expert agricultural plant pathologist AI. Analyze this image of a plant or crop.

Respond ONLY with a valid JSON object (no markdown, no extra text):
{
  "is_plant": true,
  "plant_name": "<detected plant name, e.g. Rice, Tomato, Corn>",
  "is_healthy": false,
  "disease_name": "<name of disease or 'Healthy' if no disease>",
  "severity": "<Low | Moderate | High | Critical>",
  "confidence": "<percentage, e.g. 92%>",
  "description": "<2-3 sentence plain description of what you see>",
  "symptoms": ["<symptom 1>", "<symptom 2>", "<symptom 3>"],
  "solution": "<clear actionable solution in 2-3 sentences>",
  "treatment_steps": ["<step 1>", "<step 2>", "<step 3>", "<step 4>"],
  "prevention": "<1-2 sentence prevention tip>",
  "urgency": "<Act immediately | Monitor closely | Low urgency>"
}

If the image is NOT a plant or crop, set "is_plant" to false and fill other fields with "N/A".
''';

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'inline_data': {
                    'mime_type': 'image/jpeg',
                    'data': base64Image,
                  },
                },
                {'text': prompt},
              ],
            },
          ],
          'generationConfig': {
            'temperature': 0.2,
            'maxOutputTokens': 1024,
            'responseMimeType': 'application/json',
          },
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('API Error: ${response.statusCode}');
      }

      final body = jsonDecode(response.body);
      final text =
          body['candidates'][0]['content']['parts'][0]['text'] as String;
      final cleaned = text
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();
      final parsed = jsonDecode(cleaned) as Map<String, dynamic>;

      setState(() => _result = PlantDiseaseResult.fromJson(parsed));
    } catch (e) {
      setState(
        () => _error =
            'Analysis failed. Check your API key and internet connection.\n\n$e',
      );
    } finally {
      setState(() => _isAnalyzing = false);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1F0E),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildScanArea(),
                  const SizedBox(height: 20),
                  _buildActionButtons(),
                  const SizedBox(height: 20),
                  if (_isAnalyzing) _buildAnalyzingCard(),
                  if (_error != null) _buildErrorCard(),
                  if (_result != null && !_isAnalyzing) _buildResultSection(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────────────
  Widget _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      backgroundColor: const Color(0xFF0D1F0E),
      foregroundColor: Colors.white,
      title: const Row(
        children: [
          Icon(Icons.biotech, color: Color(0xFF69F0AE), size: 22),
          SizedBox(width: 8),
          Text(
            'Plant Disease Scanner',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: Colors.white,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
      actions: [
        if (_result != null)
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF69F0AE)),
            onPressed: () => setState(() {
              _imageFile = null;
              _result = null;
              _error = null;
            }),
          ),
      ],
    );
  }

  // ── Scan area ─────────────────────────────────────────────────────────────
  Widget _buildScanArea() {
    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (context, child) {
        return Transform.scale(
          scale: _imageFile == null ? _pulseAnim.value : 1.0,
          child: child,
        );
      },
      child: GestureDetector(
        onTap: () => _pickImage(ImageSource.camera),
        child: Container(
          height: 300,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF1A2E1B),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: _imageFile != null
                  ? const Color(0xFF69F0AE)
                  : const Color(0xFF2E4D2F),
              width: 2,
            ),
          ),
          child: _imageFile != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(26),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.file(_imageFile!, fit: BoxFit.cover),
                      // Scan overlay when analyzing
                      if (_isAnalyzing)
                        Container(
                          color: Colors.black54,
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.document_scanner,
                                  color: Color(0xFF69F0AE),
                                  size: 48,
                                ),
                                SizedBox(height: 12),
                                Text(
                                  'Scanning...',
                                  style: TextStyle(
                                    color: Color(0xFF69F0AE),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFF69F0AE).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt_outlined,
                        color: Color(0xFF69F0AE),
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Tap to scan your plant',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'AI will identify diseases instantly',
                      style: TextStyle(color: Color(0xFF88A889), fontSize: 13),
                    ),
                    const SizedBox(height: 20),
                    // Corner brackets for scanner feel
                    _scannerBrackets(),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _scannerBrackets() {
    return SizedBox(
      width: 120,
      height: 60,
      child: CustomPaint(painter: _ScannerBracketPainter()),
    );
  }

  // ── Action buttons ────────────────────────────────────────────────────────
  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: _actionBtn(
            icon: Icons.camera_alt_rounded,
            label: 'Camera',
            color: const Color(0xFF69F0AE),
            onTap: () => _pickImage(ImageSource.camera),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _actionBtn(
            icon: Icons.photo_library_outlined,
            label: 'Gallery',
            color: const Color(0xFF40C4FF),
            onTap: () => _pickImage(ImageSource.gallery),
          ),
        ),
      ],
    );
  }

  Widget _actionBtn({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Analyzing card ────────────────────────────────────────────────────────
  Widget _buildAnalyzingCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2E1B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF69F0AE).withOpacity(0.3)),
      ),
      child: const Row(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              color: Color(0xFF69F0AE),
              strokeWidth: 2.5,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gemini AI is analyzing your plant…',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Identifying disease, severity & solution',
                  style: TextStyle(color: Color(0xFF88A889), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Error card ────────────────────────────────────────────────────────────
  Widget _buildErrorCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF3E1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _error!,
              style: const TextStyle(color: Colors.redAccent, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  // ── Result section ────────────────────────────────────────────────────────
  Widget _buildResultSection() {
    final r = _result!;

    if (r.isPlant == false) {
      return _buildNotPlantCard();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Summary card ────────────────────────────────────────────────
        _buildSummaryCard(r),
        const SizedBox(height: 14),

        // ── Healthy badge or severity ───────────────────────────────────
        if (r.isHealthy)
          _buildHealthyCard()
        else ...[
          _buildInfoCard(
            icon: Icons.warning_amber_rounded,
            iconColor: _severityColor(r.severity),
            title: 'Symptoms',
            child: _bulletList(r.symptoms, const Color(0xFF88A889)),
          ),
          const SizedBox(height: 14),
          _buildInfoCard(
            icon: Icons.medical_services_outlined,
            iconColor: const Color(0xFF69F0AE),
            title: 'Solution',
            child: Text(
              r.solution,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 14),
          _buildInfoCard(
            icon: Icons.list_alt_outlined,
            iconColor: const Color(0xFF40C4FF),
            title: 'Treatment Steps',
            child: _numberedList(r.treatmentSteps, const Color(0xFF40C4FF)),
          ),
          const SizedBox(height: 14),
          _buildInfoCard(
            icon: Icons.shield_outlined,
            iconColor: const Color(0xFFFFD740),
            title: 'Prevention',
            child: Text(
              r.prevention,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                height: 1.6,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSummaryCard(PlantDiseaseResult r) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: r.isHealthy
              ? [const Color(0xFF1B5E20), const Color(0xFF2E7D32)]
              : [const Color(0xFF4A0E0E), const Color(0xFF7B1A1A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color:
                (r.isHealthy
                        ? const Color(0xFF2E7D32)
                        : const Color(0xFFC62828))
                    .withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  r.isHealthy ? Icons.check_circle : Icons.coronavirus_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.plantName,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      r.diseaseName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _pill(
                'Confidence: ${r.confidence}',
                Colors.white24,
                Colors.white70,
              ),
              const SizedBox(width: 8),
              if (!r.isHealthy)
                _pill(
                  r.severity,
                  _severityColor(r.severity).withOpacity(0.3),
                  _severityColor(r.severity),
                ),
              const SizedBox(width: 8),
              _pill(r.urgency, Colors.white24, Colors.white70),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            r.description,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthyCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2E1B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF69F0AE).withOpacity(0.4),
          width: 1.5,
        ),
      ),
      child: const Row(
        children: [
          Icon(Icons.eco, color: Color(0xFF69F0AE), size: 36),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your plant looks healthy! 🎉',
                  style: TextStyle(
                    color: Color(0xFF69F0AE),
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'No disease detected. Keep up the good care.',
                  style: TextStyle(color: Color(0xFF88A889), fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotPlantCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFD740).withOpacity(0.4)),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.image_not_supported_outlined,
            color: Color(0xFFFFD740),
            size: 36,
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Not a plant image',
                  style: TextStyle(
                    color: Color(0xFFFFD740),
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Please take a photo of a plant or crop leaf.',
                  style: TextStyle(color: Color(0xFF88A889), fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2E1B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: iconColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _bulletList(List<String> items, Color color) {
    return Column(
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _numberedList(List<String> items, Color color) {
    return Column(
      children: items.asMap().entries.map((e) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${e.key + 1}',
                    style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  e.value,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _pill(String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }

  Color _severityColor(String severity) {
    switch (severity) {
      case 'Low':
        return const Color(0xFF69F0AE);
      case 'Moderate':
        return const Color(0xFFFFD740);
      case 'High':
        return const Color(0xFFFF6D00);
      case 'Critical':
        return const Color(0xFFFF1744);
      default:
        return const Color(0xFF88A889);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PlantDiseaseResult model
// ─────────────────────────────────────────────────────────────────────────────
class PlantDiseaseResult {
  final bool isPlant;
  final String plantName;
  final bool isHealthy;
  final String diseaseName;
  final String severity;
  final String confidence;
  final String description;
  final List<String> symptoms;
  final String solution;
  final List<String> treatmentSteps;
  final String prevention;
  final String urgency;

  PlantDiseaseResult({
    required this.isPlant,
    required this.plantName,
    required this.isHealthy,
    required this.diseaseName,
    required this.severity,
    required this.confidence,
    required this.description,
    required this.symptoms,
    required this.solution,
    required this.treatmentSteps,
    required this.prevention,
    required this.urgency,
  });

  factory PlantDiseaseResult.fromJson(Map<String, dynamic> j) {
    List<String> parseList(dynamic v) {
      if (v is List) return v.map((e) => e.toString()).toList();
      return [];
    }

    return PlantDiseaseResult(
      isPlant: j['is_plant'] == true,
      plantName: j['plant_name']?.toString() ?? 'Unknown',
      isHealthy: j['is_healthy'] == true,
      diseaseName: j['disease_name']?.toString() ?? 'Unknown',
      severity: j['severity']?.toString() ?? 'Unknown',
      confidence: j['confidence']?.toString() ?? 'N/A',
      description: j['description']?.toString() ?? '',
      symptoms: parseList(j['symptoms']),
      solution: j['solution']?.toString() ?? '',
      treatmentSteps: parseList(j['treatment_steps']),
      prevention: j['prevention']?.toString() ?? '',
      urgency: j['urgency']?.toString() ?? '',
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Scanner bracket painter (decorative corner lines)
// ─────────────────────────────────────────────────────────────────────────────
class _ScannerBracketPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF69F0AE)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const len = 18.0;
    // Top-left
    canvas.drawLine(Offset.zero, const Offset(len, 0), paint);
    canvas.drawLine(Offset.zero, const Offset(0, len), paint);
    // Top-right
    canvas.drawLine(Offset(size.width, 0), Offset(size.width - len, 0), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, len), paint);
    // Bottom-left
    canvas.drawLine(Offset(0, size.height), Offset(len, size.height), paint);
    canvas.drawLine(
      Offset(0, size.height),
      Offset(0, size.height - len),
      paint,
    );
    // Bottom-right
    canvas.drawLine(
      Offset(size.width, size.height),
      Offset(size.width - len, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(size.width, size.height),
      Offset(size.width, size.height - len),
      paint,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}
