import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/product_sheet.dart';
import '../widgets/ui.dart';
import 'checkout_screen.dart';

class RestaurantScreen extends StatefulWidget {
  const RestaurantScreen({super.key, required this.restaurant});

  final Restaurant restaurant;

  @override
  State<RestaurantScreen> createState() => _RestaurantScreenState();
}

class _RestaurantScreenState extends State<RestaurantScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _menuSearchController = TextEditingController();
  String _selectedCategory = 'popular';
  String _menuQuery = '';
  bool _showPinnedBack = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  void _handleScroll() {
    final shouldShow = _scrollController.offset > 250;
    if (shouldShow != _showPinnedBack) {
      setState(() => _showPinnedBack = shouldShow);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    _menuSearchController.dispose();
    super.dispose();
  }

  List<MenuItem> get _items {
    final base = menuForCategory(widget.restaurant, _selectedCategory);
    if (_menuQuery.trim().isEmpty) return base;
    final query = _menuQuery.trim();
    return base.where((item) {
      return item.name.contains(query) || item.description.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final restaurant = widget.restaurant;
    final cartCount = state.cartCount;
    final showCart = state.cart.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: _buildCover(context, restaurant, state),
              ),
              SliverToBoxAdapter(
                child: Transform.translate(
                  offset: const Offset(0, -22),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildInfoCard(context, restaurant),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Transform.translate(
                  offset: const Offset(0, -10),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 0, 22, 18),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.primarySoft,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.local_offer_outlined,
                            size: 17,
                            color: AppColors.primaryDark,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'خصم ٢٠٪ على أول طلب',
                                style: AppTextStyles.label.copyWith(
                                  color: AppColors.primaryDark,
                                  fontSize: 12.5,
                                ),
                              ),
                              Text(
                                'استخدم كود LUQMA20 عند الدفع',
                                style: AppTextStyles.caption.copyWith(
                                  fontSize: 10.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_left_rounded,
                          size: 19,
                          color: AppColors.primaryDark,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 0, 22, 10),
                  child: Row(
                    children: [
                      Text('قائمة الطعام', style: AppTextStyles.headline),
                      const Spacer(),
                      Text(
                        '${restaurant.menu.length} أطباق',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _MenuHeaderDelegate(
                  height: 112,
                  child: Container(
                    color: AppColors.background,
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            if (_showPinnedBack) ...[
                              SoftIconButton(
                                icon: Icons.arrow_forward_rounded,
                                onTap: () => Navigator.pop(context),
                                size: 40,
                                tooltip: 'رجوع',
                              ),
                              const SizedBox(width: 8),
                            ],
                            Expanded(child: _buildMenuSearch()),
                          ],
                        ),
                        const SizedBox(height: 9),
                        SizedBox(
                          height: 38,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: restaurant.menuCategories.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(width: 7),
                            itemBuilder: (context, index) {
                              final category = restaurant.menuCategories[index];
                              final selected = _selectedCategory == category.id;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedCategory = category.id;
                                    _menuQuery = '';
                                    _menuSearchController.clear();
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 220),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 15,
                                  ),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? AppColors.primary
                                        : AppColors.surface,
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                      color: selected
                                          ? AppColors.primary
                                          : AppColors.border,
                                    ),
                                    boxShadow: selected
                                        ? [
                                            BoxShadow(
                                              color: AppColors.primary
                                                  .withValues(alpha: 0.18),
                                              blurRadius: 12,
                                              offset: const Offset(0, 5),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Text(
                                    category.label,
                                    style: AppTextStyles.caption.copyWith(
                                      color: selected
                                          ? Colors.white
                                          : AppColors.textSecondary,
                                      fontWeight: selected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (_items.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      children: [
                        Container(
                          width: 66,
                          height: 66,
                          decoration: const BoxDecoration(
                            color: AppColors.primarySoft,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.search_off_rounded,
                            color: AppColors.primaryDark,
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text('لم نجد هذا الطبق', style: AppTextStyles.title),
                        const SizedBox(height: 5),
                        Text(
                          'جرّب البحث باسم آخر أو اختر تصنيفاً مختلفاً',
                          style: AppTextStyles.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () {
                            _menuSearchController.clear();
                            setState(() => _menuQuery = '');
                          },
                          child: const Text('مسح البحث'),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                  sliver: SliverList.separated(
                    itemCount: _items.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      return FadeSlideIn(
                        key: ValueKey(
                          '${_selectedCategory}_${_menuQuery}_${item.id}',
                        ),
                        delay: Duration(milliseconds: 35 * index),
                        offset: 12,
                        duration: const Duration(milliseconds: 420),
                        child: _ProductCard(
                          item: item,
                          onTap: () => showProductSheet(
                            context: context,
                            restaurant: restaurant,
                            item: item,
                          ),
                          onAdd: () => showProductSheet(
                            context: context,
                            restaurant: restaurant,
                            item: item,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              SliverToBoxAdapter(child: SizedBox(height: showCart ? 135 : 42)),
            ],
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 380),
                curve: Curves.easeOutCubic,
                offset: showCart ? Offset.zero : const Offset(0, 0.5),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 260),
                  opacity: showCart ? 1 : 0,
                  child: IgnorePointer(
                    ignoring: !showCart,
                    child: _CartBar(
                      count: cartCount,
                      total: state.total,
                      onTap: () {
                        Navigator.of(context)
                            .push(premiumRoute(const CheckoutScreen()));
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCover(
    BuildContext context,
    Restaurant restaurant,
    AppState state,
  ) {
    return SizedBox(
      height: 338,
      child: Stack(
        fit: StackFit.expand,
        children: [
          AppImage(restaurant.cover, fit: BoxFit.cover),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0, 0.42, 1],
                colors: [
                  Color(0x8A202020),
                  Color(0x00202020),
                  Color(0xE8202020),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                child: Row(
                  children: [
                    SoftIconButton(
                      icon: Icons.arrow_forward_rounded,
                      onTap: () => Navigator.pop(context),
                      background: Colors.white.withValues(alpha: 0.94),
                      size: 44,
                      tooltip: 'رجوع',
                    ),
                    const Spacer(),
                    SoftIconButton(
                      icon: state.isFavorite(restaurant.id)
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: state.isFavorite(restaurant.id)
                          ? AppColors.danger
                          : AppColors.textPrimary,
                      onTap: () => state.toggleFavorite(restaurant.id),
                      background: Colors.white.withValues(alpha: 0.94),
                      size: 44,
                      tooltip: 'المفضلة',
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: 20,
            left: 20,
            bottom: 42,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2.5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(19),
                      ),
                      child: AppImage(
                        restaurant.logo,
                        width: 56,
                        height: 56,
                        radius: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            restaurant.name,
                            style: AppTextStyles.display.copyWith(
                              fontSize: 26,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${restaurant.cuisine}  ·  ${restaurant.priceLevel}  ·  ${restaurant.distanceKm} كم',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.white.withValues(alpha: 0.72),
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 13),
                Row(
                  children: [
                    RatingPill(
                      rating: restaurant.rating,
                      reviews: restaurant.reviewCount,
                      onDark: true,
                    ),
                    const SizedBox(width: 7),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.bolt_rounded,
                            size: 13,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            'مفتوح الآن',
                            style: AppTextStyles.caption.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 10.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 7),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.18),
                        ),
                      ),
                      child: Text(
                        restaurant.badge ?? 'مميز',
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.white,
                          fontSize: 10.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, Restaurant restaurant) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 17),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Stat(
                icon: Icons.star_rounded,
                iconColor: AppColors.amber,
                value: restaurant.rating.toStringAsFixed(1),
                label: '${restaurant.reviewCount}+ تقييم',
              ),
              const _VerticalDivider(),
              _Stat(
                icon: Icons.schedule_rounded,
                value: restaurant.deliveryTime,
                label: 'وقت التوصيل',
              ),
              const _VerticalDivider(),
              _Stat(
                icon: Icons.delivery_dining_rounded,
                value: restaurant.deliveryFee == 0
                    ? 'مجاني'
                    : money(restaurant.deliveryFee),
                label: 'رسوم التوصيل',
              ),
            ],
          ),
          const SizedBox(height: 15),
          const DividerLine(),
          const SizedBox(height: 13),
          Text(
            restaurant.description,
            style: AppTextStyles.bodySmall.copyWith(height: 1.7),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 15,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                '${restaurant.distanceKm} كم منك',
                style: AppTextStyles.caption,
              ),
              const SizedBox(width: 10),
              const InfoDot(),
              const SizedBox(width: 10),
              const Icon(
                Icons.schedule_rounded,
                size: 14,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text('يغلق ٢:٠٠ ص', style: AppTextStyles.caption),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSearch() {
    return Container(
      height: 47,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const SizedBox(width: 13),
          const Icon(
            Icons.search_rounded,
            size: 19,
            color: AppColors.textTertiary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _menuSearchController,
              onChanged: (value) => setState(() => _menuQuery = value),
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textPrimary,
              ),
              decoration: const InputDecoration(
                hintText: 'ابحث داخل القائمة...',
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (_menuQuery.isNotEmpty)
            IconButton(
              onPressed: () {
                _menuSearchController.clear();
                setState(() => _menuQuery = '');
              },
              icon: const Icon(
                Icons.close_rounded,
                size: 17,
                color: AppColors.textTertiary,
              ),
            ),
        ],
      ),
    );
  }
}

class _MenuHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _MenuHeaderDelegate({required this.height, required this.child});

  final double height;
  final Widget child;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ColoredBox(color: AppColors.background, child: child);
  }

  @override
  bool shouldRebuild(covariant _MenuHeaderDelegate oldDelegate) => true;
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.item,
    required this.onTap,
    required this.onAdd,
  });

  final MenuItem item;
  final VoidCallback onTap;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(21),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 116,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (item.badge != null)
                          Container(
                            margin: const EdgeInsets.only(left: 6),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primarySoft,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item.badge!,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.primaryDark,
                                fontSize: 8.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        if (item.popular)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.inkSoft,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.local_fire_department_rounded,
                                  size: 10,
                                  color: AppColors.amber,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  'شائع',
                                  style: AppTextStyles.caption.copyWith(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      item.name,
                      style: AppTextStyles.titleSmall.copyWith(fontSize: 14.5),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.description,
                      style: AppTextStyles.caption.copyWith(height: 1.5),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Text(
                          money(item.price),
                          style: AppTextStyles.price.copyWith(fontSize: 14.5),
                        ),
                        if (item.oldPrice != null) ...[
                          const SizedBox(width: 6),
                          Text(
                            money(item.oldPrice!),
                            style: AppTextStyles.caption.copyWith(
                              decoration: TextDecoration.lineThrough,
                              color: AppColors.textTertiary,
                              fontSize: 10,
                            ),
                          ),
                        ],
                        const Spacer(),
                        Material(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(11),
                          child: InkWell(
                            onTap: onAdd,
                            borderRadius: BorderRadius.circular(11),
                            child: const SizedBox(
                              width: 34,
                              height: 34,
                              child: Icon(
                                Icons.add_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 11),
            Stack(
              children: [
                AppImage(item.image, width: 122, height: 122, radius: 18),
                const Positioned(left: 8, bottom: 8, child: SizedBox.shrink()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.icon,
    required this.value,
    required this.label,
    this.iconColor = AppColors.textPrimary,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 15, color: iconColor),
              const SizedBox(width: 3),
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.label.copyWith(fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              fontSize: 9.5,
              color: AppColors.textTertiary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 30, color: AppColors.border);
  }
}

class _CartBar extends StatelessWidget {
  const _CartBar({
    required this.count,
    required this.total,
    required this.onTap,
  });

  final int count;
  final double total;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      decoration: BoxDecoration(
        color: AppColors.charcoal,
        borderRadius: BorderRadius.circular(23),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$count',
                    style: AppTextStyles.title.copyWith(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'عرض السلة',
                      style: AppTextStyles.titleSmall.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      '$count أصناف · ${money(total)}',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 39,
                height: 39,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                  size: 19,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
