import 'package:flutter/material.dart';

import '../../models/disease_model.dart';
import '../../services/disease_service.dart';
import '../../services/gemini_disease_service.dart' hide DiseaseModel;

// ─────────────────────────────────────────────────────────────────────────────
// DiseaseScreen  —  Premium list of diseases
// ─────────────────────────────────────────────────────────────────────────────
class DiseaseScreen extends StatefulWidget {
  const DiseaseScreen({super.key});

  @override
  State<DiseaseScreen> createState() => _DiseaseScreenState();
}

class _DiseaseScreenState extends State<DiseaseScreen> {
  List<DiseaseModel> _diseases = [];
  bool _isLoading = true;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _fetchDiseases();
  }

  Future<void> _fetchDiseases() async {
    setState(() => _isLoading = true);
    try {
      final result = await DiseaseService.getDiseases(); // or your method name
      debugPrint('✅ Fetched ${result.length} diseases');
      setState(() => _diseases = result);
    } catch (e) {
      debugPrint('❌ Error: $e');
    }
    setState(() => _isLoading = false);
  }

  List<DiseaseModel> get _filtered => _diseases
      .where((d) => d.diseaseName.toLowerCase().contains(_search.toLowerCase()))
      .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: _buildAppBar(),
      body: _isLoading
          ? _buildLoading()
          : Column(
              children: [
                _buildSearchBar(),
                Expanded(child: _buildList()),
              ],
            ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFC62828),
      foregroundColor: Colors.white,
      elevation: 0,
      title: const Row(
        children: [
          Icon(Icons.biotech_outlined, size: 22),
          SizedBox(width: 8),
          Text(
            'Disease AI',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 20,
              letterSpacing: -0.4,
            ),
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 20),
            onPressed: _fetchDiseases,
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(4),
        child: Container(
          height: 4,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFB71C1C), Color(0xFFEF5350)],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: TextField(
        onChanged: (v) => setState(() => _search = v),
        decoration: InputDecoration(
          hintText: 'Search diseases…',
          hintStyle: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 14),
          prefixIcon: const Icon(
            Icons.search,
            color: Color(0xFFAAAAAA),
            size: 20,
          ),
          filled: true,
          fillColor: const Color(0xFFF5F5F5),
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildList() {
    if (_filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 52, color: Color(0xFFCCCCCC)),
            const SizedBox(height: 12),
            const Text(
              'No diseases found',
              style: TextStyle(color: Color(0xFFAAAAAA), fontSize: 16),
            ),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) => _DiseaseCard(disease: _filtered[i]),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(color: Color(0xFFC62828)),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _DiseaseCard  —  tappable card that opens DiseaseDetailScreen
// ─────────────────────────────────────────────────────────────────────────────
class _DiseaseCard extends StatelessWidget {
  final DiseaseModel disease;
  const _DiseaseCard({required this.disease});

  Color get _severityColor {
    switch (disease.aiSeverity) {
      case 'Low':
        return const Color(0xFF2E7D32);
      case 'Moderate':
        return const Color(0xFFF57F17);
      case 'High':
        return const Color(0xFFE65100);
      case 'Critical':
        return const Color(0xFFC62828);
      default:
        return const Color(0xFF888888);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DiseaseDetailScreen(disease: disease),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Disease image / placeholder
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(20),
              ),
              child: disease.image.isNotEmpty
                  ? Image.network(
                      disease.image,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder(),
                    )
                  : _placeholder(),
            ),
            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            disease.diseaseName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: Color(0xFF1A1A1A),
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                        if (disease.aiSeverity != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: _severityColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              disease.aiSeverity!,
                              style: TextStyle(
                                color: _severityColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      disease.aiExplanation ?? disease.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF666666),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(
                          Icons.auto_awesome,
                          size: 13,
                          color: Color(0xFFC62828),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'AI Analysis',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFFC62828),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.chevron_right,
                          size: 18,
                          color: Color(0xFFCCCCCC),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 100,
      height: 100,
      color: const Color(0xFFFFEBEE),
      child: const Icon(Icons.eco, color: Color(0xFFC62828), size: 40),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DiseaseDetailScreen  —  full AI analysis + chat
// ─────────────────────────────────────────────────────────────────────────────
class DiseaseDetailScreen extends StatefulWidget {
  final DiseaseModel disease;
  const DiseaseDetailScreen({super.key, required this.disease});

  @override
  State<DiseaseDetailScreen> createState() => _DiseaseDetailScreenState();
}

class _DiseaseDetailScreenState extends State<DiseaseDetailScreen>
    with SingleTickerProviderStateMixin {
  late DiseaseModel _disease;
  bool _aiLoading = false;
  String? _aiError;

  // Chat
  final TextEditingController _chatCtrl = TextEditingController();
  final ScrollController _chatScroll = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _chatLoading = false;

  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _disease = widget.disease;
    _tabCtrl = TabController(length: 3, vsync: this);
    if (_disease.aiExplanation == null) _loadAI();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _chatCtrl.dispose();
    _chatScroll.dispose();
    super.dispose();
  }

  Future<void> _loadAI() async {
    setState(() {
      _aiLoading = true;
      _aiError = null;
    });
    try {
      final enriched = await GeminiDiseaseService.analyze(_disease);
      setState(() => _disease = enriched);
    } catch (e) {
      setState(() => _aiError = e.toString());
    } finally {
      setState(() => _aiLoading = false);
    }
  }

  Future<void> _sendChat() async {
    final q = _chatCtrl.text.trim();
    if (q.isEmpty || _chatLoading) return;
    _chatCtrl.clear();
    setState(() {
      _messages.add(_ChatMessage(text: q, isUser: true));
      _chatLoading = true;
    });
    _scrollChat();

    try {
      var GeminiDiseaseService;
      final answer = await GeminiDiseaseService.askQuestion(
        disease: _disease,
        question: q,
      );
      setState(() => _messages.add(_ChatMessage(text: answer, isUser: false)));
    } catch (e) {
      setState(
        () => _messages.add(
          _ChatMessage(
            text: 'Sorry, I could not connect to AI. Please try again.',
            isUser: false,
          ),
        ),
      );
    } finally {
      setState(() => _chatLoading = false);
      _scrollChat();
    }
  }

  void _scrollChat() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_chatScroll.hasClients) {
        _chatScroll.animateTo(
          _chatScroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Color get _severityColor {
    switch (_disease.aiSeverity) {
      case 'Low':
        return const Color(0xFF2E7D32);
      case 'Moderate':
        return const Color(0xFFF57F17);
      case 'High':
        return const Color(0xFFE65100);
      case 'Critical':
        return const Color(0xFFC62828);
      default:
        return const Color(0xFF888888);
    }
  }

  get GeminiDiseaseService => null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [_buildSliverHeader()],
        body: Column(
          children: [
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabCtrl,
                children: [
                  _buildOverviewTab(),
                  _buildSolutionTab(),
                  _buildChatTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Sliver header ──────────────────────────────────────────────────
  Widget _buildSliverHeader() {
    return SliverAppBar(
      expandedHeight: 240,
      pinned: true,
      backgroundColor: const Color(0xFFC62828),
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            _disease.image.isNotEmpty
                ? Image.network(
                    _disease.image,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _headerPlaceholder(),
                  )
                : _headerPlaceholder(),
            // Gradient overlay
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xDD1A1A1A)],
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_disease.aiSeverity != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _severityColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${_disease.aiSeverity} Severity',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  Text(
                    _disease.diseaseName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerPlaceholder() {
    return Container(
      color: const Color(0xFFB71C1C),
      child: const Center(
        child: Icon(Icons.eco, color: Colors.white30, size: 80),
      ),
    );
  }

  // ── Tab bar ────────────────────────────────────────────────────────
  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabCtrl,
        labelColor: const Color(0xFFC62828),
        unselectedLabelColor: const Color(0xFF888888),
        indicatorColor: const Color(0xFFC62828),
        indicatorWeight: 2.5,
        labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Solution'),
          Tab(text: 'Ask AI'),
        ],
      ),
    );
  }

  // ── Overview tab ───────────────────────────────────────────────────
  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI Explanation card
          _buildAICard(),
          const SizedBox(height: 16),
          // Symptoms
          if (_disease.aiSymptoms != null)
            _buildListCard(
              icon: Icons.warning_amber_rounded,
              iconColor: const Color(0xFFF57F17),
              title: 'Key Symptoms',
              items: _disease.aiSymptoms!,
            ),
          const SizedBox(height: 16),
          // Original description
          _buildTextCard(
            icon: Icons.description_outlined,
            title: 'Description',
            body: _disease.description,
          ),
          const SizedBox(height: 16),
          // Prevention
          if (_disease.aiPreventionSummary != null)
            _buildTextCard(
              icon: Icons.shield_outlined,
              title: 'Prevention',
              body: _disease.aiPreventionSummary!,
              iconColor: const Color(0xFF2E7D32),
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ── Solution tab ───────────────────────────────────────────────────
  Widget _buildSolutionTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildTextCard(
            icon: Icons.medical_services_outlined,
            title: 'Recommended Solution',
            body: _disease.solution,
            iconColor: const Color(0xFFC62828),
          ),
          const SizedBox(height: 16),
          if (_disease.aiTips != null)
            _buildListCard(
              icon: Icons.lightbulb_outline,
              iconColor: const Color(0xFF1565C0),
              title: 'AI Farmer Tips',
              items: _disease.aiTips!,
              numbered: true,
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ── Chat tab ───────────────────────────────────────────────────────
  Widget _buildChatTab() {
    return Column(
      children: [
        // Intro banner
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFB71C1C), Color(0xFFEF5350)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Row(
            children: [
              Icon(Icons.auto_awesome, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Ask Gemini AI anything about this disease',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Messages
        Expanded(
          child: ListView.builder(
            controller: _chatScroll,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _messages.length + (_chatLoading ? 1 : 0),
            itemBuilder: (context, i) {
              if (i == _messages.length) return _typingIndicator();
              return _buildChatBubble(_messages[i]);
            },
          ),
        ),
        // Input
        _buildChatInput(),
      ],
    );
  }

  Widget _buildChatBubble(_ChatMessage msg) {
    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        decoration: BoxDecoration(
          color: msg.isUser ? const Color(0xFFC62828) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(msg.isUser ? 18 : 4),
            bottomRight: Radius.circular(msg.isUser ? 4 : 18),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          msg.text,
          style: TextStyle(
            color: msg.isUser ? Colors.white : const Color(0xFF1A1A1A),
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _typingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            return AnimatedContainer(
              duration: Duration(milliseconds: 300 + i * 150),
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: const Color(0xFFC62828).withOpacity(0.5),
                shape: BoxShape.circle,
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildChatInput() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(
        16,
        10,
        16,
        MediaQuery.of(context).viewInsets.bottom + 12,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _chatCtrl,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendChat(),
              decoration: InputDecoration(
                hintText: 'Ask about ${_disease.diseaseName}…',
                hintStyle: const TextStyle(
                  color: Color(0xFFAAAAAA),
                  fontSize: 14,
                ),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _sendChat,
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Color(0xFFC62828),
                shape: BoxShape.circle,
              ),
              child: _chatLoading
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Reusable card widgets ─────────────────────────────────────────
  Widget _buildAICard() {
    if (_aiLoading) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Color(0xFFC62828),
                strokeWidth: 2,
              ),
            ),
            SizedBox(width: 14),
            Text(
              'Gemini AI is analyzing…',
              style: TextStyle(color: Color(0xFF888888)),
            ),
          ],
        ),
      );
    }

    if (_aiError != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFEBEE),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFC62828)),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Could not load AI analysis.',
                style: TextStyle(color: Color(0xFFC62828)),
              ),
            ),
            TextButton(
              onPressed: _loadAI,
              child: const Text(
                'Retry',
                style: TextStyle(color: Color(0xFFC62828)),
              ),
            ),
          ],
        ),
      );
    }

    if (_disease.aiExplanation == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFB71C1C), Color(0xFFE53935)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFC62828).withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome, color: Colors.white70, size: 16),
              SizedBox(width: 6),
              Text(
                'AI Explanation',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _disease.aiExplanation!,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextCard({
    required IconData icon,
    required String title,
    required String body,
    Color iconColor = const Color(0xFF888888),
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
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
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            body,
            style: const TextStyle(
              color: Color(0xFF555555),
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required List<String> items,
    bool numbered = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
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
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...items.asMap().entries.map((e) {
            final idx = e.key;
            final item = e.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: numbered
                          ? Text(
                              '${idx + 1}',
                              style: TextStyle(
                                color: iconColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            )
                          : Icon(Icons.circle, size: 6, color: iconColor),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        color: Color(0xFF444444),
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Chat message model
// ─────────────────────────────────────────────────────────────────────────────
class _ChatMessage {
  final String text;
  final bool isUser;
  _ChatMessage({required this.text, required this.isUser});
}
