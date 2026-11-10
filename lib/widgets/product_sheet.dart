import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'ui.dart';

Future<void> showProductSheet({
  required BuildContext context,
  required Restaurant restaurant,
  required MenuItem item,
}) {
  return showAppSheet(
    context: context,
    heightFactor: 0.93,
    child: _ProductSheet(restaurant: restaurant, item: item),
  );
}

class _ProductSheet extends StatefulWidget {
  const _ProductSheet({required this.restaurant, required this.item});

  final Restaurant restaurant;
  final MenuItem item;

  @override
  State<_ProductSheet> createState() => _ProductSheetState();
}

class _ProductSheetState extends State<_ProductSheet> {
  late final Map<String, List<MenuOption>> _selections;
  final TextEditingController _noteController = TextEditingController();
  int _quantity = 1;

  static const _maxOptionCount = 5;

  MenuItem get item => widget.item;
  Restaurant get restaurant => widget.restaurant;

  double get _unitPrice {
    return item.price +
        _selections.values
            .expand((options) => options)
            .fold(0, (sum, option) => sum + option.price);
  }

  double get _total => _unitPrice * _quantity;

  @override
  void initState() {
    super.initState();
    _selections = {};
    for (final group in item.optionGroups) {
      final defaults = group.options
          .where((option) => option.isDefault)
          .toList();
      if (defaults.isNotEmpty) {
        _selections[group.id] = defaults;
      } else if (group.required && group.options.isNotEmpty) {
        _selections[group.id] = [group.options.first];
      }
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  int _countOf(OptionGroup group, MenuOption option) {
    return _selections[group.id]
            ?.where((selected) => selected.id == option.id)
            .length ??
        0;
  }

  bool _isSelected(OptionGroup group, MenuOption option) =>
      _countOf(group, option) > 0;

  void _toggleOption(OptionGroup group, MenuOption option) {
    setState(() {
      final current = List<MenuOption>.from(_selections[group.id] ?? []);
      if (group.multiple) {
        if (current.any((selected) => selected.id == option.id)) {
          current.removeWhere((selected) => selected.id == option.id);
        } else {
          current.add(option);
        }
      } else {
        if (current.any((selected) => selected.id == option.id)) {
          // Radios keep their choice — tap another option to switch.
          return;
        }
        current
          ..clear()
          ..add(option);
      }
      _selections[group.id] = current;
    });
  }

  void _stepOption(OptionGroup group, MenuOption option, int delta) {
    setState(() {
      final current = List<MenuOption>.from(_selections[group.id] ?? []);
      final count =
          current.where((selected) => selected.id == option.id).length;
      if (delta > 0 && count < _maxOptionCount) {
        current.add(option);
      } else if (delta < 0 && count > 0) {
        current.removeWhere((selected) => selected.id == option.id);
      }
      _selections[group.id] = current;
    });
  }

  void _submit() {
    final state = AppScope.of(context, listen: false);
    state.addToCart(
      restaurant: restaurant,
      item: item,
      selections: _selections,
      quantity: _quantity,
      note: _noteController.text.trim(),
    );
    Navigator.pop(context);
    showAppSnackBar(
      context,
      'تمت إضافة ${item.name} إلى السلة',
      icon: Icons.shopping_bag_rounded,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SheetHero(restaurant: restaurant, item: item),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TitleBlock(restaurant: restaurant, item: item),
                const SizedBox(height: 18),
                for (final group in item.optionGroups) ...[
                  _OptionSection(
                    group: group,
                    isSelected: (option) => _isSelected(group, option),
                    countOf: (option) => _countOf(group, option),
                    onToggle: (option) => _toggleOption(group, option),
                    onStep: (option, delta) => _stepOption(group, option, delta),
                  ),
                  const SizedBox(height: 16),
                ],
                _NotesField(controller: _noteController),
              ],
            ),
          ),
        ),
        _StickyBar(
          quantity: _quantity,
          total: _total,
          onQuantityChanged: (value) => setState(() => _quantity = value),
          onAdd: _submit,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Hero photo with dark scrim, floating actions and stat pills (design 2).
// ---------------------------------------------------------------------------

class _SheetHero extends StatelessWidget {
  const _SheetHero({required this.restaurant, required this.item});

  final Restaurant restaurant;
  final MenuItem item;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 288,
      child: Stack(
        fit: StackFit.expand,
        children: [
          AppImage(item.image, fit: BoxFit.cover),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xD9313033),
                  Colors.transparent,
                  Color(0x99313033),
                ],
                stops: [0, 0.4, 1],
              ),
            ),
          ),
          // Close / drag handle / favorite row.
          Positioned(
            top: 12,
            left: 16,
            right: 16,
            child: Row(
              children: [
                _HeroCircleButton(
                  icon: Icons.close_rounded,
                  tooltip: 'إغلاق النافذة',
                  onTap: () => Navigator.pop(context),
                ),
                const Spacer(),
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const Spacer(),
                _HeroCircleButton(
                  icon: Icons.favorite_border_rounded,
                  tooltip: 'مشاركة أو مفضلة',
                  onTap: () => showAppSnackBar(
                    context,
                    'أُضيف ${item.name} إلى المفضلة',
                    icon: Icons.favorite_rounded,
                  ),
                ),
              ],
            ),
          ),
          // "الأكثر طلباً 🔥" badge.
          if (item.popular)
            Positioned(
              top: 64,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  'الأكثر طلباً 🔥',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          // Calories + rating pills.
          Positioned(
            bottom: 12,
            right: 16,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (item.calories != null)
                  _HeroStatPill(
                    icon: Icons.local_fire_department_rounded,
                    iconColor: const Color(0xFFFFB59E),
                    label: '${item.calories} سعرة حرارية',
                  ),
                if (item.calories != null) const SizedBox(width: 8),
                _HeroStatPill(
                  icon: Icons.star_rounded,
                  iconColor: AppColors.green,
                  label:
                      '${restaurant.rating.toStringAsFixed(1)} '
                      '(${restaurant.reviewCount}+ تقييم)',
                ),
              ],
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
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final button = DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Material(
            color: const Color(0xD9313033),
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: SizedBox(
                width: 36,
                height: 36,
                child: Icon(icon, size: 20, color: Colors.white),
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

class _HeroStatPill extends StatelessWidget {
  const _HeroStatPill({
    required this.icon,
    required this.iconColor,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String label;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xD9313033),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 4),
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white,
                  fontSize: 11,
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
// Title, price and description block (design 2).
// ---------------------------------------------------------------------------

class _TitleBlock extends StatelessWidget {
  const _TitleBlock({required this.restaurant, required this.item});

  final Restaurant restaurant;
  final MenuItem item;

  @override
  Widget build(BuildContext context) {
    final latin = latinBrandNames[restaurant.id];
    final brandLabel = latin == null
        ? restaurant.name
        : '${restaurant.name} • $latin';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(brandLabel, style: AppTextStyles.caption),
                  const SizedBox(height: 2),
                  Text(
                    item.name,
                    style: AppTextStyles.headline.copyWith(fontSize: 26),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      item.price.toStringAsFixed(2),
                      style: AppTextStyles.price.copyWith(fontSize: 22),
                    ),
                    const SizedBox(width: 3),
                    Text('ر.س', style: AppTextStyles.caption),
                  ],
                ),
                if (item.oldPrice != null)
                  Text(
                    '${item.oldPrice!.toStringAsFixed(2)} ر.س',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textTertiary,
                      decoration: TextDecoration.lineThrough,
                      decorationColor: AppColors.textTertiary,
                    ),
                  ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          item.description,
          style: AppTextStyles.body.copyWith(height: 1.7),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Option section — header bar + kind-aware body (design 2).
// ---------------------------------------------------------------------------

class _OptionSection extends StatelessWidget {
  const _OptionSection({
    required this.group,
    required this.isSelected,
    required this.countOf,
    required this.onToggle,
    required this.onStep,
  });

  final OptionGroup group;
  final bool Function(MenuOption option) isSelected;
  final int Function(MenuOption option) countOf;
  final ValueChanged<MenuOption> onToggle;
  final void Function(MenuOption option, int delta) onStep;

  IconData _iconFor(MenuOption option) {
    return switch (option.icon) {
      'bakery' => Icons.bakery_dining_rounded,
      'grain' => Icons.grain_rounded,
      'eco' => Icons.eco_rounded,
      'smoke' => Icons.local_fire_department_rounded,
      'truffle' => Icons.restaurant_rounded,
      'block' => Icons.block_rounded,
      'drop' => Icons.opacity_rounded,
      'split' => Icons.horizontal_split,
      _ => Icons.lunch_dining_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    final subtitle = group.subtitle;
    final requiredChip = subtitle?.contains('مطلوب') ?? false;
    final optionalChip = subtitle?.contains('اختياري') ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 6,
              height: 16,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                group.title,
                style: AppTextStyles.titleSmall.copyWith(fontSize: 16),
              ),
            ),
            if (subtitle != null)
              if (requiredChip)
                _HeaderChip(
                  label: subtitle,
                  background: AppColors.primary.withValues(alpha: 0.1),
                  foreground: AppColors.primary,
                )
              else if (optionalChip)
                _HeaderChip(
                  label: subtitle,
                  background: AppColors.surfaceContainer,
                  foreground: AppColors.textPrimary,
                )
              else
                Text(subtitle, style: AppTextStyles.caption),
          ],
        ),
        const SizedBox(height: 12),
        switch (group.kind) {
          OptionGroupKind.radio => _RadioList(
              group: group,
              isSelected: isSelected,
              onToggle: onToggle,
            ),
          OptionGroupKind.grid => group.multiple
              ? _ChoiceGrid(
                  group: group,
                  isSelected: isSelected,
                  onToggle: onToggle,
                  iconFor: _iconFor,
                )
              : _IconGrid(
                  group: group,
                  isSelected: isSelected,
                  onToggle: onToggle,
                  iconFor: _iconFor,
                ),
          OptionGroupKind.check => _CheckList(
              group: group,
              isSelected: isSelected,
              countOf: countOf,
              onToggle: onToggle,
              onStep: onStep,
            ),
          OptionGroupKind.tags => _RemovalTags(
              group: group,
              isSelected: isSelected,
              onToggle: onToggle,
              iconFor: _iconFor,
            ),
        },
      ],
    );
  }
}

class _HeaderChip extends StatelessWidget {
  const _HeaderChip({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: foreground,
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Size selection — stacked radio rows (design 2).
// ---------------------------------------------------------------------------

class _RadioList extends StatelessWidget {
  const _RadioList({
    required this.group,
    required this.isSelected,
    required this.onToggle,
  });

  final OptionGroup group;
  final bool Function(MenuOption option) isSelected;
  final ValueChanged<MenuOption> onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final option in group.options) ...[
          _RadioRow(
            option: option,
            selected: isSelected(option),
            onTap: () => onToggle(option),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _RadioRow extends StatelessWidget {
  const _RadioRow({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final MenuOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primarySoft : AppColors.surfaceLow,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? AppColors.primary.withValues(alpha: 0.35)
                  : Colors.transparent,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              _RadioBullet(selected: selected),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            option.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.label.copyWith(
                              fontWeight: selected || option.recommended
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        if (option.recommended) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'موصى به',
                              style: AppTextStyles.caption.copyWith(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (option.subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        option.subtitle!,
                        style: AppTextStyles.bodySmall.copyWith(fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
              Text(
                option.price == 0
                    ? 'مشمول'
                    : '+${option.price.toStringAsFixed(2)} ر.س',
                style: AppTextStyles.label.copyWith(
                  color: option.price == 0
                      ? AppColors.textSecondary
                      : selected
                      ? AppColors.primary
                      : AppColors.textPrimary,
                  fontWeight: option.price == 0
                      ? FontWeight.w500
                      : FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RadioBullet extends StatelessWidget {
  const _RadioBullet({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? AppColors.primary : AppColors.textTertiary,
          width: 2,
        ),
      ),
      child: selected
          ? Center(
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            )
          : null,
    );
  }
}

// ---------------------------------------------------------------------------
// Bread-style icon grid — single choice (design 2).
// ---------------------------------------------------------------------------

class _IconGrid extends StatelessWidget {
  const _IconGrid({
    required this.group,
    required this.isSelected,
    required this.onToggle,
    required this.iconFor,
  });

  final OptionGroup group;
  final bool Function(MenuOption option) isSelected;
  final ValueChanged<MenuOption> onToggle;
  final IconData Function(MenuOption option) iconFor;

  Color _iconColor(MenuOption option) {
    return switch (option.icon) {
      'bakery' => AppColors.primary,
      'grain' => AppColors.textSecondary,
      'eco' => AppColors.green,
      _ => AppColors.textSecondary,
    };
  }

  @override
  Widget build(BuildContext context) {
    final columns = group.columns.clamp(1, 4);
    final rows = <Widget>[];
    for (var i = 0; i < group.options.length; i += columns) {
      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var j = 0; j < columns; j++)
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: j == 0 ? 0 : 5,
                    right: j == columns - 1 ? 0 : 5,
                  ),
                  child: i + j < group.options.length
                      ? _IconGridCell(
                          option: group.options[i + j],
                          selected: isSelected(group.options[i + j]),
                          icon: iconFor(group.options[i + j]),
                          iconColor: _iconColor(group.options[i + j]),
                          onTap: () => onToggle(group.options[i + j]),
                        )
                      : const SizedBox(),
                ),
              ),
          ],
        ),
      );
      if (i + columns < group.options.length) {
        rows.add(const SizedBox(height: 10));
      }
    }
    return Column(children: rows);
  }
}

class _IconGridCell extends StatelessWidget {
  const _IconGridCell({
    required this.option,
    required this.selected,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  final MenuOption option;
  final bool selected;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.surfaceHigh : AppColors.surfaceLow,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? AppColors.primary.withValues(alpha: 0.45)
                  : Colors.transparent,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              Icon(icon, size: 28, color: iconColor),
              const SizedBox(height: 6),
              Text(
                option.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                option.subtitle ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 10.5,
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
// Sauce-style grid — multiple checkboxes (design 2).
// ---------------------------------------------------------------------------

class _ChoiceGrid extends StatelessWidget {
  const _ChoiceGrid({
    required this.group,
    required this.isSelected,
    required this.onToggle,
    required this.iconFor,
  });

  final OptionGroup group;
  final bool Function(MenuOption option) isSelected;
  final ValueChanged<MenuOption> onToggle;
  final IconData Function(MenuOption option) iconFor;

  Color _iconColor(MenuOption option) {
    return switch (option.icon) {
      'truffle' => AppColors.green,
      _ => AppColors.primary,
    };
  }

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < group.options.length; i += group.columns) {
      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var j = 0; j < group.columns; j++)
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: j == 0 ? 0 : 5,
                    right: j == group.columns - 1 ? 0 : 5,
                  ),
                  child: i + j < group.options.length
                      ? _SauceCell(
                          option: group.options[i + j],
                          selected: isSelected(group.options[i + j]),
                          icon: iconFor(group.options[i + j]),
                          iconColor: _iconColor(group.options[i + j]),
                          onTap: () => onToggle(group.options[i + j]),
                        )
                      : const SizedBox(),
                ),
              ),
          ],
        ),
      );
      if (i + group.columns < group.options.length) {
        rows.add(const SizedBox(height: 10));
      }
    }
    return Column(children: rows);
  }
}

class _SauceCell extends StatelessWidget {
  const _SauceCell({
    required this.option,
    required this.selected,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  final MenuOption option;
  final bool selected;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceLow,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? AppColors.primary.withValues(alpha: 0.45)
                  : Colors.transparent,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 24, color: iconColor),
                  const Spacer(),
                  _CheckMark(selected: selected),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                option.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12.5,
                ),
              ),
              if (option.subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  option.subtitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(fontSize: 10.5),
                ),
              ],
              const SizedBox(height: 8),
              Text(
                '+${option.price.toStringAsFixed(2)} ر.س',
                style: AppTextStyles.label.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckMark extends StatelessWidget {
  const _CheckMark({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: selected ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: selected ? AppColors.primary : AppColors.textTertiary,
          width: 1.6,
        ),
      ),
      child: selected
          ? const Icon(Icons.check_rounded, size: 13, color: Colors.white)
          : null,
    );
  }
}

// ---------------------------------------------------------------------------
// Add-ons — checkbox rows with optional mini steppers (design 2).
// ---------------------------------------------------------------------------

class _CheckList extends StatelessWidget {
  const _CheckList({
    required this.group,
    required this.isSelected,
    required this.countOf,
    required this.onToggle,
    required this.onStep,
  });

  final OptionGroup group;
  final bool Function(MenuOption option) isSelected;
  final int Function(MenuOption option) countOf;
  final ValueChanged<MenuOption> onToggle;
  final void Function(MenuOption option, int delta) onStep;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final option in group.options) ...[
          _AddonRow(
            option: option,
            selected: isSelected(option),
            count: countOf(option),
            onToggle: () => onToggle(option),
            onStep: onStep,
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _AddonRow extends StatelessWidget {
  const _AddonRow({
    required this.option,
    required this.selected,
    required this.count,
    required this.onToggle,
    required this.onStep,
  });

  final MenuOption option;
  final bool selected;
  final int count;
  final VoidCallback onToggle;
  final void Function(MenuOption option, int delta) onStep;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.surfaceContainer : AppColors.surfaceLow,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onToggle,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? AppColors.primary.withValues(alpha: 0.35)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              if (option.stepper)
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceHigh,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.lunch_dining_rounded,
                    size: 22,
                    color: AppColors.primary,
                  ),
                )
              else
                _CheckMark(selected: selected),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.label.copyWith(fontSize: 14),
                    ),
                    if (option.subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        option.subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySmall.copyWith(fontSize: 11.5),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '+${option.price.toStringAsFixed(2)} ر.س',
                style: AppTextStyles.label.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              if (option.stepper) ...[
                const SizedBox(width: 8),
                _MiniStepper(
                  count: count,
                  onMinus: () => onStep(option, -1),
                  onPlus: () => onStep(option, 1),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniStepper extends StatelessWidget {
  const _MiniStepper({
    required this.count,
    required this.onMinus,
    required this.onPlus,
  });

  final int count;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _MiniStepButton(
            icon: Icons.remove_rounded,
            background: AppColors.surfaceContainer,
            onTap: count > 0 ? onMinus : null,
          ),
          SizedBox(
            width: 26,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 160),
              child: Text(
                '$count',
                key: ValueKey(count),
                textAlign: TextAlign.center,
                style: AppTextStyles.label.copyWith(fontSize: 13),
              ),
            ),
          ),
          _MiniStepButton(
            icon: Icons.add_rounded,
            background: AppColors.primary,
            iconColor: Colors.white,
            onTap: onPlus,
          ),
        ],
      ),
    );
  }
}

class _MiniStepButton extends StatelessWidget {
  const _MiniStepButton({
    required this.icon,
    required this.background,
    required this.onTap,
    this.iconColor = AppColors.textPrimary,
  });

  final IconData icon;
  final Color background;
  final Color iconColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 28,
          height: 28,
          child: Icon(icon, size: 16, color: iconColor),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Kitchen preferences — removal tag wrap (design 2).
// ---------------------------------------------------------------------------

class _RemovalTags extends StatelessWidget {
  const _RemovalTags({
    required this.group,
    required this.isSelected,
    required this.onToggle,
    required this.iconFor,
  });

  final OptionGroup group;
  final bool Function(MenuOption option) isSelected;
  final ValueChanged<MenuOption> onToggle;
  final IconData Function(MenuOption option) iconFor;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final option in group.options)
          _RemovalTag(
            option: option,
            selected: isSelected(option),
            icon: iconFor(option),
            onTap: () => onToggle(option),
          ),
      ],
    );
  }
}

class _RemovalTag extends StatelessWidget {
  const _RemovalTag({
    required this.option,
    required this.selected,
    required this.icon,
    required this.onTap,
  });

  final MenuOption option;
  final bool selected;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.surfaceHigh : AppColors.surfaceLow,
      borderRadius: BorderRadius.circular(999),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected
                  ? AppColors.primary.withValues(alpha: 0.4)
                  : AppColors.surfaceLow,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: selected ? AppColors.primary : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                option.label,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 12,
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
// Additional notes for the restaurant (design 2).
// ---------------------------------------------------------------------------

class _NotesField extends StatelessWidget {
  const _NotesField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.edit_note_rounded,
              size: 18,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text('ملاحظات إضافية للمطعم', style: AppTextStyles.label),
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          minLines: 2,
          maxLines: 4,
          maxLength: 160,
          style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'مثال: يرجى تحميص الخبز جيداً، أو وضع الصلصة على جنب...',
            fillColor: AppColors.surfaceLow,
            filled: true,
            counterStyle: AppTextStyles.caption.copyWith(fontSize: 9),
            contentPadding: const EdgeInsets.all(12),
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
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Sticky add-to-cart bar with dynamic total (design 2).
// ---------------------------------------------------------------------------

class _StickyBar extends StatelessWidget {
  const _StickyBar({
    required this.quantity,
    required this.total,
    required this.onQuantityChanged,
    required this.onAdd,
  });

  final int quantity;
  final double total;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.95),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          padding: EdgeInsets.fromLTRB(
            16,
            12,
            16,
            12 + MediaQuery.paddingOf(context).bottom,
          ),
          child: Row(
            children: [
              // Quantity stepper module.
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLow,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _StepTile(
                      icon: Icons.remove_rounded,
                      onTap: quantity > 1
                          ? () => onQuantityChanged(quantity - 1)
                          : null,
                    ),
                    SizedBox(
                      width: 30,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 160),
                        child: Text(
                          '$quantity',
                          key: ValueKey(quantity),
                          textAlign: TextAlign.center,
                          style: AppTextStyles.titleSmall.copyWith(
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    _StepTile(
                      icon: Icons.add_rounded,
                      onTap: () => onQuantityChanged(quantity + 1),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Add to basket CTA with dynamic price.
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: FilledButton(
                    onPressed: onAdd,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.shopping_bag_rounded,
                          size: 20,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 7),
                        Flexible(
                          child: Text(
                            'إضافة للسلة',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.titleSmall.copyWith(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        const Spacer(),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Row(
                            key: ValueKey(total.toStringAsFixed(2)),
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                total.toStringAsFixed(2),
                                style: AppTextStyles.titleSmall.copyWith(
                                  color: Colors.white,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(width: 3),
                              Text(
                                'ر.س',
                                style: AppTextStyles.caption.copyWith(
                                  color: Colors.white.withValues(alpha: 0.9),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepTile extends StatelessWidget {
  const _StepTile({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(
            icon,
            size: 18,
            color: onTap == null
                ? AppColors.textTertiary
                : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
