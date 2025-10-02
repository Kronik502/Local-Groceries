import 'package:flutter/foundation.dart';

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
    notifyListeners();
  }

  int get totalItemsCount {
    return _items.values.fold(0, (sum, qty) => sum + qty);
  }

  Map<String, int> get items => Map.unmodifiable(_items);

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  void removeItem(String name) {
    _items.remove(name);
    notifyListeners();
  }
}
