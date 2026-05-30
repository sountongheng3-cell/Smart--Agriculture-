import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/post_model.dart';
import '../../services/post_service.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/post_card.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
    with SingleTickerProviderStateMixin {
  List<PostModel> posts = [];
  bool isLoading = true;
  late TabController _tabController;

  final List<String> _tabs = ['All', 'Following', 'Popular', 'My Posts'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    fetchPosts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> fetchPosts() async {
    setState(() => isLoading = true);
    try {
      posts = await PostService.getPosts();
    } catch (e) {
      debugPrint(e.toString());
    }
    setState(() => isLoading = false);
  }

  void _showCreatePostSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _CreatePostSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          // ── Premium AppBar ──────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            floating: true,
            elevation: 0,
            backgroundColor: Colors.white,
            systemOverlayStyle: SystemUiOverlayStyle.dark,
            title: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.eco, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Community',
                  style: TextStyle(
                    color: Color(0xFF1A1A1A),
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            actions: [
              _appBarAction(Icons.search_rounded, () {}),
              _appBarAction(Icons.notifications_outlined, () {}),
              const SizedBox(width: 8),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(44),
              child: Container(
                color: Colors.white,
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  labelColor: const Color(0xFF2E7D32),
                  unselectedLabelColor: const Color(0xFF888888),
                  indicatorColor: const Color(0xFF2E7D32),
                  indicatorWeight: 2.5,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  tabs: _tabs.map((t) => Tab(text: t)).toList(),
                ),
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: List.generate(_tabs.length, (i) => _buildFeed()),
        ),
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  // ── App bar icon button ───────────────────────────────────────────────
  Widget _appBarAction(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: const Color(0xFFF0F2F5),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: const Color(0xFF1A1A1A), size: 20),
      ),
    );
  }

  // ── Main feed ─────────────────────────────────────────────────────────
  Widget _buildFeed() {
    if (isLoading) return const LoadingWidget();

    return RefreshIndicator(
      color: const Color(0xFF2E7D32),
      onRefresh: fetchPosts,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Story / Create post bar
          _buildCreatePostBar(),
          const SizedBox(height: 8),

          // Stories row
          _buildStoriesRow(),
          const SizedBox(height: 8),

          // Posts
          if (posts.isEmpty)
            _buildEmptyState()
          else
            ...posts.map((post) => _buildPostWrapper(post)),
        ],
      ),
    );
  }

  // ── Create post bar ───────────────────────────────────────────────────
  Widget _buildCreatePostBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundColor: Color(0xFFE8F5E9),
                child: Icon(Icons.person, color: Color(0xFF2E7D32), size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: _showCreatePostSheet,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F2F5),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: const Text(
                      "What's on your mind?",
                      style: TextStyle(color: Color(0xFF888888), fontSize: 15),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFF0F2F5)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _postTypeButton(
                Icons.videocam_outlined,
                "Live",
                const Color(0xFFE53935),
              ),
              _postTypeButton(
                Icons.photo_library_outlined,
                "Photo",
                const Color(0xFF43A047),
              ),
              _postTypeButton(
                Icons.emoji_emotions_outlined,
                "Feeling",
                const Color(0xFFFDD835),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _postTypeButton(IconData icon, String label, Color color) {
    return GestureDetector(
      onTap: _showCreatePostSheet,
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: Color(0xFF444444),
            ),
          ),
        ],
      ),
    );
  }

  // ── Stories row ───────────────────────────────────────────────────────
  Widget _buildStoriesRow() {
    final stories = [
      {'label': 'Your Story', 'icon': Icons.add, 'isAdd': true},
      {'label': 'Farmer Dara', 'icon': Icons.agriculture, 'isAdd': false},
      {'label': 'Market', 'icon': Icons.storefront, 'isAdd': false},
      {'label': 'Weather', 'icon': Icons.cloud, 'isAdd': false},
    ];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SizedBox(
        height: 100,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemCount: stories.length,
          itemBuilder: (context, i) {
            final s = stories[i];
            final isAdd = s['isAdd'] as bool;
            return SizedBox(
              width: 70,
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 62,
                        height: 62,
                        decoration: BoxDecoration(
                          gradient: isAdd
                              ? null
                              : const LinearGradient(
                                  colors: [
                                    Color(0xFF2E7D32),
                                    Color(0xFF66BB6A),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                          color: isAdd ? const Color(0xFFF0F2F5) : null,
                          shape: BoxShape.circle,
                          border: isAdd
                              ? null
                              : Border.all(
                                  color: const Color(0xFF2E7D32),
                                  width: 2.5,
                                ),
                        ),
                        child: Icon(
                          s['icon'] as IconData,
                          color: isAdd ? const Color(0xFF2E7D32) : Colors.white,
                          size: 28,
                        ),
                      ),
                      if (isAdd)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(
                              color: Color(0xFF2E7D32),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    s['label'] as String,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ── Post wrapper (card with divider) ─────────────────────────────────
  Widget _buildPostWrapper(PostModel post) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          child: PostCard(post: post),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  // ── Empty state ───────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 40),
      child: Column(
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.groups_outlined,
              color: Color(0xFF2E7D32),
              size: 44,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "No Posts Yet",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Be the first to share something with the farming community!",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF888888),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showCreatePostSheet,
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: const Text("Create Post"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              textStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── FAB ───────────────────────────────────────────────────────────────
  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: _showCreatePostSheet,
      backgroundColor: const Color(0xFF2E7D32),
      foregroundColor: Colors.white,
      elevation: 4,
      icon: const Icon(Icons.edit_outlined),
      label: const Text(
        "Post",
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
      ),
    );
  }
}

// ── Create Post Bottom Sheet ──────────────────────────────────────────────
class _CreatePostSheet extends StatelessWidget {
  const _CreatePostSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.55,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFDDDDDD),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                const Text(
                  "Create Post",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF0F2F5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 18,
                      color: Color(0xFF444444),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF0F2F5)),
          // User row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 22,
                  backgroundColor: Color(0xFFE8F5E9),
                  child: Icon(Icons.person, color: Color(0xFF2E7D32), size: 24),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Farmer",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F2F5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.public,
                            size: 12,
                            color: Color(0xFF555555),
                          ),
                          SizedBox(width: 4),
                          Text(
                            "Public",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF555555),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Text field
          const Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                maxLines: null,
                expands: true,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: "What's on your mind?",
                  hintStyle: TextStyle(color: Color(0xFFAAAAAA), fontSize: 16),
                  border: InputBorder.none,
                ),
                style: TextStyle(fontSize: 16, color: Color(0xFF1A1A1A)),
              ),
            ),
          ),
          // Bottom actions
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Color(0xFFF0F2F5), width: 1),
              ),
            ),
            child: Row(
              children: [
                _sheetAction(
                  Icons.photo_library_outlined,
                  const Color(0xFF43A047),
                ),
                const SizedBox(width: 16),
                _sheetAction(Icons.videocam_outlined, const Color(0xFFE53935)),
                _sheetAction(Icons.tag_faces_outlined, const Color(0xFFFDD835)),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Create Post Coming Soon'),
                        backgroundColor: const Color(0xFF2E7D32),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  child: const Text("Post"),
                ),
              ],
            ),
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }

  Widget _sheetAction(IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: IconButton(
        onPressed: () {},
        icon: Icon(icon, color: color, size: 26),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      ),
    );
  }
}
