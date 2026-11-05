import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/ui.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  static const _statuses = [
    (
      title: 'تم تأكيد الطلب',
      subtitle: 'استلمنا طلبك وأرسلناه إلى المطعم',
      icon: Icons.check_rounded,
    ),
    (
      title: 'المطعم يحضّر طلبك',
      subtitle: 'فريق المطبخ يعمل على طلبك الآن',
      icon: Icons.restaurant_rounded,
    ),
    (
      title: 'السائق في الطريق إلى المطعم',
      subtitle: 'عبدالله في طريقه لاستلام طلبك',
      icon: Icons.two_wheeler_rounded,
    ),
    (
      title: 'استلم السائق طلبك',
      subtitle: 'طلبك في الطريق إليك الآن',
      icon: Icons.shopping_bag_rounded,
    ),
    (
      title: 'السائق يقترب منك',
      subtitle: 'على بعد دقائق من عنوان التوصيل',
      icon: Icons.near_me_rounded,
    ),
    (
      title: 'تم توصيل الطلب',
      subtitle: 'شهية طيبة! نتمنى أن تنال وجبتك إعجابك',
      icon: Icons.home_rounded,
    ),
  ];

  static const _remaining = [18, 16, 13, 9, 4, 0];

  Timer? _timer;
  int _currentStep = 2;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 6), (timer) {
      if (!mounted) return;
      if (_currentStep >= _statuses.length - 1) {
        timer.cancel();
        return;
      }
      setState(() => _currentStep += 1);
      if (_currentStep == _statuses.length - 1) {
        AppScope.of(context, listen: false).markOrderDelivered();
        timer.cancel();
      }
    });
  }

  double _progressTarget(int step) {
    return switch (step) {
      0 => 0.05,
      1 => 0.08,
      2 => 0.28,
      3 => 0.54,
      4 => 0.82,
      _ => 1.0,
    };
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final fallbackLine = CartLine(
      lineId: 'demo',
      item: restaurants.first.menu.first,
      restaurantId: restaurants.first.id,
    );
    final order =
        state.activeOrder ??
        PlacedOrder(
          number: 'LQ-24871',
          restaurant: restaurants.first,
          lines: [fallbackLine],
          address: state.address,
          total: 43,
          placedAt: DateTime.now(),
        );
    final delivered = _currentStep >= _statuses.length - 1;
    final remaining = _remaining[_currentStep];

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final sheetHeight = constraints.maxHeight * 0.575;
          return Stack(
            children: [
              Positioned.fill(
                child: _LiveMap(
                  progress: _progressTarget(_currentStep),
                  delivered: delivered,
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
                          size: 43,
                          iconSize: 19,
                          tooltip: 'رجوع',
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.charcoal,
                            borderRadius: BorderRadius.circular(999),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.13),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const _PulseDot(size: 7),
                              const SizedBox(width: 7),
                              Text(
                                delivered ? 'تم التوصيل' : 'تتبع مباشر',
                                style: AppTextStyles.caption.copyWith(
                                  color: Colors.white,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        SoftIconButton(
                          icon: Icons.support_agent_rounded,
                          onTap: () => _showSupport(context),
                          size: 43,
                          iconSize: 19,
                          tooltip: 'المساعدة',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (!delivered)
                Positioned(
                  top: MediaQuery.paddingOf(context).top + 76,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.94),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.07),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.navigation_rounded,
                          size: 13,
                          color: AppColors.primaryDark,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'يصل خلال $remaining دقيقة',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textPrimary,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: sheetHeight,
                child: _TrackingSheet(
                  order: order,
                  currentStep: _currentStep,
                  delivered: delivered,
                  remainingMinutes: remaining,
                  statuses: _statuses,
                  onCall: () => _showCallDialog(context, order),
                  onMessage: () => _showMessageSheet(context),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showCallDialog(BuildContext context, PlacedOrder order) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 76,
                  height: 76,
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: AppColors.primarySoft,
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(child: AppImage('assets/images/driver.jpg')),
                ),
                const SizedBox(height: 12),
                Text('عبدالله الحربي', style: AppTextStyles.title),
                const SizedBox(height: 3),
                Text(
                  'سائق طلبك · ${order.number}',
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.inkSoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.phone_outlined,
                        size: 16,
                        color: AppColors.textPrimary,
                      ),
                      const SizedBox(width: 7),
                      Text(
                        '٠٥٥ ٩٤٢ ١٨٨',
                        style: AppTextStyles.label.copyWith(fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 50),
                          side: const BorderSide(color: AppColors.border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          foregroundColor: AppColors.textPrimary,
                        ),
                        child: const Text('إلغاء'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: FilledButton.icon(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          showAppSnackBar(
                            context,
                            'جارٍ الاتصال بعبدالله...',
                            icon: Icons.phone_rounded,
                          );
                        },
                        icon: const Icon(Icons.phone_rounded, size: 17),
                        label: const Text('اتصال'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showMessageSheet(BuildContext context) {
    showAppSheet(
      context: context,
      heightFactor: 0.58,
      child: _MessageSheet(
        onSend: (message) {
          Navigator.pop(context);
          showAppSnackBar(
            context,
            'تم إرسال رسالتك إلى عبدالله',
            icon: Icons.chat_bubble_rounded,
          );
        },
      ),
    );
  }

  void _showSupport(BuildContext context) {
    showAppSheet(
      context: context,
      heightFactor: 0.52,
      child: Column(
        children: [
          const SizedBox(height: 10),
          const Center(child: SheetHandle()),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'كيف يمكننا مساعدتك؟',
                    style: AppTextStyles.headline,
                  ),
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
                _SupportTile(
                  icon: Icons.chat_bubble_outline_rounded,
                  title: 'الدردشة مع الدعم',
                  subtitle: 'متاحون على مدار الساعة',
                  onTap: () => showAppSnackBar(
                    context,
                    'جارٍ فتح محادثة الدعم...',
                    icon: Icons.chat_bubble_rounded,
                  ),
                ),
                const SizedBox(height: 9),
                _SupportTile(
                  icon: Icons.report_gmailerrorred_rounded,
                  title: 'مشكلة في الطلب',
                  subtitle: 'نعتذر، دعنا نصلح ذلك فوراً',
                  onTap: () => showAppSnackBar(
                    context,
                    'تم إنشاء تذكرة دعم بخصوص طلبك',
                    icon: Icons.support_agent_rounded,
                  ),
                ),
                const SizedBox(height: 9),
                _SupportTile(
                  icon: Icons.phone_in_talk_outlined,
                  title: 'اتصال هاتفي',
                  subtitle: 'للحالات العاجلة فقط',
                  onTap: () => showAppSnackBar(
                    context,
                    'خط الدعم: ٩٢٠٠ ١٢٣ ٤٥',
                    icon: Icons.phone_rounded,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TrackingSheet extends StatelessWidget {
  const _TrackingSheet({
    required this.order,
    required this.currentStep,
    required this.delivered,
    required this.remainingMinutes,
    required this.statuses,
    required this.onCall,
    required this.onMessage,
  });

  final PlacedOrder order;
  final int currentStep;
  final bool delivered;
  final int remainingMinutes;
  final List<({IconData icon, String subtitle, String title})> statuses;
  final VoidCallback onCall;
  final VoidCallback onMessage;

  @override
  Widget build(BuildContext context) {
    final current = statuses[currentStep];
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 34,
            offset: const Offset(0, -12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        child: Column(
          children: [
            const SizedBox(height: 9),
            const SheetHandle(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
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
                              Row(
                                children: [
                                  Text(
                                    'الطلب #${order.number}',
                                    style: AppTextStyles.caption.copyWith(
                                      fontSize: 10.5,
                                    ),
                                  ),
                                  const SizedBox(width: 7),
                                  const InfoDot(),
                                  const SizedBox(width: 7),
                                  Text(
                                    delivered ? 'مكتمل' : 'مباشر',
                                    style: AppTextStyles.caption.copyWith(
                                      color: delivered
                                          ? AppColors.textTertiary
                                          : AppColors.primaryDark,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                delivered
                                    ? 'تم توصيل طلبك'
                                    : current.title.replaceFirst(
                                        'السائق ',
                                        'عبدالله ',
                                      ),
                                style: AppTextStyles.headline.copyWith(
                                  fontSize: 20,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                current.subtitle,
                                style: AppTextStyles.caption,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: delivered
                                ? AppColors.primarySoft
                                : AppColors.charcoal,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                delivered
                                    ? Icons.check_circle_rounded
                                    : Icons.timer_outlined,
                                color: delivered
                                    ? AppColors.primaryDark
                                    : AppColors.primary,
                                size: 18,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                delivered ? 'تم' : '$remainingMinutes دقيقة',
                                style: AppTextStyles.label.copyWith(
                                  color: delivered
                                      ? AppColors.primaryDark
                                      : Colors.white,
                                  fontSize: 11.5,
                                ),
                              ),
                              Text(
                                delivered ? 'التوصيل' : 'متبقية',
                                style: AppTextStyles.caption.copyWith(
                                  color: delivered
                                      ? AppColors.textTertiary
                                      : Colors.white.withValues(alpha: 0.55),
                                  fontSize: 9,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _DriverCard(
                      onCall: onCall,
                      onMessage: onMessage,
                      delivered: delivered,
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Text('حالة الطلب', style: AppTextStyles.title),
                        const Spacer(),
                        if (!delivered)
                          Row(
                            children: [
                              const _PulseDot(size: 6),
                              const SizedBox(width: 5),
                              Text(
                                'يتحدّث تلقائياً',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textTertiary,
                                  fontSize: 9.5,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ...List.generate(statuses.length, (index) {
                      return _TimelineStep(
                        title: statuses[index].title,
                        subtitle: statuses[index].subtitle,
                        state: index < currentStep
                            ? _StepState.completed
                            : index == currentStep
                            ? _StepState.active
                            : _StepState.upcoming,
                        isLast: index == statuses.length - 1,
                      );
                    }),
                    const SizedBox(height: 16),
                    _OrderInfoCard(order: order, delivered: delivered),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _StepState { completed, active, upcoming }

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({
    required this.title,
    required this.subtitle,
    required this.state,
    required this.isLast,
  });

  final String title;
  final String subtitle;
  final _StepState state;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final active = state == _StepState.active;
    final completed = state == _StepState.completed;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                const SizedBox(height: 4),
                if (active)
                  const _PulseDot(size: 16, solid: true)
                else
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: completed ? 18 : 16,
                    height: completed ? 18 : 16,
                    decoration: BoxDecoration(
                      color: completed ? AppColors.primary : AppColors.surface,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: completed
                            ? AppColors.primary
                            : AppColors.textTertiary,
                        width: 1.3,
                      ),
                    ),
                    child: completed
                        ? const Icon(
                            Icons.check_rounded,
                            size: 12,
                            color: Colors.white,
                          )
                        : null,
                  ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 3),
                      color: completed
                          ? AppColors.primary.withValues(alpha: 0.45)
                          : AppColors.border,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 3 : 13),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.label.copyWith(
                      color: active
                          ? AppColors.primaryDark
                          : completed
                          ? AppColors.textPrimary
                          : AppColors.textTertiary,
                      fontSize: 12,
                    ),
                  ),
                  if (active) ...[
                    const SizedBox(height: 1),
                    Text(
                      subtitle,
                      style: AppTextStyles.caption.copyWith(fontSize: 9.5),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DriverCard extends StatelessWidget {
  const _DriverCard({
    required this.onCall,
    required this.onMessage,
    required this.delivered,
  });

  final VoidCallback onCall;
  final VoidCallback onMessage;
  final bool delivered;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.inkSoft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: AppImage(
                    'assets/images/driver.jpg',
                    width: 50,
                    height: 50,
                  ),
                ),
              ),
              Positioned(
                bottom: -2,
                left: -2,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppColors.charcoal,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.inkSoft, width: 2),
                  ),
                  child: const Icon(
                    Icons.two_wheeler_rounded,
                    color: AppColors.primary,
                    size: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'عبدالله الحربي',
                      style: AppTextStyles.titleSmall.copyWith(fontSize: 13),
                    ),
                    const SizedBox(width: 5),
                    const Icon(
                      Icons.verified_rounded,
                      size: 13,
                      color: AppColors.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 1),
                Text(
                  'دراجة هوائية · ٢٤٥٦ ح ب',
                  style: AppTextStyles.caption.copyWith(fontSize: 9.5),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: AppColors.amber,
                      size: 13,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '٤.٩',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '· ١٢٤٠ توصيل',
                      style: AppTextStyles.caption.copyWith(fontSize: 9),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _DriverAction(
            icon: Icons.chat_bubble_outline_rounded,
            onTap: onMessage,
          ),
          const SizedBox(width: 7),
          _DriverAction(
            icon: Icons.phone_outlined,
            onTap: onCall,
            filled: true,
          ),
        ],
      ),
    );
  }
}

class _DriverAction extends StatelessWidget {
  const _DriverAction({
    required this.icon,
    required this.onTap,
    this.filled = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: filled ? AppColors.primary : AppColors.surface,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 38,
          height: 38,
          child: Icon(
            icon,
            size: 17,
            color: filled ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _OrderInfoCard extends StatelessWidget {
  const _OrderInfoCard({required this.order, required this.delivered});

  final PlacedOrder order;
  final bool delivered;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('تفاصيل الطلب', style: AppTextStyles.titleSmall),
              const Spacer(),
              Text(
                delivered ? 'تم التسليم' : 'الوصول المتوقع ٢٠:٤٥',
                style: AppTextStyles.caption.copyWith(
                  color: delivered
                      ? AppColors.primaryDark
                      : AppColors.textTertiary,
                  fontSize: 9.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          Row(
            children: [
              AppImage(
                order.restaurant.logo,
                width: 40,
                height: 40,
                radius: 12,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.restaurant.name,
                      style: AppTextStyles.label.copyWith(fontSize: 12),
                    ),
                    Text(
                      '${order.itemCount} أصناف · ${order.number}',
                      style: AppTextStyles.caption.copyWith(fontSize: 9.5),
                    ),
                  ],
                ),
              ),
              Text(
                money(order.total, decimals: true),
                style: AppTextStyles.price.copyWith(fontSize: 12.5),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (order.lines.isNotEmpty)
            ...order.lines
                .take(2)
                .map(
                  (line) => Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Row(
                      children: [
                        Text(
                          '${line.quantity}×',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.w700,
                            fontSize: 9.5,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            line.item.name,
                            style: AppTextStyles.caption.copyWith(
                              fontSize: 9.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          const DividerLine(),
          const SizedBox(height: 9),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 14,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  order.address,
                  style: AppTextStyles.caption.copyWith(fontSize: 9.5),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PulseDot extends StatefulWidget {
  const _PulseDot({required this.size, this.solid = false});

  final double size;
  final bool solid;

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
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final value = _controller.value;
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: widget.size * (0.6 + value * 0.6),
                height: widget.size * (0.6 + value * 0.6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(
                    alpha: 0.25 * (1 - value),
                  ),
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: widget.size * 0.55,
                height: widget.size * 0.55,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              if (widget.solid)
                const Icon(
                  Icons.two_wheeler_rounded,
                  size: 11,
                  color: Colors.white,
                ),
            ],
          ),
        );
      },
    );
  }
}

class _LiveMap extends StatefulWidget {
  const _LiveMap({required this.progress, required this.delivered});

  final double progress;
  final bool delivered;

  @override
  State<_LiveMap> createState() => _LiveMapState();
}

class _LiveMapState extends State<_LiveMap>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
      value: widget.progress,
    );
  }

  @override
  void didUpdateWidget(covariant _LiveMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _controller.animateTo(
        widget.progress,
        duration: const Duration(milliseconds: 1700),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final path = _buildRoutePath(size);
        final metric = path.computeMetrics().first;
        final start = metric.getTangentForOffset(0)?.position ?? Offset.zero;
        final end =
            metric.getTangentForOffset(metric.length)?.position ?? Offset.zero;
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final driver =
                metric
                    .getTangentForOffset(metric.length * _controller.value)
                    ?.position ??
                start;
            return Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _MapPainter(
                      progress: _controller.value,
                      delivered: widget.delivered,
                    ),
                  ),
                ),
                Positioned(
                  left: start.dx - 55,
                  top: start.dy - 24,
                  width: 110,
                  child: _MapMarker(
                    icon: Icons.restaurant_rounded,
                    label: 'برجر لاب',
                    color: AppColors.primary,
                  ),
                ),
                Positioned(
                  left: end.dx - 55,
                  top: end.dy - 24,
                  width: 110,
                  child: _MapMarker(
                    icon: Icons.home_rounded,
                    label: 'المنزل',
                    color: AppColors.charcoal,
                    iconOnDark: true,
                  ),
                ),
                Positioned(
                  left: driver.dx - 25,
                  top: driver.dy - 25,
                  child: _DriverMarker(delivered: widget.delivered),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _MapMarker extends StatelessWidget {
  const _MapMarker({
    required this.icon,
    required this.label,
    required this.color,
    this.iconOnDark = false,
  });

  final IconData icon;
  final String label;
  final Color color;
  final bool iconOnDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 19),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 9,
            ),
          ),
        ),
      ],
    );
  }
}

class _DriverMarker extends StatelessWidget {
  const _DriverMarker({required this.delivered});

  final bool delivered;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipOval(
        child: Stack(
          fit: StackFit.expand,
          children: [
            const AppImage('assets/images/driver.jpg'),
            Container(
              color: delivered
                  ? Colors.transparent
                  : AppColors.charcoal.withValues(alpha: 0.16),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 2),
                color: AppColors.charcoal.withValues(alpha: 0.7),
                child: const Icon(
                  Icons.two_wheeler_rounded,
                  color: Colors.white,
                  size: 9,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  _MapPainter({required this.progress, required this.delivered});

  final double progress;
  final bool delivered;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..color = const Color(0xFFEEF1E8));

    final blockPaint = Paint()..color = const Color(0xFFF8F5EE);
    final blockBorder = Paint()
      ..color = const Color(0xFFE4E4DC)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final parkPaint = Paint()..color = const Color(0xFFD7E9CF);
    final waterPaint = Paint()..color = const Color(0xFFDCEBF0);

    final water = Path()
      ..moveTo(-20, size.height * 0.02)
      ..quadraticBezierTo(
        size.width * 0.13,
        size.height * 0.05,
        size.width * 0.12,
        size.height * 0.15,
      )
      ..quadraticBezierTo(
        size.width * 0.1,
        size.height * 0.22,
        -20,
        size.height * 0.2,
      )
      ..close();
    canvas.drawPath(water, waterPaint);

    final park = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.63,
        size.height * 0.05,
        size.width * 0.29,
        size.height * 0.13,
      ),
      const Radius.circular(18),
    );
    canvas.drawRRect(park, parkPaint);

    final smallPark = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.04,
        size.height * 0.31,
        size.width * 0.17,
        size.height * 0.1,
      ),
      const Radius.circular(13),
    );
    canvas.drawRRect(smallPark, parkPaint);

    final random = math.Random(14);
    for (var row = 0; row < 5; row++) {
      for (var column = 0; column < 5; column++) {
        if (row == 0 && column < 2) continue;
        if (row == 1 && column == 3) continue;
        final w = size.width / 5 - 14;
        final h = size.height * 0.085 - 7 + random.nextDouble() * 5;
        final left = column * (size.width / 5) + 7;
        final top = row * (size.height * 0.085) + 40;
        final block = RRect.fromRectAndRadius(
          Rect.fromLTWH(left, top, w, h),
          const Radius.circular(5),
        );
        canvas.drawRRect(block, blockPaint);
        canvas.drawRRect(block, blockBorder);
      }
    }

    final roadBorder = Paint()
      ..color = const Color(0xFFE0E1D9)
      ..strokeWidth = 22
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final road = Paint()
      ..color = const Color(0xFFFAFAF6)
      ..strokeWidth = 17
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final roads = <Path>[
      Path()
        ..moveTo(0, size.height * 0.205)
        ..lineTo(size.width, size.height * 0.18),
      Path()
        ..moveTo(0, size.height * 0.365)
        ..lineTo(size.width, size.height * 0.34),
      Path()
        ..moveTo(size.width * 0.24, 0)
        ..lineTo(size.width * 0.22, size.height * 0.55),
      Path()
        ..moveTo(size.width * 0.54, 0)
        ..lineTo(size.width * 0.52, size.height * 0.55),
      Path()
        ..moveTo(size.width * 0.83, 0)
        ..lineTo(size.width * 0.84, size.height * 0.55),
      Path()
        ..moveTo(-20, size.height * 0.5)
        ..quadraticBezierTo(
          size.width * 0.3,
          size.height * 0.35,
          size.width + 20,
          size.height * 0.46,
        ),
    ];

    for (final path in roads) {
      canvas.drawPath(path, roadBorder);
      canvas.drawPath(path, road);
    }

    final route = _buildRoutePath(size);
    canvas.drawPath(
      route,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.08)
        ..strokeWidth = 15
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );
    canvas.drawPath(
      route,
      Paint()
        ..color = Colors.white
        ..strokeWidth = 11
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );
    canvas.drawPath(
      route,
      Paint()
        ..color = const Color(0xFFB9E7CC)
        ..strokeWidth = 5.5
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );
    final metric = route.computeMetrics().first;
    final completed = metric.extractPath(0, metric.length * progress);
    canvas.drawPath(
      completed,
      Paint()
        ..color = AppColors.primary
        ..strokeWidth = 5.5
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );

    _drawLabel(
      canvas,
      'طريق الملك فهد',
      Offset(size.width * 0.72, size.height * 0.155),
      color: const Color(0xFF9B9D93),
      fontSize: 9.5,
      angle: -0.03,
    );
    _drawLabel(
      canvas,
      'حي الياسمين',
      Offset(size.width * 0.77, size.height * 0.085),
      color: const Color(0xFF789576),
      fontSize: 9,
    );
    _drawLabel(
      canvas,
      'شارع الأمير سلطان',
      Offset(size.width * 0.2, size.height * 0.31),
      color: const Color(0xFFA0A297),
      fontSize: 8.5,
      angle: -1.55,
    );
    _drawLabel(
      canvas,
      'حديقة الياسمين',
      Offset(size.width * 0.1, size.height * 0.355),
      color: const Color(0xFF789576),
      fontSize: 8,
    );
  }

  void _drawLabel(
    Canvas canvas,
    String text,
    Offset offset, {
    required Color color,
    required double fontSize,
    double angle = 0,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontFamily: 'IBM Plex Sans Arabic',
          fontSize: fontSize,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.rtl,
    )..layout();
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    canvas.rotate(angle);
    painter.paint(canvas, Offset(-painter.width / 2, -painter.height / 2));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _MapPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.delivered != delivered;
  }
}

Path _buildRoutePath(Size size) {
  return Path()
    ..moveTo(size.width * 0.15, size.height * 0.195)
    ..lineTo(size.width * 0.29, size.height * 0.195)
    ..quadraticBezierTo(
      size.width * 0.335,
      size.height * 0.195,
      size.width * 0.335,
      size.height * 0.24,
    )
    ..lineTo(size.width * 0.335, size.height * 0.31)
    ..quadraticBezierTo(
      size.width * 0.335,
      size.height * 0.355,
      size.width * 0.39,
      size.height * 0.355,
    )
    ..lineTo(size.width * 0.6, size.height * 0.355)
    ..quadraticBezierTo(
      size.width * 0.665,
      size.height * 0.355,
      size.width * 0.665,
      size.height * 0.31,
    )
    ..lineTo(size.width * 0.665, size.height * 0.285)
    ..quadraticBezierTo(
      size.width * 0.665,
      size.height * 0.245,
      size.width * 0.72,
      size.height * 0.245,
    )
    ..lineTo(size.width * 0.82, size.height * 0.245);
}

class _MessageSheet extends StatefulWidget {
  const _MessageSheet({required this.onSend});

  final ValueChanged<String> onSend;

  @override
  State<_MessageSheet> createState() => _MessageSheetState();
}

class _MessageSheetState extends State<_MessageSheet> {
  final TextEditingController _controller = TextEditingController();
  final _quickMessages = [
    'أنا في الطريق إليك',
    'من فضلك اتركه عند الباب',
    'اتصل بي عند الوصول',
    'شكراً لك',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        22,
        10,
        22,
        16 + MediaQuery.paddingOf(context).bottom,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(child: SheetHandle()),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Text('رسالة إلى عبدالله', style: AppTextStyles.headline),
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
          const SizedBox(height: 6),
          Text(
            'سيصل إشعار للسائق فور إرسال رسالتك',
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: _quickMessages.map((message) {
              return InkWell(
                onTap: () {
                  _controller.text = message;
                  setState(() {});
                },
                borderRadius: BorderRadius.circular(999),
                child: AppTag(
                  label: message,
                  background: _controller.text == message
                      ? AppColors.primarySoft
                      : AppColors.surface,
                  foreground: _controller.text == message
                      ? AppColors.primaryDark
                      : AppColors.textSecondary,
                  borderColor: _controller.text == message
                      ? AppColors.primary.withValues(alpha: 0.25)
                      : AppColors.border,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: TextField(
              controller: _controller,
              maxLines: 3,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textPrimary,
              ),
              decoration: const InputDecoration(
                hintText: 'اكتب رسالتك هنا...',
                fillColor: AppColors.surface,
              ),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () {
              final message = _controller.text.trim();
              if (message.isEmpty) {
                showAppSnackBar(
                  context,
                  'اكتب رسالة أولاً',
                  icon: Icons.chat_bubble_outline_rounded,
                );
                return;
              }
              widget.onSend(message);
            },
            icon: const Icon(Icons.send_rounded, size: 17),
            label: const Text('إرسال الرسالة'),
          ),
        ],
      ),
    );
  }
}

class _SupportTile extends StatelessWidget {
  const _SupportTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
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
              child: Icon(icon, size: 19, color: AppColors.primaryDark),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.titleSmall),
                  const SizedBox(height: 1),
                  Text(subtitle, style: AppTextStyles.caption),
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
  }
}
