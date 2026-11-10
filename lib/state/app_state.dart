import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../models/models.dart';

class AppState extends ChangeNotifier {
  final List<CartLine> _cart = [];
  final Set<String> _favorites = {};

  Restaurant? _cartRestaurant;
  String _address = savedAddresses.first.details;
  String _addressLabel = savedAddresses.first.label;
  String _paymentMethod = 'card';
  String? _promoCode;
  bool _promoApplied = false;
  PlacedOrder? _activeOrder;
  bool _orderDelivered = false;

  List<CartLine> get cart => List.unmodifiable(_cart);
  Restaurant? get cartRestaurant => _cartRestaurant;
  String get address => _address;
  String get addressLabel => _addressLabel;
  String get paymentMethod => _paymentMethod;
  String? get promoCode => _promoCode;
  bool get promoApplied => _promoApplied;
  PlacedOrder? get activeOrder => _activeOrder;
  bool get orderDelivered => _orderDelivered;

  int get cartCount => _cart.fold(0, (sum, line) => sum + line.quantity);
  bool get isCartEmpty => _cart.isEmpty;

  double get subtotal => _cart.fold(0, (sum, line) => sum + line.total);

  double get deliveryFee => _cartRestaurant?.deliveryFee ?? 0;

  double get discount {
    if (!_promoApplied) return 0;
    final rate = switch (_promoCode) {
      'SULTAN15' => 0.15,
      'YALLA30' => 0.30,
      _ => 0.20,
    };
    return math.min(subtotal * rate, 25);
  }

  double get total => math.max(0, subtotal + deliveryFee - discount);

  String get paymentLabel {
    switch (_paymentMethod) {
      case 'apple':
        return 'Apple Pay';
      case 'cash':
        return 'الدفع عند الاستلام';
      default:
        return 'بطاقة •••• ٤٢٤٢';
    }
  }

  void addToCart({
    required Restaurant restaurant,
    required MenuItem item,
    required Map<String, List<MenuOption>> selections,
    required int quantity,
    String note = '',
  }) {
    if (_cartRestaurant != null && _cartRestaurant!.id != restaurant.id) {
      _cart.clear();
      _promoApplied = false;
      _promoCode = null;
    }
    _cartRestaurant = restaurant;
    _cart.add(
      CartLine(
        lineId: '${item.id}_${DateTime.now().microsecondsSinceEpoch}',
        item: item,
        restaurantId: restaurant.id,
        quantity: quantity,
        selections: selections,
        note: note,
      ),
    );
    notifyListeners();
  }

  void updateQuantity(String lineId, int quantity) {
    final index = _cart.indexWhere((line) => line.lineId == lineId);
    if (index == -1) return;
    if (quantity <= 0) {
      _cart.removeAt(index);
    } else {
      _cart[index] = _cart[index].copyWith(quantity: quantity);
    }
    if (_cart.isEmpty) {
      _cartRestaurant = null;
      _promoApplied = false;
      _promoCode = null;
    }
    notifyListeners();
  }

  void removeLine(String lineId) {
    _cart.removeWhere((line) => line.lineId == lineId);
    if (_cart.isEmpty) {
      _cartRestaurant = null;
      _promoApplied = false;
      _promoCode = null;
    }
    notifyListeners();
  }

  void setAddress(SavedAddress address) {
    _address = address.details;
    _addressLabel = address.label;
    notifyListeners();
  }

  void setPaymentMethod(String method) {
    _paymentMethod = method;
    notifyListeners();
  }

  bool applyPromo(String code) {
    final normalized = code.trim().toUpperCase();
    if (normalized == 'SULTAN15' ||
        normalized == 'WELCOME20' ||
        normalized == 'YALLA30') {
      _promoCode = normalized;
      _promoApplied = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  void removePromo() {
    _promoCode = null;
    _promoApplied = false;
    notifyListeners();
  }

  bool isFavorite(String restaurantId) => _favorites.contains(restaurantId);

  void toggleFavorite(String restaurantId) {
    if (!_favorites.add(restaurantId)) {
      _favorites.remove(restaurantId);
    }
    notifyListeners();
  }

  PlacedOrder placeOrder() {
    final restaurant = _cartRestaurant;
    final order = PlacedOrder(
      number: 'YT-24871',
      restaurant: restaurant ?? restaurants.first,
      lines: List.unmodifiable(_cart),
      address: _address,
      total: total,
      placedAt: DateTime.now(),
    );
    _activeOrder = order;
    _orderDelivered = false;
    _cart.clear();
    _cartRestaurant = null;
    _promoApplied = false;
    _promoCode = null;
    notifyListeners();
    return order;
  }

  void markOrderDelivered() {
    _orderDelivered = true;
    notifyListeners();
  }

  void resetForDemo() {
    _cart.clear();
    _cartRestaurant = null;
    _promoApplied = false;
    _promoCode = null;
    _activeOrder = null;
    _orderDelivered = false;
    notifyListeners();
  }
}

class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
    : super(notifier: state);

  static AppState of(BuildContext context, {bool listen = true}) {
    final scope = listen
        ? context.dependOnInheritedWidgetOfExactType<AppScope>()
        : context.getInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope is missing above this widget');
    return scope!.notifier!;
  }
}
