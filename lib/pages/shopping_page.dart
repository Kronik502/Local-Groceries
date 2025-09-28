import 'package:flutter/material.dart';
import 'cart_model.dart';
import 'cart_page.dart';

class ShoppingPage extends StatefulWidget {
  const ShoppingPage({super.key});

  @override
  State<ShoppingPage> createState() => _ShoppingPageState();
}

class _ShoppingPageState extends State<ShoppingPage> {
  final Map<String, int> _quantities = {
    'Bread': 0,
    'Milk': 0,
    'Coke': 0,
    'Biscuits': 0,
  };

  final Map<String, String> _descriptions = {
    'Bread': 'Freshly baked whole grain bread. Perfect for sandwiches and breakfast.',
    'Milk': 'Organic full cream milk - 1L. Packed with calcium and nutrients.',
    'Coke': 'Chilled Coca-Cola 500ml bottle. Refreshing and energizing.',
    'Biscuits': 'Crunchy butter biscuits, 250g pack. Great with tea or coffee.',
  };

  final Map<String, String> _imageFiles = {
    'Bread': 'bread.jpg',
    'Milk': 'milk.png',
    'Coke': 'coke.png',
    'Biscuits': 'biscuits.png',
  };

  void _increase(String item) {
    setState(() {
      _quantities[item] = _quantities[item]! + 1;
    });
  }

  void _decrease(String item) {
    setState(() {
      if (_quantities[item]! > 0) {
        _quantities[item] = _quantities[item]! - 1;
      }
    });
  }

  void _addToCart(String item) {
    final qty = _quantities[item]!;
    if (qty > 0) {
      CartModel().addItem(item, qty);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$qty x $item added to cart!'),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {
        _quantities[item] = 0; // reset input after adding to cart
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[50],
      appBar: AppBar(
        title: const Text('🛒 Shop Groceries'),
        backgroundColor: Colors.brown,
        elevation: 0,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CartPage()),
                  ).then((_) => setState(() {})); // refresh on return
                },
              ),
              if (CartModel().totalItemsCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                    child: Text(
                      '${CartModel().totalItemsCount}',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: _quantities.keys.map((item) {
          return Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'lib/images/${_imageFiles[item]}',
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _descriptions[item]!,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.brown[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.brown),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () => _decrease(item),
                            ),
                            Text(
                              '${_quantities[item]}',
                              style: const TextStyle(fontSize: 18),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () => _increase(item),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _addToCart(item),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.brown,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Add to Cart',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
