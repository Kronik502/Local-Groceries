import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CartModel extends ChangeNotifier {
  static final CartModel _instance = CartModel._internal();

  factory CartModel() => _instance;

  CartModel._internal();

  final Map<String, int> _items = {};

  void addItem(String name, int quantity) {
    if (_items.containsKey(name)) {
      _items[name] = _items[name]! + quantity;
    } else {
      _items[name] = quantity;
    }

    // Remove if quantity <= 0 to keep map clean
    if (_items[name]! <= 0) {
      _items.remove(name);
    }

    notifyListeners();
    saveCart();
  }

  int get totalItemsCount {
    return _items.values.fold(0, (sum, qty) => sum + qty);
  }

  Map<String, int> get items => Map.unmodifiable(_items);

  void clearCart() {
    _items.clear();
    notifyListeners();
    saveCart();
  }

  void removeItem(String name) {
    _items.remove(name);
    notifyListeners();
    saveCart();
  }

  /// Load cart data from shared preferences
  Future<void> loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = prefs.getString('cart_items');
    if (cartJson != null) {
      final Map<String, dynamic> jsonMap = json.decode(cartJson);
      _items.clear();
      jsonMap.forEach((key, value) {
        _items[key] = value as int;
      });
      notifyListeners();
    }
  }

  /// Save cart data to shared preferences
  Future<void> saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = json.encode(_items);
    await prefs.setString('cart_items', cartJson);
  }
}
