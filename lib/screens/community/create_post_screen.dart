// ============================================================
// models.dart  –  Shared data models
// Place in: lib/models/
// ============================================================

// ── User Model ───────────────────────────────────────────────
class UserModel {
  final String id;
  final String name;
  final String role;
  final String avatarEmoji;
  final int detections;
  final int saved;
  final int reports;
  final int posts;
  final int followers;
  final int following;

  const UserModel({
    required this.id,
    required this.name,
    required this.role,
    required this.avatarEmoji,
    this.detections = 0,
    this.saved = 0,
    this.reports = 0,
    this.posts = 0,
    this.followers = 0,
    this.following = 0,
  });
}

// Singleton current user — shared across the whole app
const kCurrentUser = UserModel(
  id: 'me',
  name: 'Farmer Sokha',
  role: 'Smart Agriculture User',
  avatarEmoji: '🧑‍🌾',
  detections: 12,
  saved: 5,
  reports: 3,
  posts: 8,
  followers: 124,
  following: 67,
);

// ── Post Model ───────────────────────────────────────────────
class PostModel {
  final String id;
  final String authorId;
  final String authorName;
  final String authorEmoji;
  final String authorRole;
  final String content;
  final String? imageEmoji; // used as visual placeholder
  final DateTime createdAt;
  int likes;
  int comments;
  int shares;
  bool isLiked;
  bool isSaved;
  final String category; // 'tip', 'news', 'question', 'market'
  final List<CommentModel> commentList;

  PostModel({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.authorEmoji,
    required this.authorRole,
    required this.content,
    this.imageEmoji,
    required this.createdAt,
    this.likes = 0,
    this.comments = 0,
    this.shares = 0,
    this.isLiked = false,
    this.isSaved = false,
    this.category = 'tip',
    this.commentList = const [],
  });

  // Create a copy with updated fields
  PostModel copyWith({
    int? likes,
    bool? isLiked,
    bool? isSaved,
    int? comments,
    List<CommentModel>? commentList,
  }) {
    return PostModel(
      id: id,
      authorId: authorId,
      authorName: authorName,
      authorEmoji: authorEmoji,
      authorRole: authorRole,
      content: content,
      imageEmoji: imageEmoji,
      createdAt: createdAt,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      shares: shares,
      isLiked: isLiked ?? this.isLiked,
      isSaved: isSaved ?? this.isSaved,
      category: category,
      commentList: commentList ?? this.commentList,
    );
  }
}

// ── Comment Model ────────────────────────────────────────────
class CommentModel {
  final String id;
  final String authorName;
  final String authorEmoji;
  final String content;
  final DateTime createdAt;
  int likes;
  bool isLiked;

  CommentModel({
    required this.id,
    required this.authorName,
    required this.authorEmoji,
    required this.content,
    required this.createdAt,
    this.likes = 0,
    this.isLiked = false,
  });
}

// ── Mock Data ────────────────────────────────────────────────
List<PostModel> generateMockPosts() {
  final now = DateTime.now();
  return [
    PostModel(
      id: '1',
      authorId: 'me',
      authorName: 'Farmer Sokha',
      authorEmoji: '🧑‍🌾',
      authorRole: 'Rice Farmer • Kampong Cham',
      content:
          'ស្រូវរបស់ខ្ញុំចាប់ផ្តើមមានពណ៌លឿងហើយ! ឆ្នាំនេះទំនងជាទទួលបានផលល្អ ប្រហែល ២ ទន្ទើយក្នុង ១ ហិចតា 🌾 សូមអ្នកទាំងអស់គ្នាចែករំលែកបទពិសោធន៍របស់អ្នកផងដែរ!',
      imageEmoji: '🌾',
      createdAt: now.subtract(const Duration(minutes: 15)),
      likes: 47,
      comments: 12,
      shares: 5,
      isLiked: true,
      category: 'tip',
      commentList: [
        CommentModel(
          id: 'c1',
          authorName: 'Dara Farmer',
          authorEmoji: '👨‍🌾',
          content: 'អស្ចារ្យណាស់! ខ្ញុំក៏ចាំបាច់ព្យាយាម 💪',
          createdAt: now.subtract(const Duration(minutes: 10)),
          likes: 3,
        ),
        CommentModel(
          id: 'c2',
          authorName: 'Market Admin',
          authorEmoji: '🏪',
          content: 'តម្លៃស្រូវវាខ្ពស់ក្នុងឆ្នាំនេះ ល្អសម្រាប់កសិករ!',
          createdAt: now.subtract(const Duration(minutes: 5)),
          likes: 7,
        ),
      ],
    ),
    PostModel(
      id: '2',
      authorId: 'u2',
      authorName: 'Dara Kheang',
      authorEmoji: '👨‍🌾',
      authorRole: 'Vegetable Grower • Siem Reap',
      content:
          '📢 ព័ត៌មានសំខាន់! តម្លៃបន្លែក្នុងទីផ្សារ Phnom Penh ចាប់ផ្តើមធ្លាក់ចុះ។ ស្ពៃ: ០.៥ USD/kg, ប៉េងប៉ោះ: ០.៨ USD/kg។ អ្នកដែលចង់ដាំបន្ថែមមុនត្រូវវែកប្រុង!',
      imageEmoji: '🥬',
      createdAt: now.subtract(const Duration(hours: 2)),
      likes: 93,
      comments: 28,
      shares: 15,
      category: 'market',
      commentList: [
        CommentModel(
          id: 'c3',
          authorName: 'Sophal',
          authorEmoji: '🧑‍🌾',
          content: 'អរគុណចំពោះព័ត៌មាន! ខ្ញុំនឹងរង់ចាំ...',
          createdAt: now.subtract(const Duration(hours: 1)),
          likes: 5,
        ),
      ],
    ),
    PostModel(
      id: '3',
      authorId: 'u3',
      authorName: 'AgriTech Cambodia',
      authorEmoji: '🏢',
      authorRole: 'Agricultural Organization',
      content:
          '💡 គន្លឹះកសិកម្ម: ការប្រើប្រាស់ "ជីអ័រហ្គានិក" អាចបង្កើនផលិតផលបានដល់ ៣០%! សាកល្បងប្រើជីពីសត្វ ឬ ស្លឹកឈើ ជំនួសជីគីមី ដើម្បីសន្សំប្រាក់ និងការពារសុខភាព 🌱',
      createdAt: now.subtract(const Duration(hours: 5)),
      likes: 156,
      comments: 42,
      shares: 67,
      isSaved: true,
      category: 'tip',
      commentList: [],
    ),
    PostModel(
      id: '4',
      authorId: 'u4',
      authorName: 'Mealea Chan',
      authorEmoji: '👩‍🌾',
      authorRole: 'Fruit Grower • Kampot',
      content:
          '❓ សំណួរ: តើអ្នកណាធ្លាប់ប្រើ "ប្រព័ន្ធស្រោចទឹកដោយ Drip" ហើយ? ខ្ញុំចង់ដំឡើង ប៉ុន្តែខ្លាចថ្លៃ ។ តម្លៃប្រហែលប៉ុន្មាន? ❤️ ចូរចែករំលែក!',
      createdAt: now.subtract(const Duration(hours: 8)),
      likes: 34,
      comments: 19,
      shares: 2,
      category: 'question',
      commentList: [],
    ),
    PostModel(
      id: '5',
      authorId: 'u5',
      authorName: 'Weather Alert KH',
      authorEmoji: '⛈️',
      authorRole: 'Weather Service',
      content:
          '⚠️ ព្រឹត្តការណ៍អាកាសធាតុ: ភ្លៀងធ្លាក់ខ្លាំងត្រូវបានព្យាករ ២-៣ ថ្ងៃខាងមុខ នៅតំបន់ Tonle Sap និង Mekong River Basin។ សូមប្រុងប្រយ័ត្នក្នុងការប្រមូលផល!',
      createdAt: now.subtract(const Duration(hours: 12)),
      likes: 204,
      comments: 56,
      shares: 112,
      category: 'news',
      commentList: [],
    ),
  ];
}
