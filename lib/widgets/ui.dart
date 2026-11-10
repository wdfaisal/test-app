import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class AppImage extends StatelessWidget {
  const AppImage(
    this.path, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.radius = 0,
    this.alignment = Alignment.center,
  });

  final String path;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double radius;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      path,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded || frame != null) return child;
        return const ColoredBox(color: AppColors.cream);
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width,
          height: height,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFF7F9FF), Color(0xFFEBEEF3)],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
          ),
          child: const Center(
            child: Icon(
              Icons.restaurant_rounded,
              color: AppColors.primary,
              size: 28,
            ),
          ),
        );
      },
    );

    if (radius == 0) return image;
    return ClipRRect(borderRadius: BorderRadius.circular(radius), child: image);
  }
}

class SoftIconButton extends StatelessWidget {
  const SoftIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.background = AppColors.surface,
    this.color = AppColors.textPrimary,
    this.size = 44,
    this.iconSize = 21,
    this.shadow = true,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color background;
  final Color color;
  final double size;
  final double iconSize;
  final bool shadow;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: background,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, color: color, size: iconSize),
        ),
      ),
    );

    final content = shadow
        ? DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: button,
          )
        : button;

    if (tooltip == null) return content;
    return Tooltip(message: tooltip!, child: content);
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.headline),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(subtitle!, style: AppTextStyles.bodySmall),
              ],
            ],
          ),
        ),
        if (actionLabel != null)
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onAction,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    actionLabel!,
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(width: 3),
                  const Icon(
                    Icons.arrow_back_rounded,
                    size: 16,
                    color: AppColors.primaryDark,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class RatingPill extends StatelessWidget {
  const RatingPill({
    super.key,
    required this.rating,
    this.reviews,
    this.compact = false,
    this.onDark = false,
  });

  final double rating;
  final int? reviews;
  final bool compact;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 5 : 7,
      ),
      decoration: BoxDecoration(
        color: onDark
            ? Colors.white.withValues(alpha: 0.16)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(999),
        border: onDark
            ? Border.all(color: Colors.white.withValues(alpha: 0.18))
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: AppColors.amber, size: 15),
          const SizedBox(width: 3),
          Text(
            rating.toStringAsFixed(1),
            style: AppTextStyles.label.copyWith(
              color: onDark ? Colors.white : AppColors.textPrimary,
              fontSize: compact ? 11 : 12.5,
            ),
          ),
          if (reviews != null) ...[
            const SizedBox(width: 4),
            Text(
              '($reviews)',
              style: AppTextStyles.caption.copyWith(
                color: onDark
                    ? Colors.white.withValues(alpha: 0.72)
                    : AppColors.textTertiary,
                fontSize: 10,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class PromoBadge extends StatelessWidget {
  const PromoBadge({
    super.key,
    required this.label,
    this.icon = Icons.local_offer_rounded,
    this.dark = false,
  });

  final String label;
  final IconData icon;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: dark ? AppColors.charcoal : AppColors.primary,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 10.5,
            ),
          ),
        ],
      ),
    );
  }
}

class InfoDot extends StatelessWidget {
  const InfoDot({super.key, this.color = AppColors.textTertiary});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 3,
      height: 3,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class AppTag extends StatelessWidget {
  const AppTag({
    super.key,
    required this.label,
    this.icon,
    this.background = AppColors.surface,
    this.foreground = AppColors.textSecondary,
    this.borderColor = AppColors.border,
  });

  final String label;
  final IconData? icon;
  final Color background;
  final Color foreground;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: foreground),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: foreground,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.compact = false,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final buttonSize = compact ? 30.0 : 36.0;
    return Container(
      padding: EdgeInsets.all(compact ? 3 : 4),
      decoration: BoxDecoration(
        color: AppColors.inkSoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepButton(
            icon: Icons.remove_rounded,
            size: buttonSize,
            onTap: value > 1 ? () => onChanged(value - 1) : null,
          ),
          SizedBox(
            width: compact ? 30 : 36,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: Text(
                '$value',
                key: ValueKey(value),
                textAlign: TextAlign.center,
                style: AppTextStyles.label.copyWith(
                  fontSize: compact ? 12.5 : 14,
                ),
              ),
            ),
          ),
          _StepButton(
            icon: Icons.add_rounded,
            size: buttonSize,
            onTap: () => onChanged(value + 1),
            filled: true,
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.size,
    this.onTap,
    this.filled = false,
  });

  final IconData icon;
  final double size;
  final VoidCallback? onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: filled ? AppColors.primary : Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(
            icon,
            size: size * 0.46,
            color: filled
                ? Colors.white
                : onTap == null
                ? AppColors.textTertiary
                : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  /// Pure-white design bar: fixed white, hairline top border, soft up-light.
  static const _items = [
    (icon: Icons.explore_outlined, label: 'استكشف'),
    (icon: Icons.favorite_border_rounded, label: 'المفضلة'),
    (icon: Icons.receipt_long_outlined, label: 'طلباتي'),
    (icon: Icons.person_outline_rounded, label: 'حسابي'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.surfacePure, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 12,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: List.generate(_items.length, (index) {
          final item = _items[index];
          final active = currentIndex == index;
          return Expanded(
            child: InkWell(
              onTap: () => onTap(index),
              borderRadius: BorderRadius.circular(14),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    item.icon,
                    size: 24,
                    color: active ? AppColors.primaryDark : AppColors.inkMuted,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.label,
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontSize: 12,
                      height: 16 / 12,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w600,
                      color: active ? AppColors.primaryDark : AppColors.inkMuted,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class FadeSlideIn extends StatefulWidget {
  const FadeSlideIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 620),
    this.offset = 20,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;
  final double offset;

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    final curved = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _opacity = curved;
    _slide = Tween<Offset>(
      begin: Offset(0, widget.offset / 100),
      end: Offset.zero,
    ).animate(curved);
    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      _timer = Timer(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        return Opacity(
          opacity: _opacity.value,
          child: Transform.translate(
            offset: Offset(0, _slide.value.dy * 100),
            child: child,
          ),
        );
      },
    );
  }
}

class SheetHandle extends StatelessWidget {
  const SheetHandle({super.key, this.color = AppColors.border});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(99),
      ),
    );
  }
}

class DividerLine extends StatelessWidget {
  const DividerLine({
    super.key,
    this.height = 1,
    this.color = AppColors.border,
  });

  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(height: height, color: color);
  }
}

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.onDark = false, this.size = 21});

  final bool onDark;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'يلا طلبات',
          style: TextStyle(
            fontFamily: 'IBM Plex Sans Arabic',
            fontSize: size,
            fontWeight: FontWeight.w700,
            height: 1.2,
            color: onDark ? Colors.white : AppColors.textPrimary,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(width: 2),
        Container(
          width: 5,
          height: 5,
          margin: EdgeInsets.only(bottom: size * 0.55),
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }
}

Route<T> premiumRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    transitionDuration: const Duration(milliseconds: 440),
    reverseTransitionDuration: const Duration(milliseconds: 320),
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutQuint,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: Tween<double>(begin: 0.35, end: 1).animate(curved),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.07, 0),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

Future<void> showAppSheet({
  required BuildContext context,
  required Widget child,
  bool isScrollControlled = true,
  double? heightFactor,
  bool dismissible = true,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: isScrollControlled,
    isDismissible: dismissible,
    enableDrag: dismissible,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    useSafeArea: false,
    builder: (context) {
      final screenHeight = MediaQuery.sizeOf(context).height;
      return Padding(
        padding: EdgeInsets.only(top: screenHeight * 0.06),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          child: SizedBox(
            height: heightFactor == null ? null : screenHeight * heightFactor,
            child: Material(color: AppColors.background, child: child),
          ),
        ),
      );
    },
  );
}

void showAppSnackBar(
  BuildContext context,
  String message, {
  IconData icon = Icons.check_circle_rounded,
}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        duration: const Duration(milliseconds: 2200),
        content: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 19),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
}
