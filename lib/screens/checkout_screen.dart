import 'package:flutter/material.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/app_sheets.dart';
import '../widgets/ui.dart';
import 'tracking_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final TextEditingController _promoController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();
  bool _promoError = false;
  bool _submitting = false;

  @override
  void dispose() {
    _promoController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder(AppState state) async {
    if (state.isCartEmpty) {
      showAppSnackBar(
        context,
        'سلتك فارغة، أضف طبقاً أولاً',
        icon: Icons.shopping_bag_outlined,
      );
      return;
    }
    if (state.address.trim().isEmpty) {
      showAppSnackBar(
        context,
        'أضف عنوان التوصيل قبل تأكيد الطلب',
        icon: Icons.location_off_outlined,
      );
      return;
    }

    setState(() => _submitting = true);
    await Future<void>.delayed(const Duration(milliseconds: 950));
    if (!mounted) return;
    state.placeOrder();
    Navigator.of(context).pushAndRemoveUntil(
      premiumRoute(const TrackingScreen()),
      (route) => route.isFirst,
    );
  }

  void _applyPromo(AppState state) {
    final success = state.applyPromo(_promoController.text);
    setState(() => _promoError = !success);
    if (success) {
      FocusScope.of(context).unfocus();
      showAppSnackBar(
        context,
        'تم تطبيق خصم ٢٠٪ على طلبك',
        icon: Icons.local_offer_rounded,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final restaurant = state.cartRestaurant;
    final empty = state.isCartEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  SoftIconButton(
                    icon: Icons.arrow_forward_rounded,
                    onTap: () => Navigator.pop(context),
                    size: 42,
                    iconSize: 19,
                    shadow: false,
                    background: AppColors.surface,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('السلة والدفع', style: AppTextStyles.headline),
                        Text(
                          'خطوة واحدة تفصلك عن وجبتك',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                  if (!empty)
                    TextButton(
                      onPressed: () {
                        showDialog<void>(
                          context: context,
                          builder: (dialogContext) {
                            return AlertDialog(
                              backgroundColor: AppColors.surface,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              title: Text(
                                'تفريغ السلة؟',
                                style: AppTextStyles.title,
                              ),
                              content: Text(
                                'سيتم حذف جميع الأصناف من سلتك الحالية.',
                                style: AppTextStyles.bodySmall,
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(dialogContext),
                                  child: const Text('إلغاء'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    for (final line in List<CartLine>.from(
                                      state.cart,
                                    )) {
                                      state.removeLine(line.lineId);
                                    }
                                    Navigator.pop(dialogContext);
                                  },
                                  child: Text(
                                    'تفريغ',
                                    style: AppTextStyles.label.copyWith(
                                      color: AppColors.danger,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Text(
                        'تفريغ',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const _CheckoutProgress(),
            const SizedBox(height: 16),
            Expanded(
              child: empty
                  ? _EmptyCart(onBack: () => Navigator.pop(context))
                  : SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (restaurant != null)
                            _RestaurantStrip(
                              restaurant: restaurant,
                              itemCount: state.cartCount,
                              onAddMore: () => Navigator.pop(context),
                            ),
                          const SizedBox(height: 14),
                          ...state.cart.map(
                            (line) => Padding(
                              padding: const EdgeInsets.only(bottom: 9),
                              child: _CartLineCard(
                                line: line,
                                onQuantity: (value) =>
                                    state.updateQuantity(line.lineId, value),
                                onRemove: () => state.removeLine(line.lineId),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          _PromoSection(
                            controller: _promoController,
                            applied: state.promoApplied,
                            error: _promoError,
                            code: state.promoCode,
                            onApply: () => _applyPromo(state),
                            onRemove: () {
                              state.removePromo();
                              _promoController.clear();
                              setState(() => _promoError = false);
                            },
                          ),
                          const SizedBox(height: 20),
                          _SectionLabel(
                            title: 'التوصيل',
                            icon: Icons.location_on_outlined,
                          ),
                          const SizedBox(height: 9),
                          _DeliveryAddressCard(
                            label: state.addressLabel,
                            address: state.address,
                            onChange: () => showAddressPicker(context),
                          ),
                          const SizedBox(height: 10),
                          _DeliveryInstructions(
                            controller: _instructionsController,
                          ),
                          const SizedBox(height: 20),
                          _SectionLabel(
                            title: 'الدفع',
                            icon: Icons.credit_card_rounded,
                          ),
                          const SizedBox(height: 9),
                          _PaymentMethodCard(
                            paymentLabel: state.paymentLabel,
                            method: state.paymentMethod,
                            onChange: () => showPaymentPicker(context),
                          ),
                          const SizedBox(height: 20),
                          _SectionLabel(
                            title: 'ملخص الطلب',
                            icon: Icons.receipt_long_outlined,
                          ),
                          const SizedBox(height: 9),
                          _OrderSummary(state: state),
                          const SizedBox(height: 10),
                          Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.lock_outline_rounded,
                                  size: 13,
                                  color: AppColors.textTertiary,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  'دفع آمن ومشفّر بالكامل',
                                  style: AppTextStyles.caption.copyWith(
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            if (!empty)
              _CheckoutBottomBar(
                total: state.total,
                submitting: _submitting,
                onPlaceOrder: () => _placeOrder(state),
              ),
          ],
        ),
      ),
    );
  }
}

class _CheckoutProgress extends StatelessWidget {
  const _CheckoutProgress();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Row(
        children: [
          _ProgressStep(label: 'السلة', state: 1),
          Expanded(child: _ProgressLine(completed: true)),
          _ProgressStep(label: 'الدفع', state: 0),
          Expanded(child: _ProgressLine(completed: false)),
          _ProgressStep(label: 'التتبع', state: -1),
        ],
      ),
    );
  }
}

class _ProgressStep extends StatelessWidget {
  const _ProgressStep({required this.label, required this.state});

  final String label;
  final int state;

  @override
  Widget build(BuildContext context) {
    final active = state == 0;
    final completed = state == 1;
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: active ? 24 : 21,
          height: active ? 24 : 21,
          decoration: BoxDecoration(
            color: completed
                ? AppColors.primarySoft
                : active
                ? AppColors.primary
                : AppColors.surface,
            shape: BoxShape.circle,
            border: Border.all(
              color: completed || active ? AppColors.primary : AppColors.border,
              width: 1.4,
            ),
          ),
          child: Center(
            child: completed
                ? const Icon(
                    Icons.check_rounded,
                    color: AppColors.primaryDark,
                    size: 13,
                  )
                : active
                ? Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  )
                : Text('٣', style: AppTextStyles.caption.copyWith(fontSize: 9)),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: active || completed
                ? AppColors.textPrimary
                : AppColors.textTertiary,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            fontSize: 9.5,
          ),
        ),
      ],
    );
  }
}

class _ProgressLine extends StatelessWidget {
  const _ProgressLine({required this.completed});

  final bool completed;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 2,
      margin: const EdgeInsets.only(bottom: 18),
      color: completed ? AppColors.primary : AppColors.border,
    );
  }
}

class _RestaurantStrip extends StatelessWidget {
  const _RestaurantStrip({
    required this.restaurant,
    required this.itemCount,
    required this.onAddMore,
  });

  final Restaurant restaurant;
  final int itemCount;
  final VoidCallback onAddMore;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          AppImage(restaurant.logo, width: 44, height: 44, radius: 13),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(restaurant.name, style: AppTextStyles.titleSmall),
                const SizedBox(height: 1),
                Text(
                  '$itemCount أصناف · ${restaurant.deliveryTime}',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          InkWell(
            onTap: onAddMore,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.add_rounded,
                    size: 14,
                    color: AppColors.primaryDark,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    'المزيد',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
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

class _CartLineCard extends StatelessWidget {
  const _CartLineCard({
    required this.line,
    required this.onQuantity,
    required this.onRemove,
  });

  final CartLine line;
  final ValueChanged<int> onQuantity;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppImage(line.item.image, width: 70, height: 70, radius: 15),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            line.item.name,
                            style: AppTextStyles.titleSmall.copyWith(
                              fontSize: 13.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          money(line.total),
                          style: AppTextStyles.price.copyWith(fontSize: 13.5),
                        ),
                      ],
                    ),
                    if (line.optionsLabel.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        line.optionsLabel,
                        style: AppTextStyles.caption.copyWith(fontSize: 10),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (line.note.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        'ملاحظة: ${line.note}',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primaryDark,
                          fontSize: 9.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              QuantityStepper(
                value: line.quantity,
                onChanged: onQuantity,
                compact: true,
              ),
              const Spacer(),
              InkWell(
                onTap: onRemove,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.inkSoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.delete_outline_rounded,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'إزالة',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 9.5,
                        ),
                      ),
                    ],
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

class _PromoSection extends StatelessWidget {
  const _PromoSection({
    required this.controller,
    required this.applied,
    required this.error,
    required this.code,
    required this.onApply,
    required this.onRemove,
  });

  final TextEditingController controller;
  final bool applied;
  final bool error;
  final String? code;
  final VoidCallback onApply;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    if (applied) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.22)),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.local_offer_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'تم تطبيق كود $code',
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.primaryDark,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    'خصم ٢٠٪ على قيمة الطلب',
                    style: AppTextStyles.caption.copyWith(fontSize: 10),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: onRemove,
              child: Text(
                'إزالة',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.inkSoft,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.confirmation_number_outlined,
                  size: 17,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: TextField(
                  controller: controller,
                  textCapitalization: TextCapitalization.characters,
                  style: AppTextStyles.label.copyWith(fontSize: 12.5),
                  decoration: const InputDecoration(
                    hintText: 'أدخل كود الخصم',
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                    hintStyle: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontSize: 12,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
              ),
              FilledButton(
                onPressed: onApply,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 38),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  backgroundColor: AppColors.charcoal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                ),
                child: Text(
                  'تطبيق',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 10.5,
                  ),
                ),
              ),
            ],
          ),
          if (error) ...[
            const SizedBox(height: 7),
            Text(
              'هذا الكود غير صحيح. جرّب SULTAN15',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.danger,
                fontSize: 10,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 17, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Text(title, style: AppTextStyles.title),
      ],
    );
  }
}

class _DeliveryAddressCard extends StatelessWidget {
  const _DeliveryAddressCard({
    required this.label,
    required this.address,
    required this.onChange,
  });

  final String label;
  final String address;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.location_on_rounded,
              size: 20,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(label, style: AppTextStyles.titleSmall),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        'الافتراضي',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primaryDark,
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  address,
                  style: AppTextStyles.caption.copyWith(fontSize: 10.5),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onChange,
            child: Text(
              'تغيير',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.primaryDark,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeliveryInstructions extends StatelessWidget {
  const _DeliveryInstructions({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(
              Icons.sticky_note_2_outlined,
              size: 17,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              maxLines: 2,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textPrimary,
                fontSize: 12,
              ),
              decoration: const InputDecoration(
                hintText: 'تعليمات التوصيل؟ مثال: اتركه عند الباب',
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
                hintStyle: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontSize: 11.5,
                  color: AppColors.textTertiary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  const _PaymentMethodCard({
    required this.paymentLabel,
    required this.method,
    required this.onChange,
  });

  final String paymentLabel;
  final String method;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    final icon = switch (method) {
      'apple' => Icons.phone_iphone_rounded,
      'cash' => Icons.payments_outlined,
      _ => Icons.credit_card_rounded,
    };
    return InkWell(
      onTap: onChange,
      borderRadius: BorderRadius.circular(19),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(19),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.inkSoft,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, size: 20, color: AppColors.textPrimary),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('طريقة الدفع', style: AppTextStyles.titleSmall),
                  const SizedBox(height: 2),
                  Text(paymentLabel, style: AppTextStyles.caption),
                ],
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_left_rounded,
              size: 21,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderSummary extends StatelessWidget {
  const _OrderSummary({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _SummaryRow(
            label: 'المجموع الفرعي',
            value: money(state.subtotal, decimals: true),
          ),
          const SizedBox(height: 9),
          _SummaryRow(
            label: 'رسوم التوصيل',
            value: state.deliveryFee == 0
                ? 'مجاني'
                : money(state.deliveryFee, decimals: true),
            valueColor: state.deliveryFee == 0
                ? AppColors.primaryDark
                : AppColors.textPrimary,
          ),
          if (state.promoApplied) ...[
            const SizedBox(height: 9),
            _SummaryRow(
              label: 'الخصم (${state.promoCode == 'SULTAN15' ? '١٥٪' : '٢٠٪'})',
              value: '- ${money(state.discount, decimals: true)}',
              valueColor: AppColors.primaryDark,
            ),
          ],
          const SizedBox(height: 12),
          const DividerLine(),
          const SizedBox(height: 12),
          Row(
            children: [
              Text('الإجمالي', style: AppTextStyles.title),
              const Spacer(),
              Text(
                money(state.total, decimals: true),
                style: AppTextStyles.price.copyWith(
                  fontSize: 18,
                  color: AppColors.primaryDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'شامل ضريبة القيمة المضافة',
              style: AppTextStyles.caption.copyWith(fontSize: 9.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor = AppColors.textPrimary,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: AppTextStyles.bodySmall.copyWith(fontSize: 12)),
        const Spacer(),
        Text(
          value,
          style: AppTextStyles.label.copyWith(color: valueColor, fontSize: 12),
        ),
      ],
    );
  }
}

class _CheckoutBottomBar extends StatelessWidget {
  const _CheckoutBottomBar({
    required this.total,
    required this.submitting,
    required this.onPlaceOrder,
  });

  final double total;
  final bool submitting;
  final VoidCallback onPlaceOrder;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'الإجمالي',
                style: AppTextStyles.caption.copyWith(fontSize: 10),
              ),
              const SizedBox(height: 1),
              Text(
                money(total, decimals: true),
                style: AppTextStyles.price.copyWith(fontSize: 16),
              ),
            ],
          ),
          const SizedBox(width: 15),
          Expanded(
            child: FilledButton(
              onPressed: submitting ? null : onPlaceOrder,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: submitting
                    ? const SizedBox(
                        key: ValueKey('loading'),
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        key: const ValueKey('ready'),
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.lock_outline_rounded, size: 17),
                          const SizedBox(width: 7),
                          const Text('تأكيد الطلب'),
                          const SizedBox(width: 6),
                          Container(
                            width: 1,
                            height: 15,
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            money(total),
                            style: AppTextStyles.label.copyWith(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 92,
              height: 92,
              decoration: const BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                size: 38,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 18),
            Text('سلتك فارغة', style: AppTextStyles.headline),
            const SizedBox(height: 6),
            Text(
              'أضف أطباقك المفضلة من القائمة\nوسنوصلها إليك ساخنة.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(height: 1.7),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: onBack,
              child: const Text('العودة إلى القائمة'),
            ),
          ],
        ),
      ),
    );
  }
}
