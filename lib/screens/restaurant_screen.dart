import 'dart:ui' as ui;

import 'package:flutter/material.dart';

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
  late String _selectedCategory;

  Restaurant get restaurant => widget.restaurant;

  @override
  void initState() {
    super.initState();
    _selectedCategory = restaurant.menuCategories.first.id;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<MenuItem> get _visibleItems {
    if (_selectedCategory == 'popular') {
      final popular = restaurant.menu.where((item) => item.popular).toList();
      return popular.isEmpty ? restaurant.menu.take(4).toList() : popular;
    }
    return restaurant.menu
        .where((item) => item.category == _selectedCategory)
        .toList();
  }

  String get _selectedCategoryLabel {
    return restaurant.menuCategories
        .firstWhere((category) => category.id == _selectedCategory)
        .label;
  }

  Map<String, List<MenuOption>> _defaultSelections(MenuItem item) {
    final result = <String, List<MenuOption>>{};
    for (final group in item.optionGroups) {
      final defaults = group.options.where((o) => o.isDefault).toList();
      if (defaults.isNotEmpty) {
        result[group.id] = defaults;
      } else if (group.required && group.options.isNotEmpty) {
        result[group.id] = [group.options.first];
      }
    }
    return result;
  }

  void _openItem(MenuItem item) {
    showProductSheet(context: context, restaurant: restaurant, item: item);
  }

  void _quickAdd(MenuItem item) {
    final state = AppScope.of(context, listen: false);
    state.addToCart(
      restaurant: restaurant,
      item: item,
      selections: _defaultSelections(item),
      quantity: 1,
    );
    showAppSnackBar(context, 'أُضيف ${item.name} إلى السلة');
  }

  void _quickRemove(MenuItem item) {
    final state = AppScope.of(context, listen: false);
    final line = state.cart
        .lastWhereOrNull((line) => line.item.id == item.id);
    if (line != null) {
      state.updateQuantity(line.lineId, line.quantity - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final isFavorite = state.isFavorite(restaurant.id);
    final itemCount = state.cartCount;
    final items = _visibleItems;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Hero photo with the meta card riding 32px over its bottom.
              SliverToBoxAdapter(
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 256),
                      child: _MetaCard(restaurant: restaurant),
                    ),
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: 288,
                      child: _HeroVisual(restaurant: restaurant),
                    ),
                    if (restaurant.partner)
                      Positioned(
                        top: 84,
                        left: 0,
                        right: 0,
                        child: Center(child: _PartnerBadge()),
                      ),
                  ],
                ),
              ),
              // Sticky category chips.
              SliverPersistentHeader(
                pinned: true,
                delegate: _CategoryChipsDelegate(
                  categories: restaurant.menuCategories,
                  selectedId: _selectedCategory,
                  onTap: (id) => setState(() => _selectedCategory = id),
                ),
              ),
              // Section title + menu items + safety note.
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 160),
                sliver: SliverMainAxisGroup(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Row(
                        children: [
                          Text(
                            _selectedCategoryLabel,
                            style: AppTextStyles.title,
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${items.length} أصناف شهية',
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 12)),
                    if (items.isEmpty)
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Center(
                            child: Text(
                              'لا توجد أصناف في هذا القسم',
                              style: AppTextStyles.bodySmall,
                            ),
                          ),
                        ),
                      )
                    else
                      SliverList.separated(
                        itemCount: items.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return _MenuItemRow(
                            item: item,
                            onTap: () => _openItem(item),
                            onAdd: () => _quickAdd(item),
                            onRemove: () => _quickRemove(item),
                            inCartCount: state.cart
                                .where((line) => line.item.id == item.id)
                                .fold(0, (sum, line) => sum + line.quantity),
                          );
                        },
                      ),
                    const SliverToBoxAdapter(child: SizedBox(height: 20)),
                    const SliverToBoxAdapter(child: _SafetyNote()),
                  ],
                ),
              ),
            ],
          ),
          // Floating header actions (always above the scroll content).
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    _HeroCircleButton(
                      icon: Icons.arrow_back,
                      iconSize: 22,
                      tooltip: 'رجوع',
                      onTap: () => Navigator.maybePop(context),
                    ),
                    const Spacer(),
                    _HeroCircleButton(
                      icon: Icons.share_rounded,
                      iconSize: 20,
                      tooltip: 'مشاركة',
                      onTap: () => showAppSnackBar(
                        context,
                        'تم نسخ رابط المطعم للمشاركة',
                        icon: Icons.share_rounded,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _HeroCircleButton(
                      icon: isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      iconSize: 20,
                      iconColor: isFavorite ? AppColors.primary : Colors.white,
                      tooltip: 'حفظ في المفضلة',
                      onTap: () => state.toggleFavorite(restaurant.id),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Sticky cart tray.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _CartTray(
              itemCount: itemCount,
              total: state.subtotal,
              onCheckout: itemCount == 0
                  ? null
                  : () => Navigator.of(
                      context,
                    ).push(premiumRoute(const CheckoutScreen())),
            ),
          ),
        ],
      ),
    );
  }
}

extension<T> on Iterable<T> {
  T? lastWhereOrNull(bool Function(T) test) {
    T? result;
    for (final element in this) {
      if (test(element)) result = element;
    }
    return result;
  }
}

// ---------------------------------------------------------------------------
// Hero visual — full-bleed cover photo with gradient scrim (design 1).
// ---------------------------------------------------------------------------

class _HeroVisual extends StatelessWidget {
  const _HeroVisual({required this.restaurant});

  final Restaurant restaurant;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        AppImage(restaurant.cover, fit: BoxFit.cover),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Colors.white,
                Colors.black26,
                Colors.black54,
              ],
              stops: [0, 0.35, 1],
            ),
          ),
        ),
      ],
    );
  }
}

class _PartnerBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.verified_rounded,
            size: 16,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            'شريك مميز يلا',
            style: AppTextStyles.caption.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroCircleButton extends StatelessWidget {
  const _HeroCircleButton({
    required this.icon,
    required this.onTap,
    this.iconSize = 20,
    this.iconColor = Colors.white,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onTap;
  final double iconSize;
  final Color iconColor;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final button = DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Material(
            color: Colors.black.withValues(alpha: 0.3),
            shape: const CircleBorder(
              side: BorderSide(color: Colors.black26),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: SizedBox(
                width: 40,
                height: 40,
                child: Icon(icon, size: iconSize, color: iconColor),
              ),
            ),
          ),
        ),
      ),
    );
    if (tooltip == null) return button;
    return Tooltip(message: tooltip!, child: button);
  }
}

// ---------------------------------------------------------------------------
// Restaurant meta card riding over the hero (design 1).
// ---------------------------------------------------------------------------

class _MetaCard extends StatelessWidget {
  const _MetaCard({required this.restaurant});

  final Restaurant restaurant;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
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
                        restaurant.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.headline.copyWith(fontSize: 21),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        restaurant.subtitle ?? restaurant.cuisine,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.lunch_dining_rounded,
                    size: 28,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Feature pills.
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              clipBehavior: Clip.none,
              child: Row(
                children: [
                  for (final feature in restaurant.features) ...[
                    _FeaturePill(feature: feature),
                    const SizedBox(width: 8),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            _MetricsGrid(restaurant: restaurant),
          ],
        ),
      ),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  const _FeaturePill({required this.feature});

  final String feature;

  @override
  Widget build(BuildContext context) {
    final (icon, label, background, foreground) = switch (feature) {
      'fast' => (
        Icons.bolt_rounded,
        'توصيل سريع جداً',
        AppColors.green.withValues(alpha: 0.15),
        AppColors.green,
      ),
      'card' => (
        Icons.credit_card_rounded,
        'يقبل الدفع الإلكتروني',
        AppColors.surfaceContainer,
        AppColors.textPrimary,
      ),
      _ => (
        Icons.local_offer_rounded,
        'خصومات حصرية يلا',
        AppColors.primarySoft,
        AppColors.primaryDark,
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: foreground),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: foreground,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricsGrid extends StatelessWidget {
  const _MetricsGrid({required this.restaurant});

  final Restaurant restaurant;

  @override
  Widget build(BuildContext context) {
    final feeLabel = restaurant.deliveryFee == 0
        ? 'مجاني'
        : restaurant.deliveryFee.toStringAsFixed(0);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surfaceLow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: _MetricCell(
              value: restaurant.rating.toStringAsFixed(1),
              suffix: Icons.star_rounded,
              suffixColor: AppColors.amber,
              label: '+${_formatCount(restaurant.reviewCount)} تقييم',
            ),
          ),
          Expanded(
            child: _MetricCell(
              value: '${restaurant.deliveryMin}-${restaurant.deliveryMax}',
              label: 'دقيقة',
            ),
          ),
          Expanded(
            child: _MetricCell(
              value: feeLabel,
              suffixText: restaurant.deliveryFee == 0 ? null : 'ر.س',
              label: 'رسوم التوصيل',
            ),
          ),
          Expanded(
            child: _MetricCell(
              value: restaurant.minimumOrder.toStringAsFixed(0),
              suffixText: 'ر.س',
              label: 'الحد الأدنى',
            ),
          ),
        ],
      ),
    );
  }

  static String _formatCount(int count) {
    final digits = count.toString();
    if (digits.length <= 3) return digits;
    return '${digits.substring(0, digits.length - 3)},${digits.substring(digits.length - 3)}';
  }
}

class _MetricCell extends StatelessWidget {
  const _MetricCell({
    required this.value,
    required this.label,
    this.suffix,
    this.suffixText,
    this.suffixColor = AppColors.textPrimary,
  });

  final String value;
  final String label;
  final IconData? suffix;
  final String? suffixText;
  final Color suffixColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(value, style: AppTextStyles.titleSmall.copyWith(fontSize: 15)),
            if (suffixText != null) ...[
              const SizedBox(width: 2),
              Text(
                suffixText!,
                style: AppTextStyles.caption.copyWith(fontSize: 10),
              ),
            ],
            if (suffix != null) ...[
              const SizedBox(width: 2),
              Icon(suffix, size: 15, color: suffixColor),
            ],
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.caption.copyWith(fontSize: 10),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Sticky category chips (design 1).
// ---------------------------------------------------------------------------

class _CategoryChipsDelegate extends SliverPersistentHeaderDelegate {
  _CategoryChipsDelegate({
    required this.categories,
    required this.selectedId,
    required this.onTap,
  });

  final List<MenuCategory> categories;
  final String selectedId;
  final ValueChanged<String> onTap;

  static const _height = 56.0;

  @override
  double get minExtent => _height;

  @override
  double get maxExtent => _height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ClipRect(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          color: Colors.white.withValues(alpha: 0.92),
          padding: const EdgeInsets.only(top: 10, bottom: 6),
          child: SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                for (final category in categories) ...[
                  _CategoryChip(
                    label: category.id == 'popular'
                        ? '${category.label} 🔥'
                        : category.label,
                    selected: category.id == selectedId,
                    onTap: () => onTap(category.id),
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _CategoryChipsDelegate oldDelegate) {
    return selectedId != oldDelegate.selectedId ||
        categories != oldDelegate.categories;
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : AppColors.surfaceContainer,
      borderRadius: BorderRadius.circular(999),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: selected ? Colors.white : AppColors.textPrimary,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Menu item rows (design 1).
// ---------------------------------------------------------------------------

class _MenuItemRow extends StatelessWidget {
  const _MenuItemRow({
    required this.item,
    required this.onTap,
    required this.onAdd,
    required this.onRemove,
    required this.inCartCount,
  });

  final MenuItem item;
  final VoidCallback onTap;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final int inCartCount;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.label.copyWith(fontSize: 15),
                          ),
                        ),
                        if (item.spicy)
                          Tooltip(
                            message: 'حار خفيف',
                            child: Icon(
                              Icons.local_fire_department_rounded,
                              size: 16,
                              color: AppColors.amberDeep,
                            ),
                          ),
                      ],
                    ),
                    if (item.badge != null) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
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
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 12,
                        height: 1.55,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              item.price.toStringAsFixed(0),
                              style: AppTextStyles.price.copyWith(fontSize: 18),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              'ر.س',
                              style: AppTextStyles.caption.copyWith(
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        if (item.oldPrice != null) ...[
                          const SizedBox(width: 6),
                          Text(
                            '${item.oldPrice!.toStringAsFixed(0)} ر.س',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textTertiary,
                              decoration: TextDecoration.lineThrough,
                              decorationColor: AppColors.textTertiary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                        const Spacer(),
                        _ItemStepper(
                          value: inCartCount,
                          onAdd: onAdd,
                          onRemove: onRemove,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 96,
                height: 96,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: AppColors.surfaceContainer,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: AppImage(item.image, fit: BoxFit.cover),
                      ),
                    ),
                    if (item.calories != null)
                      Positioned(
                        right: 4,
                        bottom: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${item.calories} سعرة',
                            style: AppTextStyles.caption.copyWith(
                              color: Colors.white,
                              fontSize: 9,
                              height: 1.2,
                            ),
                          ),
                        ),
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

class _ItemStepper extends StatelessWidget {
  const _ItemStepper({
    required this.value,
    required this.onAdd,
    required this.onRemove,
  });

  final int value;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceLow,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: AppColors.surfaceContainer,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: value > 0 ? onRemove : null,
              child: SizedBox(
                width: 32,
                height: 32,
                child: Icon(
                  Icons.remove_rounded,
                  size: 16,
                  color: value > 0
                      ? AppColors.textPrimary
                      : AppColors.textTertiary,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 30,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 160),
              child: Text(
                '$value',
                key: ValueKey(value),
                textAlign: TextAlign.center,
                style: AppTextStyles.label.copyWith(fontSize: 14),
              ),
            ),
          ),
          Material(
            color: AppColors.primary,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onAdd,
              child: SizedBox(
                width: 32,
                height: 32,
                child: const Icon(
                  Icons.add_rounded,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SafetyNote extends StatelessWidget {
  const _SafetyNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.green.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.health_and_safety_rounded,
              size: 22,
              color: AppColors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('تغليف معقم وحافظ للحرارة', style: AppTextStyles.label),
                const SizedBox(height: 2),
                Text(
                  'يصلك طلبك ساخناً وطازجاً في أسرع وقت مع كباتن يلا طلبات.',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sticky cart tray (design 1).
// ---------------------------------------------------------------------------

class _CartTray extends StatelessWidget {
  const _CartTray({
    required this.itemCount,
    required this.total,
    required this.onCheckout,
  });

  final int itemCount;
  final double total;
  final VoidCallback? onCheckout;

  String get _countLabel {
    if (itemCount == 0) return 'السلة فارغة';
    if (itemCount == 1) return 'صنف واحد في السلة';
    if (itemCount == 2) return 'صنفان في السلة';
    if (itemCount <= 10) return '$itemCount أصناف في السلة';
    return '$itemCount صنفاً في السلة';
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.94),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          _PulseDot(),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              _countLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.label.copyWith(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            total.toStringAsFixed(0),
                            style: AppTextStyles.price.copyWith(fontSize: 18),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            'ر.س',
                            style: AppTextStyles.caption.copyWith(fontSize: 10),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(شامل الضريبة)',
                            style: AppTextStyles.caption.copyWith(fontSize: 10),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  height: 48,
                  child: FilledButton(
                    onPressed: onCheckout,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor: AppColors.primary.withValues(
                        alpha: 0.4,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'إتمام الطلب',
                          style: AppTextStyles.titleSmall.copyWith(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.arrow_forward,
                          size: 20,
                          color: Colors.white,
                        ),
                      ],
                    ),
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

class _PulseDot extends StatefulWidget {
  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.35, end: 1).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ),
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: AppColors.green,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
