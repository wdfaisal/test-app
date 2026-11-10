import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../models/models.dart';
import '../screens/restaurant_screen.dart';
import '../screens/tracking_screen.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'ui.dart';

Future<void> showAddressPicker(BuildContext context) {
  final state = AppScope.of(context, listen: false);
  return showAppSheet(
    context: context,
    heightFactor: 0.66,
    child: StatefulBuilder(
      builder: (sheetContext, setSheetState) {
        return Column(
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('أين نوصل طلبك؟', style: AppTextStyles.headline),
                        const SizedBox(height: 4),
                        Text(
                          'اختر عنواناً محفوظاً أو أضف عنواناً جديداً',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
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
            const SizedBox(height: 18),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                itemCount: savedAddresses.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final address = savedAddresses[index];
                  final selected = state.address == address.details;
                  final icon = switch (address.icon) {
                    'work' => Icons.work_outline_rounded,
                    'family' => Icons.cottage_outlined,
                    _ => Icons.home_outlined,
                  };
                  return InkWell(
                    onTap: () {
                      state.setAddress(address);
                      Navigator.pop(sheetContext);
                      showAppSnackBar(
                        context,
                        'تم تغيير عنوان التوصيل إلى ${address.label}',
                        icon: Icons.location_on_rounded,
                      );
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.primarySoft
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selected
                              ? AppColors.primary.withValues(alpha: 0.35)
                              : AppColors.border,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.inkSoft,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Icon(
                              icon,
                              color: selected
                                  ? Colors.white
                                  : AppColors.textPrimary,
                              size: 21,
                            ),
                          ),
                          const SizedBox(width: 13),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  address.label,
                                  style: AppTextStyles.titleSmall,
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  address.details,
                                  style: AppTextStyles.bodySmall,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          if (selected)
                            const Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.primary,
                              size: 21,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                22,
                12,
                22,
                18 + MediaQuery.paddingOf(sheetContext).bottom,
              ),
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(sheetContext);
                  showAppSnackBar(
                    context,
                    'سيتم فتح خريطة تحديد الموقع في النسخة الكاملة',
                    icon: Icons.map_outlined,
                  );
                },
                icon: const Icon(Icons.add_location_alt_outlined, size: 18),
                label: const Text('إضافة عنوان جديد'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 54),
                  foregroundColor: AppColors.textPrimary,
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  textStyle: AppTextStyles.titleSmall,
                ),
              ),
            ),
          ],
        );
      },
    ),
  );
}

Future<void> showPaymentPicker(BuildContext context) {
  final state = AppScope.of(context, listen: false);
  return showAppSheet(
    context: context,
    heightFactor: 0.72,
    child: StatefulBuilder(
      builder: (sheetContext, setSheetState) {
        final methods = [
          (
            id: 'card',
            title: 'بطاقة مدى أو فيزا',
            subtitle: '•••• ٤٢٤٢',
            icon: Icons.credit_card_rounded,
          ),
          (
            id: 'apple',
            title: 'Apple Pay',
            subtitle: 'الدفع السريع والآمن',
            icon: Icons.phone_iphone_rounded,
          ),
          (
            id: 'cash',
            title: 'الدفع عند الاستلام',
            subtitle: 'نقداً أو بالبطاقة',
            icon: Icons.payments_outlined,
          ),
        ];
        return Column(
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
                    child: Text('طريقة الدفع', style: AppTextStyles.headline),
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
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF181C20), Color(0xFF2D3135)],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.14),
                      blurRadius: 26,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.contactless_rounded,
                          color: AppColors.primary,
                          size: 26,
                        ),
                        const Spacer(),
                        Text(
                          'VISA',
                          style: AppTextStyles.title.copyWith(
                            color: Colors.white,
                            fontStyle: FontStyle.italic,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    Text(
                      '٤٢٤٢  ••••  ••••  ٨٧١٢',
                      style: AppTextStyles.title.copyWith(
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text(
                          'أحمد العتيبي',
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.white.withValues(alpha: 0.65),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '09/29',
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.white.withValues(alpha: 0.65),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            ...methods.map((method) {
              final selected = state.paymentMethod == method.id;
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 5,
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () {
                    state.setPaymentMethod(method.id);
                    setSheetState(() {});
                    Navigator.pop(sheetContext);
                    showAppSnackBar(
                      context,
                      'تم اختيار ${method.title}',
                      icon: Icons.check_circle_rounded,
                    );
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 13,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primarySoft
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: selected
                            ? AppColors.primary.withValues(alpha: 0.35)
                            : AppColors.border,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.primary
                                : AppColors.inkSoft,
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: Icon(
                            method.icon,
                            color: selected
                                ? Colors.white
                                : AppColors.textPrimary,
                            size: 19,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                method.title,
                                style: AppTextStyles.titleSmall,
                              ),
                              Text(
                                method.subtitle,
                                style: AppTextStyles.caption,
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          selected
                              ? Icons.radio_button_checked_rounded
                              : Icons.radio_button_off_rounded,
                          color: selected
                              ? AppColors.primary
                              : AppColors.textTertiary,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const Spacer(),
          ],
        );
      },
    ),
  );
}

Future<void> showSearchOverlay(BuildContext context) {
  return showAppSheet(
    context: context,
    heightFactor: 0.92,
    child: _SearchOverlay(
      onRestaurantSelected: (restaurant) {
        Navigator.pop(context);
        Navigator.of(context)
            .push(premiumRoute(RestaurantScreen(restaurant: restaurant)));
      },
    ),
  );
}

class _SearchOverlay extends StatefulWidget {
  const _SearchOverlay({required this.onRestaurantSelected});

  final ValueChanged<Restaurant> onRestaurantSelected;

  @override
  State<_SearchOverlay> createState() => _SearchOverlayState();
}

class _SearchOverlayState extends State<_SearchOverlay> {
  final _controller = TextEditingController();
  String _query = '';
  final _quickSearches = ['برجر', 'بيتزا', 'شاورما', 'حلويات', 'قهوة'];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Restaurant> get _results {
    if (_query.trim().isEmpty) return restaurants;
    final query = _query.trim();
    return restaurants.where((restaurant) {
      return restaurant.name.contains(query) ||
          restaurant.cuisine.contains(query) ||
          restaurant.tags.any((tag) => tag.contains(query)) ||
          restaurant.menu.any((item) => item.name.contains(query));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          const Center(child: SheetHandle()),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Row(
              children: [
                Text('ابحث عن كل شيء', style: AppTextStyles.headline),
                const Spacer(),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: TextField(
              controller: _controller,
              autofocus: true,
              onChanged: (value) => setState(() => _query = value),
              style: AppTextStyles.titleSmall,
              decoration: InputDecoration(
                hintText: 'مطاعم، أطباق، حلويات...',
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(right: 16, left: 10),
                  child: Icon(
                    Icons.search_rounded,
                    color: AppColors.textSecondary,
                    size: 21,
                  ),
                ),
                prefixIconConstraints: const BoxConstraints(minWidth: 50),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _controller.clear();
                          setState(() => _query = '');
                        },
                        icon: const Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: AppColors.textTertiary,
                        ),
                      ),
                fillColor: AppColors.surface,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _quickSearches.map((term) {
                return InkWell(
                  onTap: () {
                    _controller.text = term;
                    setState(() => _query = term);
                  },
                  borderRadius: BorderRadius.circular(999),
                  child: AppTag(
                    label: term,
                    background: _query == term
                        ? AppColors.primarySoft
                        : AppColors.surface,
                    foreground: _query == term
                        ? AppColors.primaryDark
                        : AppColors.textSecondary,
                    borderColor: _query == term
                        ? AppColors.primary.withValues(alpha: 0.25)
                        : AppColors.border,
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Row(
              children: [
                Text(
                  _query.isEmpty ? 'مطاعم قريبة منك' : 'نتائج البحث',
                  style: AppTextStyles.title,
                ),
                const SizedBox(width: 8),
                Text('${_results.length}', style: AppTextStyles.caption),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _results.isEmpty
                ? _EmptySearch(query: _query)
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(22, 4, 22, 24),
                    itemCount: _results.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final restaurant = _results[index];
                      return InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () => widget.onRestaurantSelected(restaurant),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              AppImage(
                                restaurant.cover,
                                width: 68,
                                height: 68,
                                radius: 14,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      restaurant.name,
                                      style: AppTextStyles.titleSmall,
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      '${restaurant.cuisine} · ${restaurant.deliveryTime}',
                                      style: AppTextStyles.caption,
                                    ),
                                    const SizedBox(height: 5),
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
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(width: 9),
                                        const Icon(
                                          Icons.delivery_dining_rounded,
                                          size: 14,
                                          color: AppColors.textTertiary,
                                        ),
                                        const SizedBox(width: 3),
                                        Text(
                                          restaurant.deliveryFee == 0
                                              ? 'مجاني'
                                              : money(restaurant.deliveryFee),
                                          style: AppTextStyles.caption,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_back_rounded,
                                size: 18,
                                color: AppColors.textTertiary,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _EmptySearch extends StatelessWidget {
  const _EmptySearch({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: const BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off_rounded,
                color: AppColors.primaryDark,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text('لم نجد نتائج لـ "$query"', style: AppTextStyles.title),
            const SizedBox(height: 5),
            Text(
              'جرّب البحث عن طبق أو مطعم آخر',
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> showOrdersSheet(BuildContext context) {
  final state = AppScope.of(context, listen: false);
  final activeOrder = state.activeOrder;
  return showAppSheet(
    context: context,
    heightFactor: 0.72,
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
              Expanded(child: Text('طلباتي', style: AppTextStyles.headline)),
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
        const SizedBox(height: 18),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
            children: [
              if (activeOrder != null) ...[
                Text('الطلب الحالي', style: AppTextStyles.title),
                const SizedBox(height: 10),
                _ActiveOrderCard(order: activeOrder),
                const SizedBox(height: 22),
              ] else
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: const BoxDecoration(
                          color: AppColors.primarySoft,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.receipt_long_outlined,
                          color: AppColors.primaryDark,
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text('لا يوجد طلب نشط', style: AppTextStyles.title),
                      const SizedBox(height: 4),
                      Text(
                        'اكتشف مطعماً وأضف أطباقك المفضلة',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 8),
              Text('طلبات سابقة', style: AppTextStyles.title),
              const SizedBox(height: 10),
              _PastOrderCard(
                restaurant: restaurants[5],
                date: '٢٨ أكتوبر',
                total: 64,
                items: 'كيك الفستق، سبانيش لاتيه',
              ),
              const SizedBox(height: 10),
              _PastOrderCard(
                restaurant: restaurants[1],
                date: '٢١ أكتوبر',
                total: 82,
                items: 'مارغريتا نابولية، تيراميسو',
              ),
              const SizedBox(height: 10),
              _PastOrderCard(
                restaurant: restaurants[0],
                date: '١٤ أكتوبر',
                total: 76,
                items: 'دوبل سماش برجر، ميلك شيك',
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _ActiveOrderCard extends StatelessWidget {
  const _ActiveOrderCard({required this.order});

  final PlacedOrder order;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              AppImage(
                order.restaurant.cover,
                width: 62,
                height: 62,
                radius: 16,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.restaurant.name,
                      style: AppTextStyles.titleSmall,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'طلب #${order.number} · ${order.itemCount} أصناف',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'قيد التوصيل',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w700,
                    fontSize: 10.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: const LinearProgressIndicator(
              value: 0.58,
              minHeight: 6,
              backgroundColor: AppColors.inkSoft,
              valueColor: AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.of(context)
                        .push(premiumRoute(const TrackingScreen()));
                  },
                  icon: const Icon(Icons.near_me_rounded, size: 17),
                  label: const Text('تتبع الطلب'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 46),
                    backgroundColor: AppColors.charcoal,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(money(order.total), style: AppTextStyles.price),
            ],
          ),
        ],
      ),
    );
  }
}

class _PastOrderCard extends StatelessWidget {
  const _PastOrderCard({
    required this.restaurant,
    required this.date,
    required this.total,
    required this.items,
  });

  final Restaurant restaurant;
  final String date;
  final double total;
  final String items;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          AppImage(restaurant.cover, width: 56, height: 56, radius: 14),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(restaurant.name, style: AppTextStyles.titleSmall),
                const SizedBox(height: 2),
                Text(items, style: AppTextStyles.caption),
                const SizedBox(height: 3),
                Text(
                  '$date · ${money(total)}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                    fontSize: 10.5,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.inkSoft,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'مكتمل',
              style: AppTextStyles.caption.copyWith(fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> showProfileSheet(BuildContext context) {
  final state = AppScope.of(context, listen: false);
  var notifications = true;
  return showAppSheet(
    context: context,
    heightFactor: 0.84,
    child: StatefulBuilder(
      builder: (sheetContext, setSheetState) {
        return ListView(
          padding: EdgeInsets.zero,
          children: [
            const SizedBox(height: 10),
            const Center(child: SheetHandle()),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Row(
                children: [
                  Text('حسابي', style: AppTextStyles.headline),
                  const Spacer(),
                  SoftIconButton(
                    icon: Icons.settings_outlined,
                    size: 38,
                    iconSize: 18,
                    shadow: false,
                    background: AppColors.inkSoft,
                    onTap: () => showAppSnackBar(
                      sheetContext,
                      'الإعدادات متاحة في النسخة الكاملة',
                      icon: Icons.settings_outlined,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.charcoal, AppColors.darkSoft],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary,
                          ),
                          child: ClipOval(
                            child: AppImage(
                              appUser.avatar,
                              width: 54,
                              height: 54,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                appUser.name,
                                style: AppTextStyles.title.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                appUser.phone,
                                style: AppTextStyles.caption.copyWith(
                                  color: Colors.white.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.diamond_rounded,
                                size: 12,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'ذهبي',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.primary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          _ProfileStat(value: '٢٤', label: 'طلب'),
                          _ProfileDivider(),
                          _ProfileStat(value: '٤.٩', label: 'تقييم'),
                          _ProfileDivider(),
                          _ProfileStat(value: '٣', label: 'عناوين'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Column(
                children: [
                  _ProfileTile(
                    icon: Icons.location_on_outlined,
                    title: 'العناوين المحفوظة',
                    subtitle: state.addressLabel,
                    onTap: () {
                      Navigator.pop(sheetContext);
                      showAddressPicker(context);
                    },
                  ),
                  _ProfileTile(
                    icon: Icons.credit_card_rounded,
                    title: 'طرق الدفع',
                    subtitle: state.paymentLabel,
                    onTap: () {
                      Navigator.pop(sheetContext);
                      showPaymentPicker(context);
                    },
                  ),
                  _ProfileTile(
                    icon: Icons.local_offer_outlined,
                    title: 'العروض والقسائم',
                    subtitle: '٣ عروض متاحة',
                    accent: true,
                    onTap: () => showAppSnackBar(
                      sheetContext,
                      'لديك ٣ عروض متاحة قريباً',
                      icon: Icons.local_offer_rounded,
                    ),
                  ),
                  _ProfileTile(
                    icon: Icons.notifications_none_rounded,
                    title: 'الإشعارات',
                    trailing: Switch.adaptive(
                      value: notifications,
                      activeThumbColor: Colors.white,
                      activeTrackColor: AppColors.primary,
                      onChanged: (value) {
                        setSheetState(() => notifications = value);
                      },
                    ),
                  ),
                  _ProfileTile(
                    icon: Icons.help_outline_rounded,
                    title: 'المساعدة والدعم',
                    onTap: () => showAppSnackBar(
                      sheetContext,
                      'فريق الدعم متاح على مدار الساعة',
                      icon: Icons.support_agent_rounded,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () => showAppSnackBar(
                      sheetContext,
                      'تم تسجيل الخروج من الحساب التجريبي',
                      icon: Icons.logout_rounded,
                    ),
                    icon: const Icon(
                      Icons.logout_rounded,
                      size: 18,
                      color: AppColors.danger,
                    ),
                    label: Text(
                      'تسجيل الخروج',
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.danger,
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.paddingOf(sheetContext).bottom),
                ],
              ),
            ),
          ],
        );
      },
    ),
  );
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: AppTextStyles.title.copyWith(color: Colors.white)),
          const SizedBox(height: 1),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: Colors.white.withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 28,
      color: Colors.white.withValues(alpha: 0.1),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.accent = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: accent ? AppColors.primarySoft : AppColors.inkSoft,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  icon,
                  size: 19,
                  color: accent ? AppColors.primaryDark : AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.titleSmall),
                    if (subtitle != null) ...[
                      const SizedBox(height: 1),
                      Text(subtitle!, style: AppTextStyles.caption),
                    ],
                  ],
                ),
              ),
              trailing ??
                  const Icon(
                    Icons.arrow_back_rounded,
                    size: 18,
                    color: AppColors.textTertiary,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
