import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/app_sheets.dart';
import '../widgets/ui.dart';
import 'restaurant_screen.dart';

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

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  List<Restaurant> get _filteredRestaurants {
    var list = restaurants;
    if (_selectedCategory != null) {
      list = list
          .where((restaurant) => restaurant.tags.contains(_selectedCategory))
          .toList();
    }
    if (_query.trim().isNotEmpty) {
      final query = _query.trim();
      list = list.where((restaurant) {
        return restaurant.name.contains(query) ||
            restaurant.cuisine.contains(query) ||
            restaurant.menu.any((item) => item.name.contains(query));
      }).toList();
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

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    FadeSlideIn(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 22),
                        child: Row(
                          children: [
                            const BrandMark(size: 22),
                            const Spacer(),
                            SoftIconButton(
                              icon: Icons.notifications_none_rounded,
                              size: 42,
                              iconSize: 20,
                              onTap: () => _showNotifications(context),
                              tooltip: 'الإشعارات',
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 50),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 22),
                        child: Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () => showAddressPicker(context),
                                borderRadius: BorderRadius.circular(16),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 2,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'مساء الخير، ${appUser.name.split(' ').first}',
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: AppColors.textTertiary,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.location_on_rounded,
                                            size: 18,
                                            color: AppColors.primary,
                                          ),
                                          const SizedBox(width: 5),
                                          Flexible(
                                            child: Text(
                                              state.address,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: AppTextStyles.titleSmall
                                                  .copyWith(fontSize: 14.5),
                                            ),
                                          ),
                                          const SizedBox(width: 3),
                                          const Icon(
                                            Icons.keyboard_arrow_down_rounded,
                                            size: 19,
                                            color: AppColors.textSecondary,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.primary,
                                  width: 1.5,
                                ),
                              ),
                              child: ClipOval(
                                child: AppImage(
                                  appUser.avatar,
                                  width: 46,
                                  height: 46,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 90),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 22),
                        child: _SearchBar(
                          controller: _searchController,
                          focusNode: _searchFocus,
                          onChanged: (value) => setState(() => _query = value),
                          onFilter: () => showSearchOverlay(context),
                          onClear: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    if (_query.trim().isEmpty) ...[
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 130),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 22),
                          child: _HeroBanner(
                            onTap: () => _openRestaurant(restaurants.first),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 22),
                        child: SectionHeader(
                          title: 'ماذا تشتهي اليوم؟',
                          subtitle: 'اختر مزاجك، ونحن نتولى الباقي',
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        height: 94,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 22),
                          itemCount: foodCategories.length + 1,
                          separatorBuilder: (context, index) =>
                              const SizedBox(width: 15),
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return _AllCategoryItem(
                                selected: _selectedCategory == null,
                                onTap: () =>
                                    setState(() => _selectedCategory = null),
                              );
                            }
                            final category = foodCategories[index - 1];
                            return _CategoryItem(
                              category: category,
                              selected: _selectedCategory == category.id,
                              onTap: () {
                                setState(() {
                                  _selectedCategory =
                                      _selectedCategory == category.id
                                      ? null
                                      : category.id;
                                });
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 22),
                        child: SectionHeader(
                          title: 'مطاعم مميزة',
                          subtitle: _selectedCategory == null
                              ? 'اختيارات لُقمة لهذا اليوم'
                              : 'أفضل ما اخترناه لمزاجك',
                          actionLabel: 'عرض الكل',
                          onAction: () => showSearchOverlay(context),
                        ),
                      ),
                      const SizedBox(height: 14),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 360),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        child: _filteredRestaurants.isEmpty
                            ? _EmptyCategory(
                                key: ValueKey(_selectedCategory),
                                onReset: () =>
                                    setState(() => _selectedCategory = null),
                              )
                            : SizedBox(
                                key: ValueKey(_selectedCategory),
                                height: 282,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 22,
                                  ),
                                  itemCount: _filteredRestaurants.length,
                                  separatorBuilder: (context, index) =>
                                      const SizedBox(width: 14),
                                  itemBuilder: (context, index) {
                                    final restaurant =
                                        _filteredRestaurants[index];
                                    return _RestaurantCard(
                                      restaurant: restaurant,
                                      isFavorite: state.isFavorite(
                                        restaurant.id,
                                      ),
                                      onTap: () => _openRestaurant(restaurant),
                                      onFavorite: () =>
                                          state.toggleFavorite(restaurant.id),
                                    );
                                  },
                                ),
                              ),
                      ),
                      const SizedBox(height: 28),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 22),
                        child: SectionHeader(
                          title: 'مقترحة لك',
                          subtitle: 'مختارة من مطاعم قريبة وتقييمات عالية',
                          actionLabel: 'اكتشف',
                          onAction: () => showSearchOverlay(context),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 22),
                        child: Column(
                          children: [
                            for (final restaurant
                                in restaurants.skip(2).take(3))
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _RecommendedCard(
                                  restaurant: restaurant,
                                  onTap: () => _openRestaurant(restaurant),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 22),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.primarySoft,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: const BoxDecoration(
                                  color: AppColors.surface,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.eco_outlined,
                                  color: AppColors.primaryDark,
                                  size: 23,
                                ),
                              ),
                              const SizedBox(width: 13),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'طلباتك أكثر استدامة',
                                      style: AppTextStyles.titleSmall,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'تغليف صديق للبيئة مع كل طلب من لُقمة',
                                      style: AppTextStyles.caption,
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_back_rounded,
                                color: AppColors.primaryDark,
                                size: 19,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 2),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 22),
                        child: Row(
                          children: [
                            Text('نتائج البحث', style: AppTextStyles.headline),
                            const SizedBox(width: 8),
                            Text(
                              '${_filteredRestaurants.length}',
                              style: AppTextStyles.caption,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      if (_filteredRestaurants.isEmpty)
                        _EmptyCategory(
                          onReset: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 22),
                          child: Column(
                            children: [
                              for (final restaurant in _filteredRestaurants)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: _RecommendedCard(
                                    restaurant: restaurant,
                                    onTap: () => _openRestaurant(restaurant),
                                  ),
                                ),
                            ],
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),
            AppBottomNav(currentIndex: 0, onTap: _handleNavTap),
          ],
        ),
      ),
    );
  }

  void _showNotifications(BuildContext context) {
    showAppSheet(
      context: context,
      heightFactor: 0.52,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          const Center(child: SheetHandle()),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Row(
              children: [
                Expanded(
                  child: Text('الإشعارات', style: AppTextStyles.headline),
                ),
                SoftIconButton(
                  icon: Icons.close_rounded,
                  size: 38,
                  iconSize: 18,
                  shadow: false,
                  background: AppColors.inkSoft,
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              children: [
                _NotificationTile(
                  icon: Icons.local_offer_rounded,
                  title: 'عرض خاص لك',
                  body: 'خصم ٢٠٪ على طلبك القادم من برجر لاب.',
                  time: 'الآن',
                  accent: true,
                ),
                const SizedBox(height: 9),
                _NotificationTile(
                  icon: Icons.delivery_dining_rounded,
                  title: 'توصيل سريع',
                  body: 'مطاعم جديدة وصلت إلى حيّك هذا الأسبوع.',
                  time: 'قبل ساعة',
                ),
                const SizedBox(height: 9),
                _NotificationTile(
                  icon: Icons.star_rounded,
                  title: 'قيّم تجربتك',
                  body: 'كيف كانت وجبتك الأخيرة من نوليتا بيتزا؟',
                  time: 'أمس',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onFilter,
    required this.onClear,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onFilter;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          const Icon(
            Icons.search_rounded,
            color: AppColors.textSecondary,
            size: 21,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              style: AppTextStyles.titleSmall.copyWith(fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'مطاعم، أطباق، بقالة...',
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            IconButton(
              onPressed: onClear,
              icon: const Icon(
                Icons.close_rounded,
                size: 17,
                color: AppColors.textTertiary,
              ),
            ),
          Container(width: 1, height: 22, color: AppColors.border),
          const SizedBox(width: 6),
          Padding(
            padding: const EdgeInsets.all(6),
            child: Material(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: onFilter,
                borderRadius: BorderRadius.circular(12),
                child: const SizedBox(
                  width: 38,
                  height: 38,
                  child: Icon(
                    Icons.tune_rounded,
                    color: Colors.white,
                    size: 18,
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

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 196,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.14),
              blurRadius: 26,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: Stack(
            fit: StackFit.expand,
            children: [
              AppImage(
                'assets/images/burger2.jpg',
                fit: BoxFit.cover,
                alignment: Alignment.centerLeft,
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                    stops: [0.05, 0.58, 1],
                    colors: [
                      Color(0xF2202020),
                      Color(0xB3202020),
                      Color(0x14202020),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 16,
                right: 18,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.16),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 5,
                            height: 5,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'عرض محدود',
                            style: AppTextStyles.caption.copyWith(
                              color: Colors.white,
                              fontSize: 10.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 52,
                left: 16,
                child: Transform.rotate(
                  angle: -0.08,
                  child: Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.4),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.35),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '٣٠٪',
                          style: AppTextStyles.title.copyWith(
                            color: Colors.white,
                            fontSize: 20,
                            height: 1.2,
                          ),
                        ),
                        Text(
                          'خصم',
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 20,
                bottom: 18,
                child: SizedBox(
                  width: 220,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'جوعك يستاهل',
                        style: AppTextStyles.headline.copyWith(
                          color: Colors.white,
                          fontSize: 24,
                          height: 1.4,
                        ),
                      ),
                      Text(
                        'الأفضل يوصلك قبل ما تشتهيه.',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 11.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'اطلب الآن',
                              style: AppTextStyles.label.copyWith(
                                color: AppColors.charcoal,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 5),
                            const Icon(
                              Icons.arrow_back_rounded,
                              size: 15,
                              color: AppColors.charcoal,
                            ),
                          ],
                        ),
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

class _AllCategoryItem extends StatelessWidget {
  const _AllCategoryItem({required this.selected, required this.onTap});

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 68,
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 240),
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: selected ? AppColors.charcoal : AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? AppColors.charcoal : AppColors.border,
                  width: 1.5,
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: AppColors.charcoal.withValues(alpha: 0.18),
                          blurRadius: 16,
                          offset: const Offset(0, 7),
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                selected ? Icons.grid_view_rounded : Icons.grid_view_outlined,
                size: 24,
                color: selected ? Colors.white : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              'الكل',
              style: AppTextStyles.caption.copyWith(
                color: selected ? AppColors.charcoal : AppColors.textSecondary,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  const _CategoryItem({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final FoodCategory category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 68,
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 240),
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? AppColors.primary : Colors.transparent,
                  width: 2,
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.18),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : null,
              ),
              child: Stack(
                children: [
                  ClipOval(
                    child: AppImage(category.image, width: 58, height: 58),
                  ),
                  if (selected)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 11,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              category.label,
              style: AppTextStyles.caption.copyWith(
                color: selected
                    ? AppColors.primaryDark
                    : AppColors.textSecondary,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RestaurantCard extends StatelessWidget {
  const _RestaurantCard({
    required this.restaurant,
    required this.isFavorite,
    required this.onTap,
    required this.onFavorite,
  });

  final Restaurant restaurant;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 286,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AppImage(
                  restaurant.cover,
                  width: double.infinity,
                  height: 145,
                  radius: 23,
                ),
                const Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 80,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(23),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Color(0x66202020), Colors.transparent],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: PromoBadge(label: restaurant.badge ?? 'مميز'),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: SoftIconButton(
                    icon: isFavorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: isFavorite
                        ? AppColors.danger
                        : AppColors.textPrimary,
                    size: 34,
                    iconSize: 17,
                    shadow: false,
                    background: Colors.white.withValues(alpha: 0.94),
                    onTap: onFavorite,
                  ),
                ),
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: AppImage(restaurant.logo, width: 38, height: 38),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          restaurant.name,
                          style: AppTextStyles.title.copyWith(fontSize: 17),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      RatingPill(
                        rating: restaurant.rating,
                        reviews: restaurant.reviewCount,
                        compact: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${restaurant.cuisine}  ·  ${restaurant.priceLevel}',
                    style: AppTextStyles.bodySmall.copyWith(fontSize: 12),
                  ),
                  const SizedBox(height: 11),
                  Row(
                    children: [
                      Flexible(
                        flex: 3,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.schedule_rounded,
                              size: 15,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                restaurant.deliveryTime,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const InfoDot(),
                      const SizedBox(width: 8),
                      Flexible(
                        flex: 4,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.delivery_dining_rounded,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                restaurant.deliveryFee == 0
                                    ? 'توصيل مجاني'
                                    : money(restaurant.deliveryFee),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.caption.copyWith(
                                  color: restaurant.deliveryFee == 0
                                      ? AppColors.primaryDark
                                      : AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
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
          ],
        ),
      ),
    );
  }
}

class _RecommendedCard extends StatelessWidget {
  const _RecommendedCard({required this.restaurant, required this.onTap});

  final Restaurant restaurant;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          restaurant.name,
                          style: AppTextStyles.titleSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (restaurant.badge != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primarySoft,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            restaurant.badge!,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.primaryDark,
                              fontSize: 8.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${restaurant.cuisine} · ${restaurant.distanceKm} كم',
                    style: AppTextStyles.caption,
                  ),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: AppColors.amber,
                        size: 14,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        restaurant.rating.toStringAsFixed(1),
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 9),
                      const Icon(
                        Icons.schedule_rounded,
                        size: 13,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        restaurant.deliveryTime,
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            AppImage(restaurant.cover, width: 94, height: 94, radius: 16),
          ],
        ),
      ),
    );
  }
}

class _EmptyCategory extends StatelessWidget {
  const _EmptyCategory({super.key, required this.onReset});

  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 22),
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: const BoxDecoration(
              color: AppColors.primarySoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.restaurant_menu_rounded,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 12),
          Text('لا توجد نتائج هنا', style: AppTextStyles.titleSmall),
          const SizedBox(height: 4),
          Text(
            'جرّب البحث عن مطعم أو تصنيف آخر',
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: 12),
          TextButton(onPressed: onReset, child: const Text('عرض كل المطاعم')),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.icon,
    required this.title,
    required this.body,
    required this.time,
    this.accent = false,
  });

  final IconData icon;
  final String title;
  final String body;
  final String time;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: accent ? AppColors.primarySoft : AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: accent
              ? AppColors.primary.withValues(alpha: 0.2)
              : AppColors.border,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: accent ? AppColors.primary : AppColors.inkSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 18,
              color: accent ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(title, style: AppTextStyles.titleSmall),
                    ),
                    Text(time, style: AppTextStyles.caption),
                  ],
                ),
                const SizedBox(height: 2),
                Text(body, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
