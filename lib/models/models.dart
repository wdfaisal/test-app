import 'package:flutter/material.dart';

class FoodCategory {
  const FoodCategory({
    required this.id,
    required this.label,
    required this.image,
  });

  final String id;
  final String label;
  final String image;
}

/// Visual layout used by the product customization sheet.
enum OptionGroupKind {
  /// Stacked radio rows (size selection).
  radio,

  /// Icon grid (bread choice).
  grid,

  /// Checkbox / stepper rows (add-ons).
  check,

  /// Wrap of toggle chips (removal preferences).
  tags,
}

class MenuCategory {
  const MenuCategory({required this.id, required this.label});

  final String id;
  final String label;
}

class MenuOption {
  const MenuOption({
    required this.id,
    required this.label,
    this.subtitle,
    this.price = 0,
    this.isDefault = false,
    this.stepper = false,
    this.recommended = false,
    this.icon,
  });

  final String id;
  final String label;
  final String? subtitle;
  final double price;
  final bool isDefault;

  /// When true the option is quantified with a stepper instead of a checkbox.
  final bool stepper;

  /// Rendered with a "موصى به" tag (chef pick).
  final bool recommended;

  /// Icon key used by grid layouts (bread choice, sauces).
  final String? icon;
}

class OptionGroup {
  const OptionGroup({
    required this.id,
    required this.title,
    required this.options,
    this.subtitle,
    this.required = false,
    this.multiple = false,
    this.kind = OptionGroupKind.radio,
    this.columns = 2,
  });

  final String id;
  final String title;
  final String? subtitle;
  final bool required;
  final bool multiple;
  final List<MenuOption> options;
  final OptionGroupKind kind;

  /// Column count for grid layouts.
  final int columns;
}

class MenuItem {
  const MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.price,
    required this.category,
    this.badge,
    this.popular = false,
    this.oldPrice,
    this.calories,
    this.spicy = false,
    this.optionGroups = const [],
  });

  final String id;
  final String name;
  final String description;
  final String image;
  final double price;
  final String category;
  final String? badge;
  final bool popular;
  final double? oldPrice;
  final int? calories;
  final bool spicy;
  final List<OptionGroup> optionGroups;
}

/// Tone of the promo badge shown on restaurant cards.
enum BadgeTone { orange, outline, green, white }

/// Accent color of the highlight row under a restaurant card.
enum FooterTone { orange, green, amber }

class Restaurant {
  const Restaurant({
    required this.id,
    required this.name,
    required this.cuisine,
    required this.description,
    required this.cover,
    required this.logo,
    required this.rating,
    required this.reviewCount,
    required this.deliveryMin,
    required this.deliveryMax,
    required this.deliveryFee,
    required this.distanceKm,
    required this.tags,
    required this.menuCategories,
    required this.menu,
    this.subtitle,
    this.badge,
    this.badgeTone = BadgeTone.orange,
    this.partner = false,
    this.features = const [],
    this.minimumOrder = 0,
    this.freeDeliveryAbove,
    this.footerIcon,
    this.footerText,
    this.footerTone = FooterTone.orange,
    this.promoCode,
    this.priceLevel = r'$$',
  });

  final String id;
  final String name;
  final String cuisine;
  final String description;

  /// Short line under the name (design 1 meta card).
  final String? subtitle;
  final String cover;
  final String logo;
  final double rating;
  final int reviewCount;
  final int deliveryMin;
  final int deliveryMax;
  final double deliveryFee;
  final double distanceKm;
  final List<String> tags;
  final List<MenuCategory> menuCategories;
  final List<MenuItem> menu;
  final String? badge;
  final BadgeTone badgeTone;
  final bool partner;
  final List<String> features;
  final double minimumOrder;
  final double? freeDeliveryAbove;
  final String? footerIcon;
  final String? footerText;
  final FooterTone footerTone;
  final String? promoCode;
  final String priceLevel;

  String get deliveryTime => '$deliveryMin–$deliveryMax دقيقة';
}

/// Brand tile in the "أفضل العلامات التجارية" grid.
class BrandTile {
  const BrandTile({
    required this.id,
    required this.name,
    required this.color,
    required this.logoType,
    this.badge,
    this.badgeColor,
    this.badgeOnColor = Colors.white,
    this.time,
    this.restaurantId,
  });

  final String id;
  final String name;
  final Color color;

  /// Which logo renderer to use: 'arches' | 'kfc' | 'hut' | 'kudu' |
  /// 'albaik' | 'shawarmer' | 'boutique' | 'maestro'.
  final String logoType;
  final String? badge;
  final Color? badgeColor;
  final Color badgeOnColor;
  final String? time;
  final String? restaurantId;
}

class CartLine {
  const CartLine({
    required this.lineId,
    required this.item,
    required this.restaurantId,
    this.quantity = 1,
    this.selections = const {},
    this.note = '',
  });

  final String lineId;
  final MenuItem item;
  final String restaurantId;
  final int quantity;
  final Map<String, List<MenuOption>> selections;
  final String note;

  double get optionsPrice {
    return selections.values
        .expand((options) => options)
        .fold(0, (sum, option) => sum + option.price);
  }

  double get unitPrice => item.price + optionsPrice;
  double get total => unitPrice * quantity;

  List<MenuOption> get selectedOptions {
    return selections.values.expand((options) => options).toList();
  }

  String get optionsLabel {
    final counts = <String, int>{};
    for (final option in selectedOptions) {
      counts[option.label] = (counts[option.label] ?? 0) + 1;
    }
    return counts.entries
        .map((entry) =>
            entry.value > 1 ? '${entry.key} ×${entry.value}' : entry.key)
        .join('، ');
  }

  CartLine copyWith({
    int? quantity,
    Map<String, List<MenuOption>>? selections,
    String? note,
  }) {
    return CartLine(
      lineId: lineId,
      item: item,
      restaurantId: restaurantId,
      quantity: quantity ?? this.quantity,
      selections: selections ?? this.selections,
      note: note ?? this.note,
    );
  }
}

class PlacedOrder {
  const PlacedOrder({
    required this.number,
    required this.restaurant,
    required this.lines,
    required this.address,
    required this.total,
    required this.placedAt,
  });

  final String number;
  final Restaurant restaurant;
  final List<CartLine> lines;
  final String address;
  final double total;
  final DateTime placedAt;

  int get itemCount => lines.fold(0, (sum, line) => sum + line.quantity);
}

class SavedAddress {
  const SavedAddress({
    required this.label,
    required this.details,
    required this.icon,
  });

  final String label;
  final String details;
  final String icon;
}

@immutable
class AppUser {
  const AppUser({
    required this.name,
    required this.phone,
    required this.avatar,
  });

  final String name;
  final String phone;
  final String avatar;
}
