import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/app_sheets.dart';
import '../widgets/ui.dart';
import 'restaurant_screen.dart';
import 'tracking_screen.dart';

const _sortLabels = {
  'relevance': 'الأكثر ملاءمة',
  'rating': 'الأعلى تقييماً',
  'fast': 'الأسرع توصيلاً',
  'fee': 'الأقل رسوم توصيل',
};

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  String? _selectedCategory;
  String _query = '';
  bool _gridView = false;
  String _sortMode = 'relevance';
  bool _freeDeliveryOnly = false;

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  List<Restaurant> get _filteredRestaurants {
    var list = restaurants.toList();
    if (_selectedCategory != null) {
      list = list
          .where((restaurant) => restaurant.tags.contains(_selectedCategory))
          .toList();
    }
    if (_freeDeliveryOnly) {
      list = list.where((r) => r.deliveryFee == 0).toList();
    }
    if (_query.trim().isNotEmpty) {
      final query = _query.trim();
      list = list.where((restaurant) {
        return restaurant.name.contains(query) ||
            restaurant.cuisine.contains(query) ||
            restaurant.menu.any((item) => item.name.contains(query));
      }).toList();
    }
    switch (_sortMode) {
      case 'rating':
        list.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'fast':
        list.sort((a, b) => a.deliveryMin.compareTo(b.deliveryMin));
        break;
      case 'fee':
        list.sort((a, b) => a.deliveryFee.compareTo(b.deliveryFee));
        break;
    }
    return list;
  }

  Future<void> _handleNavTap(int index) async {
    switch (index) {
      case 1:
        await showSearchOverlay(context);
        break;
      case 2:
        await showOrdersSheet(context);
        break;
      case 3:
        await showProfileSheet(context);
        break;
      default:
        _searchFocus.unfocus();
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
        );
    }
  }

  void _openRestaurant(Restaurant restaurant) {
    Navigator.of(context)
        .push(premiumRoute(RestaurantScreen(restaurant: restaurant)));
  }

  void _openBrand(BrandTile brand) {
    final target = brand.restaurantId == null
        ? null
        : restaurants
              .where((r) => r.id == brand.restaurantId)
              .firstOrNull;
    _openRestaurant(target ?? restaurants.first);
  }

  void _openCart() {
    final state = AppScope.of(context, listen: false);
    final restaurant = state.cartRestaurant;
    if (restaurant != null) {
      Navigator.of(context)
          .push(premiumRoute(RestaurantScreen(restaurant: restaurant)));
      return;
    }
    showAppSnackBar(
      context,
      'سلتك فارغة — تصفح المطاعم وأضف ما يشتهيه قلبك',
      icon: Icons.shopping_bag_rounded,
    );
  }

  void _showFilterSheet() {
    var sortMode = _sortMode;
    var freeOnly = _freeDeliveryOnly;
    showAppSheet(
      context: context,
      heightFactor: 0.56,
      dismissible: true,
      child: StatefulBuilder(
        builder: (sheetContext, setSheetState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                const Center(child: SheetHandle()),
                const SizedBox(height: 18),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text('تصفية النتائج', style: AppTextStyles.title),
                      ),
                      SoftIconButton(
                        icon: Icons.close_rounded,
                        size: 38,
                        iconSize: 18,
                        shadow: false,
                        background: AppColors.inkSoft,
                        onTap: () => Navigator.pop(sheetContext),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(22, 18, 22, 8),
                    children: [
                      Text(
                        'ترتيب النتائج',
                        style: AppTextStyles.label
                            .copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 8),
                      ..._sortLabels.entries.map((entry) {
                        final selected = sortMode == entry.key;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Material(
                            color: selected
                                ? AppColors.primarySoft
                                : AppColors.surfaceLow,
                            borderRadius: BorderRadius.circular(12),
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              onTap: () => setSheetState(
                                () => sortMode = entry.key,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 13,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      selected
                                          ? Icons.radio_button_checked_rounded
                                          : Icons.radio_button_off_rounded,
                                      size: 20,
                                      color: selected
                                          ? AppColors.primary
                                          : AppColors.textTertiary,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        entry.value,
                                        style: AppTextStyles.label,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 12),
                      SwitchListTile(
                        value: freeOnly,
                        onChanged: (value) =>
                            setSheetState(() => freeOnly = value),
                        activeTrackColor: AppColors.primary,
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          'توصيل مجاني فقط',
                          style: AppTextStyles.label,
                        ),
                        subtitle: Text(
                          'إظهار المطاعم التي توصيل مجاناً',
                          style: AppTextStyles.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 6, 22, 18),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        setState(() {
                          _sortMode = sortMode;
                          _freeDeliveryOnly = freeOnly;
                        });
                        Navigator.pop(sheetContext);
                      },
                      child: const Text('تطبيق التصفية'),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final filtered = _filteredRestaurants;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _YallaHeader(
              address: state.address,
              cartCount: state.cartCount,
              onBack: () => Navigator.maybePop(context),
              onAddressTap: () => showAddressPicker(context),
              onCartTap: _openCart,
              searchController: _searchController,
              searchFocus: _searchFocus,
              onQueryChanged: (value) => setState(() => _query = value),
            ),
            Expanded(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 118),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _CategoriesSection(
                          selectedCategory: _selectedCategory,
                          onCategoryTap: _toggleCategory,
                        ),
                        _BrandsSection(onBrandTap: _openBrand),
                        _SortBar(
                          sortLabel: _sortLabels[_sortMode]!,
                          gridView: _gridView,
                          onSortTap: _showFilterSheet,
                          onViewToggle: () =>
                              setState(() => _gridView = !_gridView),
                        ),
                        if (filtered.isEmpty)
                          const _EmptyResults()
                        else if (_gridView)
                          _RestaurantGrid(
                            restaurants: filtered,
                            onOpen: _openRestaurant,
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                            child: Column(
                              children: [
                                for (final restaurant in filtered) ...[
                                  _RestaurantCard(
                                    restaurant: restaurant,
                                    onTap: () => _openRestaurant(restaurant),
                                  ),
                                  const SizedBox(height: 12),
                                ],
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 14,
                    child: Center(
                      child: _FloatingFilterPill(
                        onMapTap: () => Navigator.of(
                          context,
                        ).push(premiumRoute(const TrackingScreen())),
                        onFilterTap: _showFilterSheet,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 0,
        onTap: _handleNavTap,
      ),
    );
  }

  void _toggleCategory(String id) {
    setState(() {
      // "الكل" always resets the filter — every other tile toggles itself.
      if (id == 'الكل') {
        _selectedCategory = null;
        return;
      }
      _selectedCategory = _selectedCategory == id ? null : id;
    });
  }
}

// ---------------------------------------------------------------------------
// Orange gradient header with address pill, cart button, search and the
// signature saw-tooth divider (design 0).
// ---------------------------------------------------------------------------

class _YallaHeader extends StatelessWidget {
  const _YallaHeader({
    required this.address,
    required this.cartCount,
    required this.onBack,
    required this.onAddressTap,
    required this.onCartTap,
    required this.searchController,
    required this.searchFocus,
    required this.onQueryChanged,
  });

  final String address;
  final int cartCount;
  final VoidCallback onBack;
  final VoidCallback onAddressTap;
  final VoidCallback onCartTap;
  final TextEditingController searchController;
  final FocusNode searchFocus;
  final ValueChanged<String> onQueryChanged;

  String get _shortAddress {
    final parts = address.split('،');
    if (parts.length >= 2) return '${parts[0]}، ${parts[1]}';
    return address;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFF591B), Color(0xFFFF3E00)],
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: Column(
              children: [
                Row(
                  children: [
                    _GlassCircleButton(
                      icon: Icons.arrow_back,
                      iconSize: 24,
                      tooltip: 'رجوع',
                      onTap: onBack,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Material(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(999),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: onAddressTap,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.location_on_rounded,
                                  size: 18,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'التوصيل إلى',
                                        style: AppTextStyles.caption.copyWith(
                                          color: Colors.white.withValues(
                                            alpha: 0.8,
                                          ),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              _shortAddress,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: AppTextStyles.caption
                                                  .copyWith(
                                                    color: Colors.white,
                                                    fontSize: 13,
                                                    fontWeight:
                                                        FontWeight.w700,
                                                  ),
                                            ),
                                          ),
                                          const Icon(
                                            Icons.expand_more_rounded,
                                            size: 16,
                                            color: Colors.white,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        _GlassCircleButton(
                          icon: Icons.shopping_bag_rounded,
                          iconSize: 22,
                          tooltip: 'سلة المشتريات',
                          onTap: onCartTap,
                        ),
                        if (cartCount > 0)
                          Positioned(
                            top: 4,
                            left: 4,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // White search bar.
                Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: searchController,
                    focusNode: searchFocus,
                    textDirection: TextDirection.rtl,
                    onChanged: onQueryChanged,
                    onSubmitted: (_) => searchFocus.unfocus(),
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'ابحث عن اسم مطعم، وجبة أو نوع المطبخ...',
                      hintStyle: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary.withValues(
                          alpha: 0.8,
                        ),
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                      suffixIcon: searchController.text.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(
                                Icons.close_rounded,
                                size: 18,
                                color: AppColors.textTertiary,
                              ),
                              onPressed: () {
                                searchController.clear();
                                onQueryChanged('');
                              },
                            ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 13,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Saw-tooth white divider.
          CustomPaint(
            size: const Size(double.infinity, 30),
            painter: _SawtoothPainter(),
          ),
        ],
      ),
    );
  }
}

class _GlassCircleButton extends StatelessWidget {
  const _GlassCircleButton({
    required this.icon,
    required this.onTap,
    this.iconSize = 20,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onTap;
  final double iconSize;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: Colors.white.withValues(alpha: 0.2),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, size: iconSize, color: Colors.white),
        ),
      ),
    );
    if (tooltip == null) return button;
    return Tooltip(message: tooltip!, child: button);
  }
}

class _SawtoothPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final sx = w / 1440;
    final sy = h / 80;

    final wavePaint1 = Paint()..color = Colors.white.withValues(alpha: 0.28);
    final wave1 = Path()
      ..moveTo(0, 36 * sy)
      ..cubicTo(180 * sx, 62 * sy, 360 * sx, 18 * sy, 540 * sx, 42 * sy)
      ..cubicTo(720 * sx, 66 * sy, 900 * sx, 14 * sy, 1080 * sx, 40 * sy)
      ..cubicTo(1260 * sx, 66 * sy, 1380 * sx, 24 * sy, 1440 * sx, 32 * sy)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(wave1, wavePaint1);

    final wavePaint2 = Paint()..color = Colors.white;
    final wave2 = Path()
      ..moveTo(0, 52 * sy)
      ..cubicTo(220 * sx, 20 * sy, 440 * sx, 68 * sy, 700 * sx, 44 * sy)
      ..cubicTo(960 * sx, 20 * sy, 1200 * sx, 64 * sy, 1440 * sx, 46 * sy)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(wave2, wavePaint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ---------------------------------------------------------------------------
// Food categories strip (design 0).
// ---------------------------------------------------------------------------

class _CategoriesSection extends StatelessWidget {
  const _CategoriesSection({
    required this.selectedCategory,
    required this.onCategoryTap,
  });

  final String? selectedCategory;
  final ValueChanged<String> onCategoryTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.surfaceLow)),
      ),
      padding: const EdgeInsets.only(top: 12, bottom: 14),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'التصنيفات الغذائية',
                    style: AppTextStyles.titleSmall,
                  ),
                ),
                InkWell(
                  onTap: () => onCategoryTap('الكل'),
                  borderRadius: BorderRadius.circular(8),
                  child: Text(
                    'عرض الكل',
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 96,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _CategoryTile(
                  label: 'الكل',
                  selected: selectedCategory == null,
                  selectedStyle: true,
                  onTap: () => onCategoryTap('الكل'),
                ),
                const SizedBox(width: 12),
                for (final category in foodCategories) ...[
                  _CategoryTile(
                    label: category.label,
                    image: category.image,
                    selected: selectedCategory == category.id,
                    onTap: () => onCategoryTap(category.id),
                  ),
                  const SizedBox(width: 12),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.label,
    required this.selected,
    required this.onTap,
    this.image,
    this.selectedStyle = false,
  });

  final String label;
  final String? image;
  final bool selected;
  final bool selectedStyle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final highlight = selectedStyle && selected;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: highlight ? AppColors.primary : AppColors.surfaceLow,
              borderRadius: BorderRadius.circular(16),
              border: selected && !selectedStyle
                  ? Border.all(color: AppColors.primary, width: 2)
                  : null,
              boxShadow: highlight
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            clipBehavior: Clip.antiAlias,
            child: image == null
                ? const Icon(
                    Icons.restaurant_rounded,
                    size: 28,
                    color: Colors.white,
                  )
                : AppImage(image!, fit: BoxFit.cover),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: selected ? AppColors.primary : AppColors.textPrimary,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Top brands grid (design 0) — two stacked rows flowing horizontally.
// ---------------------------------------------------------------------------

class _BrandsSection extends StatelessWidget {
  const _BrandsSection({required this.onBrandTap});

  final ValueChanged<BrandTile> onBrandTap;

  @override
  Widget build(BuildContext context) {
    final pairs = <Widget>[];
    for (var i = 0; i < topBrands.length; i += 2) {
      pairs.add(
        Column(
          children: [
            _BrandTileWidget(brand: topBrands[i], onTap: () => onBrandTap(topBrands[i])),
            const SizedBox(height: 14),
            if (i + 1 < topBrands.length)
              _BrandTileWidget(
                brand: topBrands[i + 1],
                onTap: () => onBrandTap(topBrands[i + 1]),
              ),
          ],
        ),
      );
    }

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.surfaceLow)),
      ),
      padding: const EdgeInsets.only(top: 4, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.workspace_premium_rounded,
                    size: 16,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'أفضل العلامات التجارية',
                    style: AppTextStyles.titleSmall,
                  ),
                ),
                InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(8),
                  child: Row(
                    children: [
                      Text(
                        'عرض الكل',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(
                        Icons.chevron_right,
                        size: 16,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 222,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                for (final pair in pairs) ...[pair, const SizedBox(width: 14)],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandTileWidget extends StatelessWidget {
  const _BrandTileWidget({required this.brand, required this.onTap});

  final BrandTile brand;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 68,
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 68,
                  height: 68,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: brand.color,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: brand.color.withValues(alpha: 0.2),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: _BrandLogo(logoType: brand.logoType),
                ),
                if (brand.badge != null)
                  Positioned(
                    top: -6,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: brand.badgeColor ?? AppColors.primary,
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Text(
                        brand.badge!,
                        style: const TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          height: 1.1,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              brand.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              brand.time ?? '',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
                fontSize: 10,
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Renders the colored monogram/logo of each brand tile.
class _BrandLogo extends StatelessWidget {
  const _BrandLogo({required this.logoType});

  final String logoType;

  @override
  Widget build(BuildContext context) {
    switch (logoType) {
      case 'arches':
        return CustomPaint(
          size: const Size(52, 52),
          painter: _ArchesPainter(),
        );
      case 'kfc':
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'KFC',
              style: TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: Colors.white,
                height: 1,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (_) {
                return Container(
                  width: 3.5,
                  height: 3.5,
                  margin: const EdgeInsets.symmetric(horizontal: 1.5),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),
          ],
        );
      case 'hut':
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomPaint(
              size: const Size(44, 26),
              painter: _HutRoofPainter(),
            ),
            const SizedBox(height: 3),
            const Text(
              'Pizza Hut',
              style: TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontSize: 8,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1,
              ),
            ),
          ],
        );
      case 'kudu':
        return Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'kudu',
              style: TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFFFF8200),
                height: 1,
              ),
            ),
          ),
        );
      case 'albaik':
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Text('🍗', style: TextStyle(fontSize: 13)),
            ),
            const SizedBox(height: 4),
            const Text(
              'ALBAIK',
              style: TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontSize: 8,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4,
                color: Color(0xFFFFC72C),
                height: 1,
              ),
            ),
          ],
        );
      case 'shawarmer':
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Text('🌯', style: TextStyle(fontSize: 13)),
            ),
            const SizedBox(height: 4),
            const Text(
              'شاورمر',
              style: TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1,
              ),
            ),
          ],
        );
      case 'boutique':
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.lunch_dining_rounded,
                size: 15,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'BOUTIQUE',
              style: TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontSize: 7.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.8,
                color: Color(0xFFFFB59E),
                height: 1,
              ),
            ),
          ],
        );
      case 'maestro':
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Text('🍕', style: TextStyle(fontSize: 13)),
            ),
            const SizedBox(height: 4),
            const Text(
              'MAESTRO',
              style: TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontSize: 8,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4,
                color: Color(0xFFFFC72C),
                height: 1,
              ),
            ),
          ],
        );
      default:
        return const Icon(Icons.restaurant_rounded, color: Colors.white);
    }
  }
}

class _ArchesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final sx = w / 108;
    final sy = h / 108;
    final paint = Paint()..color = const Color(0xFFFFC72C);
    final path = Path()
      ..moveTo(20 * sx, 88 * sy)
      ..lineTo(20 * sx, 50 * sy)
      ..cubicTo(20 * sx, 34 * sy, 32 * sx, 20 * sy, 46 * sx, 20 * sy)
      ..cubicTo(54 * sx, 20 * sy, 60 * sx, 25 * sy, 64 * sx, 33 * sy)
      ..cubicTo(68 * sx, 25 * sy, 74 * sx, 20 * sy, 82 * sx, 20 * sy)
      ..cubicTo(96 * sx, 20 * sy, 108 * sx, 34 * sy, 108 * sx, 50 * sy)
      ..lineTo(108 * sx, 88 * sy)
      ..lineTo(90 * sx, 88 * sy)
      ..lineTo(90 * sx, 52 * sy)
      ..cubicTo(90 * sx, 41 * sy, 83 * sx, 36 * sy, 74 * sx, 36 * sy)
      ..cubicTo(65 * sx, 36 * sy, 58 * sx, 41 * sy, 58 * sx, 52 * sy)
      ..lineTo(58 * sx, 88 * sy)
      ..lineTo(40 * sx, 88 * sy)
      ..lineTo(40 * sx, 52 * sy)
      ..cubicTo(40 * sx, 41 * sy, 33 * sx, 36 * sy, 24 * sx, 36 * sy)
      ..cubicTo(15 * sx, 36 * sy, 10 * sx, 41 * sy, 10 * sx, 52 * sy)
      ..lineTo(10 * sx, 88 * sy)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HutRoofPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final sx = w / 100;
    final sy = h / 60;

    final white = Paint()..color = Colors.white;
    final black = Paint()..color = Colors.black;

    final path1 = Path()
      ..moveTo(10 * sx, 42 * sy)
      ..cubicTo(30 * sx, 38 * sy, 70 * sx, 38 * sy, 90 * sx, 42 * sy)
      ..lineTo(95 * sx, 46 * sy)
      ..cubicTo(65 * sx, 40 * sy, 35 * sx, 40 * sy, 5 * sx, 46 * sy)
      ..close();
    canvas.drawPath(path1, white);

    final path2 = Path()
      ..moveTo(28 * sx, 38 * sy)
      ..lineTo(38 * sx, 18 * sy)
      ..lineTo(62 * sx, 18 * sy)
      ..lineTo(72 * sx, 38 * sy)
      ..cubicTo(56 * sx, 34 * sy, 44 * sx, 34 * sy, 28 * sx, 38 * sy)
      ..close();
    canvas.drawPath(path2, white);

    final path3 = Path()
      ..moveTo(4 * sx, 48 * sy)
      ..cubicTo(34 * sx, 43 * sy, 66 * sx, 43 * sy, 96 * sx, 48 * sy)
      ..lineTo(92 * sx, 53 * sy)
      ..cubicTo(64 * sx, 48 * sy, 36 * sx, 48 * sy, 8 * sx, 53 * sy)
      ..close();
    canvas.drawPath(path3, black);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ---------------------------------------------------------------------------
// Sort / view-toggle bar (design 0).
// ---------------------------------------------------------------------------

class _SortBar extends StatelessWidget {
  const _SortBar({
    required this.sortLabel,
    required this.gridView,
    required this.onSortTap,
    required this.onViewToggle,
  });

  final String sortLabel;
  final bool gridView;
  final VoidCallback onSortTap;
  final VoidCallback onViewToggle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      child: Row(
        children: [
          Text(
            'ترتيب حسب:',
            style: AppTextStyles.bodySmall.copyWith(fontSize: 12.5),
          ),
          const SizedBox(width: 6),
          Material(
            color: AppColors.surfaceLow,
            borderRadius: BorderRadius.circular(8),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onSortTap,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.surfaceContainer),
                ),
                child: Row(
                  children: [
                    Text(
                      sortLabel,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textPrimary,
                        fontSize: 12.5,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 16,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.surfaceLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.surfaceContainer),
            ),
            child: Row(
              children: [
                _ViewToggleIcon(
                  icon: Icons.view_agenda_rounded,
                  active: !gridView,
                  tooltip: 'عرض قائمة',
                  onTap: onViewToggle,
                ),
                const SizedBox(width: 2),
                _ViewToggleIcon(
                  icon: Icons.grid_view_rounded,
                  active: gridView,
                  tooltip: 'عرض شبكي',
                  onTap: onViewToggle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ViewToggleIcon extends StatelessWidget {
  const _ViewToggleIcon({
    required this.icon,
    required this.active,
    required this.onTap,
    this.tooltip,
  });

  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: active ? Colors.white : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 32,
          height: 32,
          child: Icon(
            icon,
            size: 18,
            color: active ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
    if (tooltip == null) return button;
    return Tooltip(message: tooltip!, child: button);
  }
}

class _EmptyResults extends StatelessWidget {
  const _EmptyResults();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 48),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off_rounded,
              size: 34,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text('لا توجد نتائج مطابقة', style: AppTextStyles.titleSmall),
          const SizedBox(height: 6),
          Text(
            'جرّب كلمة بحث مختلفة أو غيّر التصفية',
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Restaurant cards — list layout (design 0).
// ---------------------------------------------------------------------------

class _RestaurantCard extends StatelessWidget {
  const _RestaurantCard({required this.restaurant, required this.onTap});

  final Restaurant restaurant;
  final VoidCallback onTap;

  IconData get _footerIcon {
    switch (restaurant.footerIcon) {
      case 'fire':
        return Icons.local_fire_department_rounded;
      case 'bolt':
        return Icons.bolt_rounded;
      case 'offer':
        return Icons.local_offer_rounded;
      case 'ticket':
        return Icons.confirmation_number_rounded;
      case 'like':
        return Icons.thumb_up_rounded;
      case 'verified':
        return Icons.verified_rounded;
      case 'favorite':
        return Icons.favorite_rounded;
      default:
        return Icons.local_offer_rounded;
    }
  }

  Color get _footerColor {
    switch (restaurant.footerTone) {
      case FooterTone.green:
        return AppColors.green;
      case FooterTone.amber:
        return AppColors.amber;
      case FooterTone.orange:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final isFavorite = state.isFavorite(restaurant.id);
    final latin = latinBrandNames[restaurant.id];
    final displayName = latin == null
        ? restaurant.name
        : '${restaurant.name} ($latin)';
    final boxedFooter = restaurant.footerIcon == 'fire';

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.surfaceHigh.withValues(alpha: 0.6),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _RestaurantThumb(
                restaurant: restaurant,
                isFavorite: isFavorite,
                width: 112,
                height: 112,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 112),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      displayName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextStyles.titleSmall.copyWith(
                                        fontSize: 15.5,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      restaurant.cuisine,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextStyles.bodySmall.copyWith(
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6),
                              _RatingChip(rating: restaurant.rating),
                            ],
                          ),
                          const SizedBox(height: 6),
                          _DeliveryMeta(restaurant: restaurant),
                        ],
                      ),
                      if (boxedFooter)
                        _BoxedFooter(
                          icon: _footerIcon,
                          color: _footerColor,
                          text: restaurant.footerText ?? '',
                        )
                      else if (restaurant.footerText != null)
                        Row(
                          children: [
                            Icon(
                              _footerIcon,
                              size: 14,
                              color: _footerColor,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                restaurant.footerText!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 11,
                                ),
                              ),
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
      ),
    );
  }
}

class _RestaurantThumb extends StatelessWidget {
  const _RestaurantThumb({
    required this.restaurant,
    required this.isFavorite,
    this.width = 112,
    this.height = 112,
    this.radius = 12,
  });

  final Restaurant restaurant;
  final bool isFavorite;
  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context, listen: false);
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius),
                color: AppColors.surfaceLow,
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  AppImage(restaurant.cover, fit: BoxFit.cover),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black54,
                          Colors.transparent,
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (restaurant.badge != null)
            Positioned(
              top: 6,
              right: 6,
              child: _CardBadge(
                label: restaurant.badge!,
                tone: restaurant.badgeTone,
              ),
            ),
          Positioned(
            left: 6,
            bottom: 6,
            child: Material(
              color: Colors.white.withValues(alpha: 0.85),
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => state.toggleFavorite(restaurant.id),
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: Icon(
                    isFavorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    size: 16,
                    color: isFavorite
                        ? AppColors.primary
                        : AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardBadge extends StatelessWidget {
  const _CardBadge({required this.label, required this.tone});

  final String label;
  final BadgeTone tone;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (tone) {
      BadgeTone.orange => (AppColors.primary, Colors.white),
      BadgeTone.green => (AppColors.green, Colors.white),
      BadgeTone.outline => (Colors.white, AppColors.primary),
      BadgeTone.white => (Colors.white, AppColors.textPrimary),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: foreground,
          fontWeight: FontWeight.w700,
          fontSize: 10,
          height: 1.2,
        ),
      ),
    );
  }
}

class _RatingChip extends StatelessWidget {
  const _RatingChip({required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.surfaceLow,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.surfaceContainer),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 14, color: AppColors.amber),
          const SizedBox(width: 2),
          Text(
            rating.toStringAsFixed(1),
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _DeliveryMeta extends StatelessWidget {
  const _DeliveryMeta({required this.restaurant});

  final Restaurant restaurant;

  @override
  Widget build(BuildContext context) {
    Widget delivery;
    if (restaurant.deliveryFee == 0) {
      delivery = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.moped_rounded, size: 14, color: AppColors.green),
          const SizedBox(width: 3),
          Text(
            'توصيل مجاني',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.green,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      );
    } else if (restaurant.freeDeliveryAbove != null) {
      delivery = Text(
        'مجاني فوق ${restaurant.freeDeliveryAbove!.toStringAsFixed(0)} ر.س',
        style: AppTextStyles.caption.copyWith(
          color: AppColors.green,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      );
    } else {
      delivery = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.moped_rounded,
            size: 14,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 3),
          Text(
            'توصيل: ${restaurant.deliveryFee.toStringAsFixed(0)} ر.س',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        const Icon(
          Icons.schedule_rounded,
          size: 14,
          color: AppColors.primary,
        ),
        const SizedBox(width: 3),
        Text(
          '${restaurant.deliveryMin} - ${restaurant.deliveryMax} دقيقة',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
        const SizedBox(width: 6),
        Container(
          width: 3,
          height: 3,
          decoration: const BoxDecoration(
            color: AppColors.textTertiary,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Flexible(child: delivery),
      ],
    );
  }
}

class _BoxedFooter extends StatelessWidget {
  const _BoxedFooter({
    required this.icon,
    required this.color,
    required this.text,
  });

  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    final parts = text.split(':');
    final lead = parts.length > 1 ? '${parts.first}:' : '';
    final highlight = parts.length > 1 ? parts.sublist(1).join(':').trim() : text;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surfaceLow.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.surfaceLow),
      ),
      child: Row(
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 4),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: lead,
                    style: AppTextStyles.caption.copyWith(fontSize: 11),
                  ),
                  TextSpan(
                    text: highlight,
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'طلب',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
              const Icon(Icons.chevron_right, size: 14, color: AppColors.primary),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Restaurant cards — compact grid layout.
// ---------------------------------------------------------------------------

class _RestaurantGrid extends StatelessWidget {
  const _RestaurantGrid({required this.restaurants, required this.onOpen});

  final List<Restaurant> restaurants;
  final ValueChanged<Restaurant> onOpen;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < restaurants.length; i += 2) {
      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _RestaurantGridCard(
                  restaurant: restaurants[i],
                  onTap: () => onOpen(restaurants[i]),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: i + 1 < restaurants.length
                    ? _RestaurantGridCard(
                        restaurant: restaurants[i + 1],
                        onTap: () => onOpen(restaurants[i + 1]),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(children: rows),
    );
  }
}

class _RestaurantGridCard extends StatelessWidget {
  const _RestaurantGridCard({required this.restaurant, required this.onTap});

  final Restaurant restaurant;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final isFavorite = state.isFavorite(restaurant.id);
    final latin = latinBrandNames[restaurant.id];
    final displayName = latin == null
        ? restaurant.name
        : '${restaurant.name} ($latin)';

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.surfaceHigh.withValues(alpha: 0.6),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 118,
                width: double.infinity,
                child: _RestaurantThumb(
                  restaurant: restaurant,
                  isFavorite: isFavorite,
                  width: double.infinity,
                  height: 118,
                  radius: 15,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.label.copyWith(fontSize: 13),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      restaurant.cuisine,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption.copyWith(fontSize: 10.5),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 13,
                          color: AppColors.amber,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          restaurant.rating.toStringAsFixed(1),
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.schedule_rounded,
                          size: 12,
                          color: restaurant.deliveryFee == 0
                              ? AppColors.green
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          restaurant.deliveryFee == 0
                              ? 'توصيل مجاني'
                              : '${restaurant.deliveryMin}-${restaurant.deliveryMax} د',
                          style: AppTextStyles.caption.copyWith(
                            color: restaurant.deliveryFee == 0
                                ? AppColors.green
                                : AppColors.textSecondary,
                            fontSize: 10.5,
                            fontWeight: restaurant.deliveryFee == 0
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Floating dark pill — "عرض على الخريطة" / "تصفية" (design 0).
// ---------------------------------------------------------------------------

class _FloatingFilterPill extends StatelessWidget {
  const _FloatingFilterPill({required this.onMapTap, required this.onFilterTap});

  final VoidCallback onMapTap;
  final VoidCallback onFilterTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        boxShadow: AppColors.pillGlow,
        borderRadius: BorderRadius.all(Radius.circular(999)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.charcoal.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.map_rounded,
                  size: 20,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'عرض على الخريطة',
                  style: AppTextStyles.label.copyWith(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 1,
                  height: 16,
                  color: Colors.white.withValues(alpha: 0.2),
                ),
                const SizedBox(width: 12),
                InkWell(
                  onTap: onFilterTap,
                  borderRadius: BorderRadius.circular(999),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.filter_list_rounded,
                        size: 18,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'تصفية',
                        style: AppTextStyles.label.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
