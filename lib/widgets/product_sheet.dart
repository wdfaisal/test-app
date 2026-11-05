import 'package:flutter/material.dart';

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

  MenuItem get item => widget.item;

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

  bool _isSelected(OptionGroup group, MenuOption option) {
    return _selections[group.id]?.any((selected) => selected.id == option.id) ??
        false;
  }

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
          if (!group.required) current.clear();
        } else {
          current
            ..clear()
            ..add(option);
        }
      }
      _selections[group.id] = current;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context, listen: false);
    return Column(
      children: [
        SizedBox(
          height: 232,
          child: Stack(
            fit: StackFit.expand,
            children: [
              AppImage(item.image, fit: BoxFit.cover),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x5C000000), Colors.transparent],
                    stops: [0, 0.45],
                  ),
                ),
              ),
              Positioned(
                top: 12,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 28,
                right: 18,
                child: SoftIconButton(
                  icon: Icons.close_rounded,
                  size: 40,
                  iconSize: 19,
                  background: Colors.white.withValues(alpha: 0.95),
                  onTap: () => Navigator.pop(context),
                ),
              ),
              if (item.badge != null)
                Positioned(
                  top: 32,
                  left: 18,
                  child: PromoBadge(label: item.badge!, dark: true),
                ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: AppTextStyles.headline.copyWith(fontSize: 22),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      money(item.price),
                      style: AppTextStyles.price.copyWith(fontSize: 17),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                Text(
                  item.description,
                  style: AppTextStyles.bodySmall.copyWith(height: 1.75),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.schedule_rounded,
                            size: 13,
                            color: AppColors.primaryDark,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'يُحضّر طازجاً',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.primaryDark,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.local_fire_department_rounded,
                            size: 13,
                            color: AppColors.amber,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item.popular ? 'الأكثر طلباً' : 'اختيار الشيف',
                            style: AppTextStyles.caption.copyWith(
                              fontSize: 10.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                ...item.optionGroups.map((group) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _OptionGroupCard(
                      group: group,
                      selections: _selections[group.id] ?? const [],
                      isSelected: (option) => _isSelected(group, option),
                      onTap: (option) => _toggleOption(group, option),
                    ),
                  );
                }),
                const SizedBox(height: 4),
                Text('تعليمات خاصة', style: AppTextStyles.titleSmall),
                const SizedBox(height: 8),
                TextField(
                  controller: _noteController,
                  maxLines: 3,
                  maxLength: 160,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText:
                        'مثال: بدون بصل، الصوص على الجانب، تقطيع إضافي...',
                    fillColor: AppColors.surface,
                    counterStyle: AppTextStyles.caption.copyWith(fontSize: 9),
                    contentPadding: const EdgeInsets.all(14),
                  ),
                ),
                const SizedBox(height: 2),
              ],
            ),
          ),
        ),
        Container(
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
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 22,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          child: Row(
            children: [
              QuantityStepper(
                value: _quantity,
                onChanged: (value) => setState(() => _quantity = value),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    state.addToCart(
                      restaurant: widget.restaurant,
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
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('أضف للسلة'),
                      const SizedBox(width: 7),
                      Container(
                        width: 1,
                        height: 16,
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                      const SizedBox(width: 7),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        child: Text(
                          money(_total),
                          key: ValueKey(_total),
                          style: AppTextStyles.label.copyWith(
                            color: Colors.white,
                            fontSize: 12.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OptionGroupCard extends StatelessWidget {
  const _OptionGroupCard({
    required this.group,
    required this.selections,
    required this.isSelected,
    required this.onTap,
  });

  final OptionGroup group;
  final List<MenuOption> selections;
  final bool Function(MenuOption option) isSelected;
  final ValueChanged<MenuOption> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 15, 15, 7),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(group.title, style: AppTextStyles.titleSmall),
              if (group.required) ...[
                const SizedBox(width: 7),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'مطلوب',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primaryDark,
                      fontSize: 8.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              if (group.multiple)
                Text(
                  '${selections.length} مختار',
                  style: AppTextStyles.caption.copyWith(fontSize: 9.5),
                ),
            ],
          ),
          if (group.subtitle != null) ...[
            const SizedBox(height: 3),
            Text(
              group.subtitle!,
              style: AppTextStyles.caption.copyWith(fontSize: 10.5),
            ),
          ],
          const SizedBox(height: 5),
          ...group.options.map((option) {
            final selected = isSelected(option);
            return InkWell(
              onTap: () => onTap(option),
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.border)),
                ),
                child: Row(
                  children: [
                    _SelectionControl(
                      selected: selected,
                      multiple: group.multiple,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        option.label,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: selected
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                    Text(
                      option.price == 0 ? 'مجاناً' : '+ ${money(option.price)}',
                      style: AppTextStyles.caption.copyWith(
                        color: option.price == 0
                            ? AppColors.textTertiary
                            : AppColors.textSecondary,
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _SelectionControl extends StatelessWidget {
  const _SelectionControl({required this.selected, required this.multiple});

  final bool selected;
  final bool multiple;

  @override
  Widget build(BuildContext context) {
    if (multiple) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 19,
        height: 19,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.textTertiary,
            width: 1.4,
          ),
        ),
        child: selected
            ? const Icon(Icons.check_rounded, color: Colors.white, size: 13)
            : null,
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 19,
      height: 19,
      decoration: BoxDecoration(
        color: selected ? AppColors.primary : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? AppColors.primary : AppColors.textTertiary,
          width: 1.4,
        ),
      ),
      child: selected
          ? Center(
              child: Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            )
          : null,
    );
  }
}
