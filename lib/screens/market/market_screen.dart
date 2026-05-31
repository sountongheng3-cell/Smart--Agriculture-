// ============================================================
// PREMIUM AGRICULTURAL MARKET SCREEN
// Modern Fintech-Style Flutter UI — Material 3
// ============================================================
//
// FILE STRUCTURE (single-file for portability):
//   • AppColors         — brand palette
//   • AppTextStyles     — typography system
//   • MarketProduct     — data model
//   • TrendDirection    — enum
//   • MarketScreen      — root screen (StatefulWidget)
//   • _MarketSummaryRow — top stats strip
//   • _SummaryChip      — individual stat card
//   • _ProductCard      — animated product card
//   • _SkeletonCard     — loading placeholder
//   • _EmptyState       — empty / no-results UI
//   • _SearchBar        — custom search field
//   • _QuickActionBtn   — pill CTA on card
//
// Drop this file into lib/features/market/ and adjust
// imports to match your project's path aliases.
// ============================================================

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────────
// 1. DESIGN TOKENS
// ─────────────────────────────────────────────

abstract class AppColors {
  static const primary = Color(0xFF2E7D32);
  static const primaryLight = Color(0xFF4CAF50);
  static const primaryDark = Color(0xFF1B5E20);
  static const accent = Color(0xFFFFC107);
  static const accentDark = Color(0xFFF9A825);
  static const background = Color(0xFFF5F7FA);
  static const surface = Colors.white;
  static const cardShadow = Color(0x14000000);

  static const trendUp = Color(0xFF00C853);
  static const trendDown = Color(0xFFD50000);
  static const trendStable = Color(0xFF0288D1);

  static const trendUpBg = Color(0xFFE8F5E9);
  static const trendDownBg = Color(0xFFFFEBEE);
  static const trendStableBg = Color(0xFFE1F5FE);

  static const textPrimary = Color(0xFF1A1E25);
  static const textSecondary = Color(0xFF6B7280);
  static const textMuted = Color(0xFFB0BAC9);

  static const divider = Color(0xFFEDF1F7);

  static const gradientStart = Color(0xFF2E7D32);
  static const gradientMid = Color(0xFF388E3C);
  static const gradientEnd = Color(0xFF1B5E20);

  static const glassFill = Color(0x22FFFFFF);
  static const glassBorder = Color(0x33FFFFFF);
}

abstract class AppTextStyles {
  static const _base = TextStyle(fontFamily: 'Nunito');

  static final displayLg = _base.copyWith(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static final displaySm = _base.copyWith(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
  );

  static final titleLg = _base.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static final titleSm = _base.copyWith(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static final bodyMd = _base.copyWith(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static final bodySm = _base.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
  );

  static final labelBold = _base.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.4,
  );

  static final priceLg = _base.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
  );

  static final priceSm = _base.copyWith(
    fontSize: 13,
    fontWeight: FontWeight.w600,
  );
}

// ─────────────────────────────────────────────
// 2. DATA MODEL
// ─────────────────────────────────────────────

enum TrendDirection { up, down, stable }

enum ProductCategory { grain, vegetable, fruit, livestock, dairy }

extension ProductCategoryLabel on ProductCategory {
  String get label {
    switch (this) {
      case ProductCategory.grain:
        return 'Grain';
      case ProductCategory.vegetable:
        return 'Vegetable';
      case ProductCategory.fruit:
        return 'Fruit';
      case ProductCategory.livestock:
        return 'Livestock';
      case ProductCategory.dairy:
        return 'Dairy';
    }
  }

  Color get color {
    switch (this) {
      case ProductCategory.grain:
        return const Color(0xFFF59E0B);
      case ProductCategory.vegetable:
        return const Color(0xFF10B981);
      case ProductCategory.fruit:
        return const Color(0xFFEF4444);
      case ProductCategory.livestock:
        return const Color(0xFF8B5CF6);
      case ProductCategory.dairy:
        return const Color(0xFF3B82F6);
    }
  }

  Color get bgColor {
    switch (this) {
      case ProductCategory.grain:
        return const Color(0xFFFEF3C7);
      case ProductCategory.vegetable:
        return const Color(0xFFD1FAE5);
      case ProductCategory.fruit:
        return const Color(0xFFFEE2E2);
      case ProductCategory.livestock:
        return const Color(0xFFEDE9FE);
      case ProductCategory.dairy:
        return const Color(0xFFDBEAFE);
    }
  }
}

class MarketProduct {
  final String id;
  final String name;
  final String emoji;
  final double price;
  final String unit;
  final TrendDirection trend;
  final double changePercent;
  final String lastUpdated;
  final ProductCategory category;
  final double volume; // trading volume in tons

  const MarketProduct({
    required this.id,
    required this.name,
    required this.emoji,
    required this.price,
    required this.unit,
    required this.trend,
    required this.changePercent,
    required this.lastUpdated,
    required this.category,
    required this.volume,
  });

  String get formattedPrice => '\$${price.toStringAsFixed(0)}';
  String get formattedChange =>
      '${trend == TrendDirection.up
          ? '+'
          : trend == TrendDirection.down
          ? '-'
          : ''}${changePercent.toStringAsFixed(1)}%';
}

// ─────────────────────────────────────────────
// 3. MOCK DATA
// ─────────────────────────────────────────────

final _mockProducts = [
  const MarketProduct(
    id: '1',
    name: 'Premium Rice',
    emoji: '🌾',
    price: 250,
    unit: 'ton',
    trend: TrendDirection.up,
    changePercent: 3.4,
    lastUpdated: '2 min ago',
    category: ProductCategory.grain,
    volume: 1240,
  ),
  const MarketProduct(
    id: '2',
    name: 'Yellow Corn',
    emoji: '🌽',
    price: 180,
    unit: 'ton',
    trend: TrendDirection.down,
    changePercent: 1.8,
    lastUpdated: '5 min ago',
    category: ProductCategory.grain,
    volume: 890,
  ),
  const MarketProduct(
    id: '3',
    name: 'Russet Potato',
    emoji: '🥔',
    price: 120,
    unit: 'ton',
    trend: TrendDirection.stable,
    changePercent: 0.2,
    lastUpdated: '8 min ago',
    category: ProductCategory.vegetable,
    volume: 430,
  ),
  const MarketProduct(
    id: '4',
    name: 'Vine Tomato',
    emoji: '🍅',
    price: 90,
    unit: 'ton',
    trend: TrendDirection.up,
    changePercent: 5.6,
    lastUpdated: '1 min ago',
    category: ProductCategory.vegetable,
    volume: 670,
  ),
  const MarketProduct(
    id: '5',
    name: 'Alphonso Mango',
    emoji: '🥭',
    price: 300,
    unit: 'ton',
    trend: TrendDirection.up,
    changePercent: 7.2,
    lastUpdated: 'Just now',
    category: ProductCategory.fruit,
    volume: 310,
  ),
  const MarketProduct(
    id: '6',
    name: 'Red Apple',
    emoji: '🍎',
    price: 220,
    unit: 'ton',
    trend: TrendDirection.down,
    changePercent: 2.1,
    lastUpdated: '10 min ago',
    category: ProductCategory.fruit,
    volume: 580,
  ),
  const MarketProduct(
    id: '7',
    name: 'Soybeans',
    emoji: '🫘',
    price: 195,
    unit: 'ton',
    trend: TrendDirection.up,
    changePercent: 1.5,
    lastUpdated: '3 min ago',
    category: ProductCategory.grain,
    volume: 2100,
  ),
  const MarketProduct(
    id: '8',
    name: 'Fresh Spinach',
    emoji: '🥬',
    price: 65,
    unit: 'ton',
    trend: TrendDirection.down,
    changePercent: 4.3,
    lastUpdated: '7 min ago',
    category: ProductCategory.vegetable,
    volume: 200,
  ),
];

// ─────────────────────────────────────────────
// 4. MARKET SCREEN
// ─────────────────────────────────────────────

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen>
    with TickerProviderStateMixin {
  // State
  bool _isLoading = true;
  bool _isRefreshing = false;
  String _searchQuery = '';
  ProductCategory? _selectedCategory;
  List<MarketProduct> _products = [];
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  // Animations
  late AnimationController _fadeCtrl;
  late AnimationController _headerCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _headerSlide;

  @override
  void initState() {
    super.initState();

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _headerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOutCubic));

    _loadData();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _headerCtrl.dispose();
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    // Simulate network fetch
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;
    setState(() {
      _products = _mockProducts;
      _isLoading = false;
    });
    _headerCtrl.forward();
    _fadeCtrl.forward();
  }

  Future<void> _onRefresh() async {
    setState(() => _isRefreshing = true);
    HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    // Randomise a trend for demo
    setState(() => _isRefreshing = false);
    HapticFeedback.selectionClick();
  }

  List<MarketProduct> get _filteredProducts {
    var list = _products;
    if (_selectedCategory != null) {
      list = list.where((p) => p.category == _selectedCategory).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((p) => p.name.toLowerCase().contains(q)).toList();
    }
    return list;
  }

  int get _upCount =>
      _products.where((p) => p.trend == TrendDirection.up).length;
  int get _downCount =>
      _products.where((p) => p.trend == TrendDirection.down).length;

  // ── Build ──────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: RefreshIndicator(
          onRefresh: _onRefresh,
          color: AppColors.accent,
          backgroundColor: AppColors.surface,
          displacement: 80,
          child: CustomScrollView(
            controller: _scrollCtrl,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ── Gradient AppBar ──
              _buildSliverAppBar(isTablet),

              // ── Search Bar ──
              SliverToBoxAdapter(child: _buildSearchBar()),

              // ── Category Filters ──
              SliverToBoxAdapter(child: _buildCategoryFilters()),

              // ── Market Summary ──
              if (!_isLoading)
                SliverToBoxAdapter(
                  child: SlideTransition(
                    position: _headerSlide,
                    child: FadeTransition(
                      opacity: _fadeAnim,
                      child: _MarketSummaryRow(
                        total: _products.length,
                        upCount: _upCount,
                        downCount: _downCount,
                      ),
                    ),
                  ),
                ),

              // ── Product List or Skeleton or Empty ──
              _buildBody(isTablet),

              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
        ),
      ),
    );
  }

  // ── Sliver App Bar ──────────────────────────

  Widget _buildSliverAppBar(bool isTablet) {
    return SliverAppBar(
      expandedHeight: isTablet ? 200 : 185,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.primary,
      // Remove the back arrow on web/tablet
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: _AppBarBackground(isTablet: isTablet),
      ),
      bottom: PreferredSize(
        // Tell Flutter the true height so it reserves space correctly
        preferredSize: const Size.fromHeight(24),
        child: Container(
          height: 24,
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
        ),
      ),
    );
  }

  // ── Search Bar ──────────────────────────────

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: _SearchBar(
        controller: _searchCtrl,
        onChanged: (v) => setState(() => _searchQuery = v),
        onClear: () {
          _searchCtrl.clear();
          setState(() => _searchQuery = '');
        },
      ),
    );
  }

  // ── Category Filters ────────────────────────

  Widget _buildCategoryFilters() {
    final categories = ProductCategory.values;
    return SizedBox(
      height: 44,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (ctx, i) {
          if (i == 0) {
            return _CategoryChip(
              label: 'All',
              isSelected: _selectedCategory == null,
              color: AppColors.primary,
              bgColor: AppColors.trendUpBg,
              onTap: () => setState(() => _selectedCategory = null),
            );
          }
          final cat = categories[i - 1];
          return _CategoryChip(
            label: cat.label,
            isSelected: _selectedCategory == cat,
            color: cat.color,
            bgColor: cat.bgColor,
            onTap: () => setState(
              () => _selectedCategory = _selectedCategory == cat ? null : cat,
            ),
          );
        },
      ),
    );
  }

  // ── Body ────────────────────────────────────

  Widget _buildBody(bool isTablet) {
    if (_isLoading) {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (_, i) => const _SkeletonCard(),
          childCount: 5,
        ),
      );
    }

    final items = _filteredProducts;
    if (items.isEmpty) {
      return const SliverToBoxAdapter(child: _EmptyState());
    }

    if (isTablet) {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverGrid(
          delegate: SliverChildBuilderDelegate(
            (ctx, i) => _AnimatedProductCard(product: items[i], index: i),
            childCount: items.length,
          ),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 1.7,
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (ctx, i) => _AnimatedProductCard(product: items[i], index: i),
          childCount: items.length,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 5. APP BAR BACKGROUND (Gradient + Overlay)
// ─────────────────────────────────────────────

class _AppBarBackground extends StatelessWidget {
  final bool isTablet;
  const _AppBarBackground({required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.gradientEnd,
            AppColors.gradientMid,
            AppColors.gradientStart,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Decorative circles (glassmorphism blobs)
          Positioned(
            top: -30,
            right: -20,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: -40,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.07),
              ),
            ),
          ),

          // Content
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      // Logo chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.glassFill,
                          border: Border.all(color: AppColors.glassBorder),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🌿', style: TextStyle(fontSize: 14)),
                            const SizedBox(width: 5),
                            Text(
                              'AgroMarket',
                              style: AppTextStyles.labelBold.copyWith(
                                color: Colors.white,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      // Notification bell
                      _GlassIconBtn(
                        icon: Icons.notifications_outlined,
                        onTap: () {},
                      ),
                      const SizedBox(width: 8),
                      _GlassIconBtn(icon: Icons.tune_rounded, onTap: () {}),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Market Prices',
                    style: AppTextStyles.displayLg.copyWith(
                      color: Colors.white,
                      letterSpacing: -0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Live agricultural commodity rates',
                    style: AppTextStyles.bodyMd.copyWith(
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 6. GLASS ICON BUTTON
// ─────────────────────────────────────────────

class _GlassIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _GlassIconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.glassFill,
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 7. CUSTOM SEARCH BAR
// ─────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchBar({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          Icon(Icons.search_rounded, color: AppColors.textMuted, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: AppTextStyles.titleSm.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Search products…',
                hintStyle: AppTextStyles.bodyMd.copyWith(
                  color: AppColors.textMuted,
                ),
                isDense: true,
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            GestureDetector(
              onTap: onClear,
              child: Container(
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.textMuted,
                ),
                child: const Icon(Icons.close, size: 14, color: Colors.white),
              ),
            ),
          const SizedBox(width: 8),
          Container(width: 1, height: 24, color: AppColors.divider),
          GestureDetector(
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  Icon(
                    Icons.bar_chart_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Sort',
                    style: AppTextStyles.labelBold.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 8. CATEGORY CHIP
// ─────────────────────────────────────────────

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? color : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : AppColors.divider,
              width: 1.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [],
          ),
          child: Text(
            label,
            style: AppTextStyles.labelBold.copyWith(
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 9. MARKET SUMMARY ROW
// ─────────────────────────────────────────────

class _MarketSummaryRow extends StatelessWidget {
  final int total;
  final int upCount;
  final int downCount;

  const _MarketSummaryRow({
    required this.total,
    required this.upCount,
    required this.downCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            _SummaryChip(
              label: 'Total',
              value: '$total',
              icon: '📊',
              iconBg: Colors.white12,
            ),
            _VerticalDivider(),
            _SummaryChip(
              label: 'Rising',
              value: '$upCount',
              icon: '📈',
              iconBg: Colors.white12,
            ),
            _VerticalDivider(),
            _SummaryChip(
              label: 'Falling',
              value: '$downCount',
              icon: '📉',
              iconBg: Colors.white12,
            ),
            _VerticalDivider(),
            _SummaryChip(
              label: 'Stable',
              value: '${total - upCount - downCount}',
              icon: '➡️',
              iconBg: Colors.white12,
            ),
          ],
        ),
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      color: Colors.white24,
      margin: const EdgeInsets.symmetric(horizontal: 6),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final String value;
  final String icon;
  final Color iconBg;

  const _SummaryChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconBg,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.titleLg.copyWith(
              color: Colors.white,
              fontSize: 17,
            ),
          ),
          Text(
            label,
            style: AppTextStyles.bodySm.copyWith(
              color: Colors.white60,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 10. ANIMATED PRODUCT CARD
// ─────────────────────────────────────────────

class _AnimatedProductCard extends StatefulWidget {
  final MarketProduct product;
  final int index;

  const _AnimatedProductCard({required this.product, required this.index});

  @override
  State<_AnimatedProductCard> createState() => _AnimatedProductCardState();
}

class _AnimatedProductCardState extends State<_AnimatedProductCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    // Stagger
    Future.delayed(Duration(milliseconds: 80 * widget.index), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: GestureDetector(
            onTapDown: (_) => setState(() => _pressed = true),
            onTapUp: (_) => setState(() => _pressed = false),
            onTapCancel: () => setState(() => _pressed = false),
            onTap: () {
              HapticFeedback.lightImpact();
              // Navigate to product detail
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              transform: Matrix4.identity()..scale(_pressed ? 0.975 : 1.0),
              transformAlignment: Alignment.center,
              child: _ProductCard(product: widget.product),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final MarketProduct product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final trend = product.trend;
    final trendColor = trend == TrendDirection.up
        ? AppColors.trendUp
        : trend == TrendDirection.down
        ? AppColors.trendDown
        : AppColors.trendStable;
    final trendBg = trend == TrendDirection.up
        ? AppColors.trendUpBg
        : trend == TrendDirection.down
        ? AppColors.trendDownBg
        : AppColors.trendStableBg;
    final trendIcon = trend == TrendDirection.up
        ? Icons.trending_up_rounded
        : trend == TrendDirection.down
        ? Icons.trending_down_rounded
        : Icons.trending_flat_rounded;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Row 1: icon + info + price
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Emoji icon with category color background
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: product.category.bgColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      product.emoji,
                      style: const TextStyle(fontSize: 30),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Name + category + updated
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category label
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: product.category.bgColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          product.category.label.toUpperCase(),
                          style: AppTextStyles.labelBold.copyWith(
                            color: product.category.color,
                            fontSize: 10,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(product.name, style: AppTextStyles.titleSm),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 11,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            product.lastUpdated,
                            style: AppTextStyles.bodySm,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Price block
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(product.formattedPrice, style: AppTextStyles.priceLg),
                    Text('/ ${product.unit}', style: AppTextStyles.bodySm),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Row 2: trend badge + volume + quick action
            Row(
              children: [
                // Trend badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: trendBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(trendIcon, size: 15, color: trendColor),
                      const SizedBox(width: 4),
                      Text(
                        product.formattedChange,
                        style: AppTextStyles.priceSm.copyWith(
                          color: trendColor,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Volume
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.swap_horiz_rounded,
                        size: 13,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${product.volume.toStringAsFixed(0)}t vol',
                        style: AppTextStyles.bodySm.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Quick action button
                _QuickActionBtn(onTap: () => HapticFeedback.mediumImpact()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 11. QUICK ACTION BUTTON
// ─────────────────────────────────────────────

class _QuickActionBtn extends StatelessWidget {
  final VoidCallback onTap;
  const _QuickActionBtn({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primaryLight, AppColors.primary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.35),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.bolt_rounded, color: Colors.white, size: 14),
            const SizedBox(width: 4),
            Text(
              'Trade',
              style: AppTextStyles.labelBold.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 12. SKELETON LOADING CARD
// ─────────────────────────────────────────────

class _SkeletonCard extends StatefulWidget {
  const _SkeletonCard();

  @override
  State<_SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<_SkeletonCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: AnimatedBuilder(
        animation: _anim,
        builder: (_, __) {
          final shimmer = Color.lerp(
            const Color(0xFFEDF1F7),
            const Color(0xFFDDE3EE),
            _anim.value,
          )!;

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    _Bone(w: 58, h: 58, r: 16, color: shimmer),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Bone(w: 60, h: 14, r: 6, color: shimmer),
                          const SizedBox(height: 8),
                          _Bone(w: 120, h: 16, r: 8, color: shimmer),
                          const SizedBox(height: 6),
                          _Bone(w: 80, h: 11, r: 6, color: shimmer),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _Bone(w: 70, h: 20, r: 8, color: shimmer),
                        const SizedBox(height: 4),
                        _Bone(w: 40, h: 11, r: 6, color: shimmer),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _Bone(w: 80, h: 30, r: 10, color: shimmer),
                    const SizedBox(width: 8),
                    _Bone(w: 90, h: 30, r: 10, color: shimmer),
                    const Spacer(),
                    _Bone(w: 76, h: 32, r: 12, color: shimmer),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Bone extends StatelessWidget {
  final double w;
  final double h;
  final double r;
  final Color color;

  const _Bone({
    required this.w,
    required this.h,
    required this.r,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(r),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 13. EMPTY STATE
// ─────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 60),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.trendUpBg,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('🌱', style: TextStyle(fontSize: 46)),
            ),
          ),
          const SizedBox(height: 20),
          Text('No Products Found', style: AppTextStyles.titleLg),
          const SizedBox(height: 8),
          Text(
            'Try a different search term or reset the category filter.',
            style: AppTextStyles.bodyMd,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryLight, AppColors.primary],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                'Clear Filters',
                style: AppTextStyles.labelBold.copyWith(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 14. ENTRY POINT (remove if integrating into existing app)
// ─────────────────────────────────────────────

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
      ),
      home: const MarketScreen(),
    ),
  );
}
