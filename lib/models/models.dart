import 'package:flutter/foundation.dart';

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

class MenuCategory {
  const MenuCategory({required this.id, required this.label});

  final String id;
  final String label;
}

class MenuOption {
  const MenuOption({
    required this.id,
    required this.label,
    this.price = 0,
    this.isDefault = false,
  });

  final String id;
  final String label;
  final double price;
  final bool isDefault;
}

class OptionGroup {
  const OptionGroup({
    required this.id,
    required this.title,
    required this.options,
    this.subtitle,
    this.required = false,
    this.multiple = false,
  });

  final String id;
  final String title;
  final String? subtitle;
  final bool required;
  final bool multiple;
  final List<MenuOption> options;
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
  final List<OptionGroup> optionGroups;
}

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
    this.badge,
    this.priceLevel = r'$$',
  });

  final String id;
  final String name;
  final String cuisine;
  final String description;
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
  final String priceLevel;

  String get deliveryTime => '$deliveryMin–$deliveryMax دقيقة';
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
    return selectedOptions.map((option) => option.label).join('، ');
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
