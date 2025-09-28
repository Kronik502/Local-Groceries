class CartModel {
  static final CartModel _instance = CartModel._internal();

  factory CartModel() {
    return _instance;
  }

  CartModel._internal();

  // Map of product name to quantity
  final Map<String, int> items = {};

  void addItem(String product, int quantity) {
    if (quantity <= 0) return;
    items.update(product, (existingQty) => existingQty + quantity, ifAbsent: () => quantity);
  }

  void removeItem(String product) {
    items.remove(product);
  }

  void clear() {
    items.clear();
  }

  int get totalItemsCount => items.values.fold(0, (sum, qty) => sum + qty);
}
