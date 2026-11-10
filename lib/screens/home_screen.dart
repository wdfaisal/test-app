import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/app_sheets.dart';
import '../widgets/ui.dart';
import 'restaurant_screen.dart';

// ---------------------------------------------------------------------------
// Home — "الرئيسية (المظهر الأبيض النقي)".
//
// A faithful port of the pure-white Stitch export: fixed white header with the
// address pill + wallet + cart, services tiles, the YALLA30 gradient banner,
// "عروض حصرية اليوم" carousel, "مطاعم بالقرب منك" feed and the
// "الأكثر طلباً هذا الأسبوع" grid — all spacing/colors/type sizes follow the
// computed-style values measured in the design HTML.
// ---------------------------------------------------------------------------

/// Design text styles — every line renders in IBM Plex Sans Arabic.
abstract final class _T {
  static const _family = 'IBM Plex Sans Arabic';

  /// headline-sm: 18/24 w600.
  static const headlineSm = TextStyle(
    fontFamily: _family,
    fontSize: 18,
    height: 24 / 18,
    fontWeight: FontWeight.w600,
    color: AppColors.ink,
  );

  /// headline-md: 20/26 w600.
  static const headlineMd = TextStyle(
    fontFamily: _family,
    fontSize: 20,
    height: 26 / 20,
    fontWeight: FontWeight.w600,
    color: AppColors.ink,
  );

  /// label-lg: 14/20 w600.
  static const labelLg = TextStyle(
    fontFamily: _family,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w600,
    color: AppColors.ink,
  );

  /// label-md: 12/16 w600.
  static const labelMd = TextStyle(
    fontFamily: _family,
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w600,
    color: AppColors.ink,
  );

  /// label-sm: 10/14 w600.
  static const labelSm = TextStyle(
    fontFamily: _family,
    fontSize: 10,
    height: 14 / 10,
    fontWeight: FontWeight.w600,
    color: AppColors.ink,
  );

  /// body-sm: 12/16 w400.
  static const bodySm = TextStyle(
    fontFamily: _family,
    fontSize: 12,
    height: 16 / 12,
    color: AppColors.ink,
  );

  /// body-md: 14/20 w400.
  static const bodyMd = TextStyle(
    fontFamily: _family,
    fontSize: 14,
    height: 20 / 14,
    color: AppColors.ink,
  );

  static final headlineSmBold = headlineSm.copyWith(fontWeight: FontWeight.w700);
  static final headlineMdBold = headlineMd.copyWith(fontWeight: FontWeight.w700);
  static final labelMdPrimary = labelMd.copyWith(color: AppColors.primaryDark);
  static final labelMdMuted = labelMd.copyWith(color: AppColors.inkMuted);
  static final bodyMdMuted = bodyMd.copyWith(color: AppColors.inkMuted);
}

/// "(2.4k+)" review-count chips from the design.
String _reviewChip(int count) {
  if (count >= 1000) {
    final k = (count / 100).round() / 10;
    return '(${k.toStringAsFixed(1)}k+)';
  }
  return '($count)';
}

/// "1.8 كم" — one decimal, as measured in the design.
String _km(double value) => '${value.toStringAsFixed(1)} كم';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _nearbyKey = GlobalKey();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // --- Interactions --------------------------------------------------------

  Future<void> _handleNavTap(int index) async {
    switch (index) {
      case 1: // المفضلة
        await showFavoritesSheet(context);
        break;
      case 2: // طلباتي
        await showOrdersSheet(context);
        break;
      case 3: // حسابي
        await showProfileSheet(context);
        break;
      default: // استكشف — back to the very top.
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

  void _quickAdd(Restaurant restaurant, MenuItem item) {
    AppScope.of(context, listen: false).addToCart(
      restaurant: restaurant,
      item: item,
      selections: const {},
      quantity: 1,
    );
    showAppSnackBar(context, 'أُضيف "${item.name}" إلى السلة');
  }

  void _applyYallaPromo() {
    AppScope.of(context, listen: false).applyPromo('YALLA30');
    showAppSnackBar(context, 'تم تفعيل كود YALLA30 — خصم 30% على أول طلبين!');
  }

  void _comingSoon(String service) {
    showAppSnackBar(
      context,
      'خدمة $service قادمة قريباً — ترقّبونا',
      icon: Icons.rocket_launch_rounded,
    );
  }

  /// "المطاعم" service tile — glides down to the nearby restaurants feed.
  void _scrollToNearby() {
    final target = _nearbyKey.currentContext;
    if (target != null) {
      Scrollable.ensureVisible(
        target,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final offerRestaurants = offerRestaurantIds.map(restaurantById).toList();
    final nearbyRestaurants = nearbyRestaurantIds.map(restaurantById).toList();
    final mostOrdered = [
      for (final (restaurantId, itemId) in mostOrderedEntries)
        (
          restaurantById(restaurantId),
          menuItemById(restaurantById(restaurantId), itemId),
          mostOrderedSubtitles[itemId] ?? restaurantById(restaurantId).name,
        ),
    ];

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _PureHeader(
              address: state.address,
              cartCount: state.cartCount,
              onAddressTap: () => showAddressPicker(context),
              onWalletTap: () => showPaymentPicker(context),
              onCartTap: _openCart,
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SearchBar(onTap: () => showSearchOverlay(context)),
                    _ServicesSection(
                      onRestaurantsTap: _scrollToNearby,
                      onServiceTap: _comingSoon,
                    ),
                    _PromoBanner(onApply: _applyYallaPromo),
                    _OffersSection(
                      restaurants: offerRestaurants,
                      isFavorite: state.isFavorite,
                      onToggleFavorite: (id) => state.toggleFavorite(id),
                      onOpenRestaurant: _openRestaurant,
                      onAddItem: _quickAdd,
                    ),
                    _NearbySection(
                      sectionKey: _nearbyKey,
                      restaurants: nearbyRestaurants,
                      isFavorite: state.isFavorite,
                      onToggleFavorite: (id) => state.toggleFavorite(id),
                      onOpenRestaurant: _openRestaurant,
                      onSeeAll: () => showSearchOverlay(context),
                    ),
                    _MostOrderedSection(
                      entries: mostOrdered,
                      onOpenRestaurant: _openRestaurant,
                      onAddItem: _quickAdd,
                      onSeeMore: () => showSearchOverlay(context),
                    ),
                  ],
                ),
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
}

// ---------------------------------------------------------------------------
// Fixed white header — location pill + wallet + cart (h-56, hairline border).
// ---------------------------------------------------------------------------

class _PureHeader extends StatelessWidget {
  const _PureHeader({
    required this.address,
    required this.cartCount,
    required this.onAddressTap,
    required this.onWalletTap,
    required this.onCartTap,
  });

  final String address;
  final int cartCount;
  final VoidCallback onAddressTap;
  final VoidCallback onWalletTap;
  final VoidCallback onCartTap;

  String get _shortAddress {
    final parts = address.split('،');
    if (parts.length >= 2) {
      return '${parts[0].trim()}، ${parts[1].trim()}';
    }
    return address;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.surfacePure, width: 1),
        ),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          Expanded(
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(999),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onAddressTap,
                borderRadius: BorderRadius.circular(999),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 22,
                        color: AppColors.primaryDark,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'التوصيل إلى: $_shortAddress',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: _T.labelMd.copyWith(
                            fontSize: 16,
                            height: 20 / 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 20,
                        color: AppColors.inkMuted,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _PlainHeaderButton(
            icon: Icons.account_balance_wallet_rounded,
            iconSize: 22,
            color: AppColors.inkMuted,
            tooltip: 'المحفظة',
            onTap: onWalletTap,
          ),
          const SizedBox(width: 8),
          _CartButton(count: cartCount, onTap: onCartTap),
        ],
      ),
    );
  }
}

class _PlainHeaderButton extends StatelessWidget {
  const _PlainHeaderButton({
    required this.icon,
    required this.iconSize,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final double iconSize;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 40,
            height: 40,
            child: Center(
              child: Icon(icon, size: iconSize, color: color),
            ),
          ),
        ),
      ),
    );
  }
}

class _CartButton extends StatelessWidget {
  const _CartButton({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
            border: Border.fromBorderSide(
              BorderSide(color: AppColors.borderMuted),
            ),
            boxShadow: AppColors.cardShadow,
          ),
          child: Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              customBorder: const CircleBorder(),
              child: const Center(
                child: Icon(
                  Icons.shopping_bag_outlined,
                  size: 20,
                  color: AppColors.primaryDark,
                ),
              ),
            ),
          ),
        ),
        if (count > 0)
          PositionedDirectional(
            top: -4,
            start: -4,
            child: Container(
              constraints: const BoxConstraints(minWidth: 16),
              height: 16,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.primaryDark,
                borderRadius: BorderRadius.all(Radius.circular(999)),
                boxShadow: AppColors.cardShadow,
              ),
              child: Text(
                '$count',
                style: _T.labelSm.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Search bar — white, hairline border, r-16 (opens the search overlay).
// ---------------------------------------------------------------------------

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      // pt-3 pb-8 + wrapper pb-8 from the design → 12 above, 40 below.
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            height: 42,
            padding: const EdgeInsetsDirectional.only(start: 14, end: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderMuted),
              boxShadow: AppColors.cardShadow,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.search_rounded,
                  size: 20,
                  color: AppColors.primaryDark,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'ابحث عن مطعم أو صنف (برجر، بيتزا، شاورما)...',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _T.bodySm.copyWith(color: AppColors.inkMuted),
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

// ---------------------------------------------------------------------------
// خدماتنا — five service tiles with emoji, ground shadow and corner badges.
// ---------------------------------------------------------------------------

class _ServicesSection extends StatelessWidget {
  const _ServicesSection({
    required this.onRestaurantsTap,
    required this.onServiceTap,
  });

  final VoidCallback onRestaurantsTap;
  final ValueChanged<String> onServiceTap;

  static const _services = [
    (emoji: '🍔', size: 38.0, label: 'المطاعم', highlight: true, badge: null),
    (emoji: '🛍️', size: 36.0, label: 'طلبات مارت', highlight: false, badge: 'سريع'),
    (emoji: '🥦', size: 36.0, label: 'البقالة', highlight: false, badge: null),
    (emoji: '🍽️', size: 36.0, label: 'DineOut', highlight: false, badge: 'جديد'),
    (emoji: '💊', size: 36.0, label: 'صيدلية', highlight: false, badge: null),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4), // pt-1
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text('خدماتنا', style: _T.headlineSmBold),
                ),
                GestureDetector(
                  onTap: () => onServiceTap('باقي الخدمات'),
                  child: Text('عرض الكل', style: _T.labelMdPrimary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12), // gap-3
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              physics: const BouncingScrollPhysics(),
              itemCount: _services.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12), // gap-3
              itemBuilder: (context, index) {
                final service = _services[index];
                return _ServiceTile(
                  emoji: service.emoji,
                  emojiSize: service.size,
                  label: service.label,
                  highlight: service.highlight,
                  badge: service.badge,
                  onTap: service.label == 'المطاعم'
                      ? onRestaurantsTap
                      : () => onServiceTap(service.label),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceTile extends StatelessWidget {
  const _ServiceTile({
    required this.emoji,
    required this.emojiSize,
    required this.label,
    required this.highlight,
    required this.badge,
    required this.onTap,
  });

  final String emoji;
  final double emojiSize;
  final String label;
  final bool highlight;
  final String? badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 80,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: highlight
                          ? AppColors.borderMuted
                          : AppColors.surfacePure,
                    ),
                    boxShadow: AppColors.cardShadow,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        emoji,
                        style: TextStyle(
                          fontSize: emojiSize,
                          height: 1,
                          shadows: const [
                            Shadow(
                              color: Color(0x2E000000),
                              offset: Offset(0, 6),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4), // mt-1
                      ImageFiltered(
                        imageFilter: ui.ImageFilter.blur(
                          sigmaX: 1.5,
                          sigmaY: 1.5,
                        ),
                        child: Container(
                          width: 36,
                          height: 6,
                          decoration: BoxDecoration(
                            color: const Color(0x1A000000),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (badge != null)
                  PositionedDirectional(
                    top: -6,
                    start: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: badge == 'سريع'
                            ? AppColors.primaryDark
                            : AppColors.inkBadge,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: AppColors.cardShadow,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            badge!,
                            style: _T.labelSm.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              height: 1,
                            ),
                          ),
                          if (badge == 'سريع') ...[
                            const SizedBox(width: 2),
                            const Text(
                              '🚀',
                              style: TextStyle(fontSize: 9, height: 1),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8), // gap-2
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: _T.headlineSm.copyWith(
                fontSize: 13,
                height: 16 / 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// YALLA30 banner — crimson→orange gradient with burger medallion + pager dots.
// ---------------------------------------------------------------------------

class _PromoBanner extends StatelessWidget {
  const _PromoBanner({required this.onApply});

  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    return Padding(
      // mt-1 + pt-2 → 12 below the services row.
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        height: 114,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            // bg-gradient-to-l: from-primary (right) to-primary-container (left).
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
            colors: [AppColors.primaryDark, Color(0xFFFF591B)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColors.cardShadow,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Deco glow circle, -top-12 -start-12.
              PositionedDirectional(
                top: -48,
                start: -48,
                child: ImageFiltered(
                  imageFilter: ui.ImageFilter.blur(
                    sigmaX: 24,
                    sigmaY: 24,
                  ),
                  child: Container(
                    width: 128,
                    height: 128,
                    decoration: const BoxDecoration(
                      color: Color(0x1AFFFFFF),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12), // p-3
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // عرض حصري chip.
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: const BoxDecoration(
                              color: Color(0x33FFFFFF),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(999)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.local_fire_department_outlined,
                                  size: 13,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'عرض حصري',
                                  style: _T.labelSm.copyWith(
                                    color: Colors.white,
                                    height: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4), // gap-1
                          Text(
                            'خصم 30% على أول طلبين!',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: _T.headlineSm.copyWith(
                              fontSize: 16,
                              height: 20 / 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                'كود:',
                                style: _T.labelSm.copyWith(
                                  fontSize: 11,
                                  color: Colors.white.withValues(
                                    alpha: 0.9,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6), // gap-1.5
                              GestureDetector(
                                onTap: onApply,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: BorderRadius.circular(6),
                                    boxShadow: AppColors.cardShadow,
                                  ),
                                  child: Text(
                                    'YALLA30',
                                    style: _T.labelSm.copyWith(
                                      fontSize: 11,
                                      color: AppColors.primaryDark,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.6,
                                      height: 14 / 11,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4), // ms-1
                              Material(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(8),
                                clipBehavior: Clip.antiAlias,
                                child: InkWell(
                                  onTap: onApply,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'اطلب الآن',
                                          style: _T.labelSm.copyWith(
                                            fontSize: 11,
                                            color: AppColors.primaryDark,
                                            fontWeight: FontWeight.w700,
                                            height: 14 / 11,
                                          ),
                                        ),
                                        const SizedBox(width: 2),
                                        Transform.scale(
                                          scaleX: -1, // rtl:-scale-x-100
                                          child: const Icon(
                                            Icons.arrow_forward,
                                            size: 13,
                                            color: AppColors.primaryDark,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8), // gap-2
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          padding: const EdgeInsets.all(2), // p-0.5
                          decoration: const BoxDecoration(
                            color: Color(0x33FFFFFF), // white/20
                            shape: BoxShape.circle,
                            boxShadow: AppColors.pillShadow,
                          ),
                          child: ClipOval(
                            child: AppImage(
                              'assets/images/yalla/y_pure_promo.jpg',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6), // gap-1.5
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 12,
                              height: 4,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(999)),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Container(
                              width: 4,
                              height: 4,
                              decoration: const BoxDecoration(
                                color: Color(0x66FFFFFF), // white/40
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Container(
                              width: 4,
                              height: 4,
                              decoration: const BoxDecoration(
                                color: Color(0x66FFFFFF),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
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
// عروض حصرية اليوم — carousel of offer cards with a 3-col discount grid.
// ---------------------------------------------------------------------------

class _OffersSection extends StatelessWidget {
  const _OffersSection({
    required this.restaurants,
    required this.isFavorite,
    required this.onToggleFavorite,
    required this.onOpenRestaurant,
    required this.onAddItem,
  });

  final List<Restaurant> restaurants;
  final bool Function(String restaurantId) isFavorite;
  final ValueChanged<String> onToggleFavorite;
  final ValueChanged<Restaurant> onOpenRestaurant;
  final void Function(Restaurant restaurant, MenuItem item) onAddItem;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24), // mt-space-lg
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryDark,
                    borderRadius: BorderRadius.all(Radius.circular(999)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(child: Text('عروض حصرية اليوم', style: _T.headlineSm)),
                // Timer chip.
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.borderMuted),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.timer_outlined,
                        size: 16,
                        color: AppColors.primaryDark,
                      ),
                      const SizedBox(width: 4),
                      Text('ينتهي خلال ساعتين', style: _T.labelMdPrimary),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12), // gap-3
          // Content-height horizontal strip (the design strip sizes to its
          // tallest card) — no fixed height means no vertical overflow.
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < restaurants.length; i++) ...[
                  if (i > 0) const SizedBox(width: 16), // gap-4
                  _OfferCard(
                    restaurant: restaurants[i],
                    items: [
                      for (final itemId in offerItemIds[restaurants[i].id]!)
                        menuItemById(restaurants[i], itemId),
                    ],
                    isFavorite: isFavorite(restaurants[i].id),
                    onToggleFavorite: () => onToggleFavorite(restaurants[i].id),
                    onOpen: () => onOpenRestaurant(restaurants[i]),
                    onAddItem: (item) => onAddItem(restaurants[i], item),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  const _OfferCard({
    required this.restaurant,
    required this.items,
    required this.isFavorite,
    required this.onToggleFavorite,
    required this.onOpen,
    required this.onAddItem,
  });

  final Restaurant restaurant;
  final List<MenuItem> items;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  final VoidCallback onOpen;
  final ValueChanged<MenuItem> onAddItem;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onOpen,
      child: Container(
        width: 320,
        padding: const EdgeInsets.all(14), // p-3.5
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.surfacePure),
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo box 64×64, r-12, hairline border.
                Container(
                  width: 64,
                  height: 64,
                  padding: const EdgeInsets.all(2), // p-0.5
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.surfacePure),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: AppImage(restaurant.logo, fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(width: 10), // gap-2.5
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              restaurant.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: _T.headlineSm.copyWith(
                                fontSize: 16,
                                height: 20 / 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6), // gap-1.5
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: const BoxDecoration(
                              color: AppColors.primaryDark,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8)),
                              boxShadow: AppColors.cardShadow,
                            ),
                            child: Text(
                              restaurant.badge ?? '',
                              style: _T.labelSm.copyWith(
                                fontSize: 11,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                height: 13 / 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4), // gap-1
                      Text(
                        restaurant.cuisine,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _T.bodySm.copyWith(
                          fontSize: 11,
                          color: AppColors.inkMuted,
                        ),
                      ),
                      const SizedBox(height: 2), // gap-1 + pt-0.5
                      Row(
                        children: [
                          // Rating pill.
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.tertiarySoft,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  size: 13,
                                  color: AppColors.tertiary,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  restaurant.rating.toStringAsFixed(1),
                                  style: _T.bodySm.copyWith(
                                    fontSize: 11,
                                    color: AppColors.tertiary,
                                    fontWeight: FontWeight.w700,
                                    height: 13 / 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8), // gap-2
                          Icon(
                            Icons.moped_outlined,
                            size: 14,
                            color: AppColors.primaryDark,
                          ),
                          const SizedBox(width: 4), // gap-1
                          Flexible(
                            child: Text(
                              '${restaurant.deliveryMin}-'
                              '${restaurant.deliveryMax} دقيقة',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: _T.bodySm.copyWith(
                                fontSize: 11,
                                color: AppColors.inkMuted,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              restaurant.deliveryFee == 0
                                  ? 'توصيل مجاني'
                                  : 'توصيل ${money(restaurant.deliveryFee)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: _T.bodySm.copyWith(
                                fontSize: 11,
                                color: restaurant.deliveryFee == 0
                                    ? AppColors.tertiary
                                    : AppColors.inkMuted,
                                fontWeight: restaurant.deliveryFee == 0
                                    ? FontWeight.w600
                                    : FontWeight.w700,
                                height: 13 / 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                // Favorite toggle 28×28.
                GestureDetector(
                  onTap: onToggleFavorite,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceLowPure,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      size: 16,
                      color: isFavorite
                          ? AppColors.primaryDark
                          : AppColors.ink,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12), // gap-3
            // Discount grid.
            Container(
              padding: const EdgeInsets.only(top: 10), // pt-2.5
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColors.surfacePure),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'أبرز عروض الخصم',
                        style: _T.labelMd.copyWith(
                          color: AppColors.inkMuted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${items.length} أصناف مخفضة',
                        style: _T.bodySm.copyWith(
                          fontSize: 11,
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8), // mb-2
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < items.length; i++) ...[
                        if (i > 0) const SizedBox(width: 8), // gap-2
                        Expanded(
                          child: _OfferItemCard(
                            item: items[i],
                            onAdd: () => onAddItem(items[i]),
                          ),
                        ),
                      ],
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

class _OfferItemCard extends StatelessWidget {
  const _OfferItemCard({required this.item, required this.onAdd});

  final MenuItem item;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8), // p-2
      decoration: BoxDecoration(
        color: AppColors.surfaceLowPure.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfacePure),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  height: 80,
                  width: double.infinity,
                  child: AppImage(item.image, fit: BoxFit.cover),
                ),
              ),
              PositionedDirectional(
                bottom: 4,
                end: 4, // bottom-1 end-1
                child: _AddButton(size: 28, iconSize: 16, onTap: onAdd),
              ),
            ],
          ),
          const SizedBox(height: 8), // mb-2
          Text(
            item.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: _T.bodySm.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2), // mt-0.5
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                money(item.price),
                style: _T.headlineSm.copyWith(
                  fontSize: 13,
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 4), // gap-1
              if (item.oldPrice != null)
                Flexible(
                  child: Text(
                    money(item.oldPrice!),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _T.bodySm.copyWith(
                      fontSize: 10,
                      color: AppColors.inkMuted,
                      decoration: TextDecoration.lineThrough,
                      decorationColor: AppColors.inkMuted,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// مطاعم بالقرب منك — hero cards with status badges, moped pill and rating.
// ---------------------------------------------------------------------------

class _NearbySection extends StatelessWidget {
  const _NearbySection({
    required this.sectionKey,
    required this.restaurants,
    required this.isFavorite,
    required this.onToggleFavorite,
    required this.onOpenRestaurant,
    required this.onSeeAll,
  });

  final GlobalKey sectionKey;
  final List<Restaurant> restaurants;
  final bool Function(String restaurantId) isFavorite;
  final ValueChanged<String> onToggleFavorite;
  final ValueChanged<Restaurant> onOpenRestaurant;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0), // mt-space-lg px-margin
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 24,
                decoration: const BoxDecoration(
                  color: AppColors.primaryDark,
                  borderRadius: BorderRadius.all(Radius.circular(999)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text('مطاعم بالقرب منك', style: _T.headlineSm),
              ),
              GestureDetector(
                onTap: onSeeAll,
                child: Text('عرض الكل (42)', style: _T.labelMdPrimary),
              ),
            ],
          ),
          const SizedBox(height: 12), // gap-3
          for (var i = 0; i < restaurants.length; i++) ...[
            if (i > 0) const SizedBox(height: 16), // gap-4
            _NearbyCard(
              key: i == 0 ? sectionKey : null,
              restaurant: restaurants[i],
              isFavorite: isFavorite(restaurants[i].id),
              onToggleFavorite: () =>
                  onToggleFavorite(restaurants[i].id),
              onOpen: () => onOpenRestaurant(restaurants[i]),
            ),
          ],
        ],
      ),
    );
  }
}

class _NearbyCard extends StatelessWidget {
  const _NearbyCard({
    super.key,
    required this.restaurant,
    required this.isFavorite,
    required this.onToggleFavorite,
    required this.onOpen,
  });

  final Restaurant restaurant;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final hasLogoOverlay = restaurant.id == 'shawarmer';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfacePure),
        boxShadow: AppColors.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onOpen,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 176, // h-44
                width: double.infinity,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: AppImage(restaurant.cover, fit: BoxFit.cover),
                    ),
                    // Status badges — top-3 start-3.
                    PositionedDirectional(
                      top: 12,
                      start: 12,
                      child: Row(
                        children: [
                          _statusBadge(
                            'مفتوح الآن',
                            bg: AppColors.tertiary,
                            fg: Colors.white,
                            weight: FontWeight.w600,
                          ),
                          if (restaurant.badge != null &&
                              restaurant.badge != 'مفتوح الآن') ...[
                            const SizedBox(width: 8),
                            if (restaurant.badgeTone == BadgeTone.outline)
                              _statusBadge(
                                restaurant.badge!,
                                bg: AppColors.surface,
                                fg: AppColors.primaryDark,
                                weight: FontWeight.w700,
                                border: AppColors.borderMuted,
                              )
                            else
                              _statusBadge(
                                restaurant.badge!,
                                bg: AppColors.primaryDark,
                                fg: Colors.white,
                                weight: FontWeight.w700,
                              ),
                          ],
                        ],
                      ),
                    ),
                    // Favorite — top-3 end-3, 36×36 frosted circle.
                    PositionedDirectional(
                      top: 12,
                      end: 12,
                      child: GestureDetector(
                        onTap: onToggleFavorite,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.surfacePure),
                          ),
                          child: Icon(
                            isFavorite
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            size: 20,
                            color: isFavorite
                                ? AppColors.primaryDark
                                : AppColors.ink,
                          ),
                        ),
                      ),
                    ),
                    // Moped + distance pill — bottom-3 start-3.
                    PositionedDirectional(
                      bottom: 12,
                      start: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: AppColors.surfacePure),
                          boxShadow: AppColors.cardShadow,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.moped_outlined,
                              size: 16,
                              color: AppColors.primaryDark,
                            ),
                            const SizedBox(width: 6), // gap-1.5
                            Text(
                              '${restaurant.deliveryMin} - '
                              '${restaurant.deliveryMax} دقيقة',
                              style: _T.labelMd,
                            ),
                            const SizedBox(width: 4), // mx-1
                            Container(
                              width: 4,
                              height: 4,
                              decoration: const BoxDecoration(
                                color: AppColors.separatorDot,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(_km(restaurant.distanceKm), style: _T.labelMd),
                          ],
                        ),
                      ),
                    ),
                    // Shawarmer logo — absolute -bottom-5 left-4 (physical).
                    if (hasLogoOverlay)
                      Positioned(
                        bottom: -20,
                        left: 16,
                        child: Container(
                          width: 48,
                          height: 48,
                          padding: const EdgeInsets.all(4), // p-1
                          decoration: const BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.all(
                              Radius.circular(12),
                            ),
                            border: Border.fromBorderSide(
                              BorderSide(color: AppColors.surfacePure),
                            ),
                            boxShadow: AppColors.pillShadow,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.borderMuted),
                            ),
                            child: const Center(
                              child: _ShawarmaMark(
                                color: AppColors.primaryDark,
                                size: 28,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16), // p-4
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            restaurant.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: _T.headlineMdBold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.tertiarySoft,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                size: 16,
                                color: AppColors.tertiary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                restaurant.rating.toStringAsFixed(1),
                                style: _T.labelMd.copyWith(
                                  color: AppColors.tertiary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _reviewChip(restaurant.reviewCount),
                                style: _T.labelSm.copyWith(
                                  color: AppColors.inkMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8), // gap-2
                    Text(restaurant.cuisine, style: _T.bodyMdMuted),
                    const SizedBox(height: 8), // pt-2
                    Row(
                      children: [
                        if (restaurant.deliveryFee == 0)
                          Row(
                            children: [
                              const Icon(
                                Icons.local_shipping_outlined,
                                size: 18,
                                color: AppColors.tertiary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'توصيل مجاني',
                                style: _T.labelMd.copyWith(
                                  color: AppColors.tertiary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          )
                        else
                          Row(
                            children: [
                              const Icon(
                                Icons.payments_rounded,
                                size: 18,
                                color: AppColors.inkMuted,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'توصيل: ${money(restaurant.deliveryFee)}',
                                style: _T.labelMdMuted,
                              ),
                            ],
                          ),
                        const SizedBox(width: 16), // gap-4
                        Container(
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                            color: AppColors.separatorDot,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Row(
                          children: [
                            const Icon(
                              Icons.shopping_bag_outlined,
                              size: 18,
                              color: AppColors.inkMuted,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'الحد الأدنى: '
                              '${money(restaurant.minimumOrder)}',
                              style: _T.labelMdMuted,
                            ),
                          ],
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

  Widget _statusBadge(
    String label, {
    required Color bg,
    required Color fg,
    required FontWeight weight,
    Color? border,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: border == null ? null : Border.all(color: border),
        boxShadow: AppColors.cardShadow,
      ),
      child: Text(
        label,
        style: _T.labelSm.copyWith(color: fg, fontWeight: weight),
      ),
    );
  }
}

/// The shawarma mark from the design's inline SVG (شاورمر logo box).
class _ShawarmaMark extends StatelessWidget {
  const _ShawarmaMark({required this.color, this.size = 28});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _ShawarmaMarkPainter(color),
    );
  }
}

class _ShawarmaMarkPainter extends CustomPainter {
  _ShawarmaMarkPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    canvas.save();
    canvas.scale(size.width / 24, size.height / 24);

    // Outer wrap — M12 2 C… (the full design path).
    final outer = Path()
      ..moveTo(12, 2)
      ..cubicTo(7.5, 2, 4, 4.5, 4, 8)
      ..cubicTo(4, 10.2, 5.4, 12.2, 7.6, 13.3)
      ..lineTo(6, 21)
      ..lineTo(9, 19.5)
      ..lineTo(12, 22)
      ..lineTo(15, 19.5)
      ..lineTo(18, 22)
      ..lineTo(16.4, 14.3)
      ..cubicTo(18.6, 12.2, 20, 10.2, 20, 8)
      ..cubicTo(20, 4.5, 16.5, 2, 12, 2)
      ..close();

    // Face cutout — M12 4 c… l….
    final inner = Path()
      ..moveTo(12, 4)
      ..cubicTo(15.3, 4, 18, 5.8, 18, 8)
      ..cubicTo(18, 9.5, 16.7, 10.8, 14.7, 11.5)
      ..lineTo(14, 11.7)
      ..lineTo(14.7, 15.2)
      ..lineTo(13, 13.8)
      ..lineTo(12, 13)
      ..lineTo(11, 12.2)
      ..lineTo(9.3, 13.6)
      ..lineTo(10, 10.1)
      ..lineTo(9.3, 9.9)
      ..cubicTo(8.3, 10.8, 7, 9.5, 7, 8)
      ..cubicTo(7, 5.8, 9.7, 4, 13, 4)
      ..close();

    canvas.drawPath(outer, paint);
    // The face subpath is a cutout in the SVG — punch it out in white.
    canvas.drawPath(
      inner,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill
        ..isAntiAlias = true,
    );
    // Eyes.
    canvas.drawCircle(const Offset(9.5, 8), 1, paint);
    canvas.drawCircle(const Offset(14.5, 8), 1, paint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(_ShawarmaMarkPainter oldDelegate) =>
      oldDelegate.color != color;
}

// ---------------------------------------------------------------------------
// الأكثر طلباً هذا الأسبوع — 2-col grid of best-selling dishes.
// ---------------------------------------------------------------------------

class _MostOrderedSection extends StatelessWidget {
  const _MostOrderedSection({
    required this.entries,
    required this.onOpenRestaurant,
    required this.onAddItem,
    required this.onSeeMore,
  });

  final List<(Restaurant, MenuItem, String)> entries;
  final ValueChanged<Restaurant> onOpenRestaurant;
  final void Function(Restaurant restaurant, MenuItem item) onAddItem;
  final VoidCallback onSeeMore;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0), // mt-space-lg
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 24,
                decoration: const BoxDecoration(
                  color: AppColors.primaryDark,
                  borderRadius: BorderRadius.all(Radius.circular(999)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'الأكثر طلباً هذا الأسبوع',
                  style: _T.headlineSm,
                ),
              ),
              GestureDetector(
                onTap: onSeeMore,
                child: Text('المزيد', style: _T.labelMdPrimary),
              ),
            ],
          ),
          const SizedBox(height: 12), // gap-3
          for (var i = 0; i < entries.length; i += 2)
            Padding(
              padding: EdgeInsets.only(
                bottom: i + 2 < entries.length ? 12 : 0, // gap-3
              ),
              child: Builder(
                builder: (context) {
                  Widget card(int index) => _MostOrderedCard(
                        entry: entries[index],
                        onOpen: () =>
                            onOpenRestaurant(entries[index].$1),
                        onAdd: () => onAddItem(
                          entries[index].$1,
                          entries[index].$2,
                        ),
                      );
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: card(i)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: i + 1 < entries.length
                            ? card(i + 1)
                            : const SizedBox(),
                      ),
                    ],
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _MostOrderedCard extends StatelessWidget {
  const _MostOrderedCard({
    required this.entry,
    required this.onOpen,
    required this.onAdd,
  });

  final (Restaurant, MenuItem, String) entry;
  final VoidCallback onOpen;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final (restaurant, item, subtitle) = entry;

    return GestureDetector(
      onTap: onOpen,
      child: Container(
        padding: const EdgeInsets.all(12), // p-3
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.surfacePure),
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: AppImage(item.image, fit: BoxFit.cover),
                    ),
                  ),
                  PositionedDirectional(
                    bottom: 8,
                    end: 8, // bottom-2 end-2
                    child: _AddButton(size: 36, iconSize: 20, onTap: onAdd),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8), // mb-2
            Text(
              item.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _T.labelLg,
            ),
            const SizedBox(height: 4), // gap-1
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _T.bodySm.copyWith(color: AppColors.inkMuted),
            ),
            const SizedBox(height: 4), // mt-1
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  money(item.price),
                  style: _T.headlineSm.copyWith(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (item.oldPrice != null)
                  Text(
                    money(item.oldPrice!),
                    style: _T.bodySm.copyWith(
                      color: AppColors.inkMuted,
                      decoration: TextDecoration.lineThrough,
                      decorationColor: AppColors.inkMuted,
                    ),
                  )
                else if (item.badge != null)
                  Text(
                    item.badge!,
                    style: _T.labelSm.copyWith(
                      color: item.badge == 'الأعلى تقييماً'
                          ? AppColors.tertiary
                          : AppColors.inkMuted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Round primary "+"" button shared by item cards.
class _AddButton extends StatelessWidget {
  const _AddButton({
    required this.size,
    required this.iconSize,
    required this.onTap,
  });

  final double size;
  final double iconSize;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: AppColors.primaryDark,
          shape: BoxShape.circle,
          boxShadow: AppColors.pillShadow,
        ),
        child: Icon(Icons.add_rounded, size: iconSize, color: Colors.white),
      ),
    );
  }
}
