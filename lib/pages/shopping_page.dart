import 'package:flutter/material.dart';
import 'package:provider/provider.dart';  // <-- Import provider
import '../styles/colors.dart';
import 'cart_model.dart';
import 'cart_page.dart';

class ShoppingPage extends StatefulWidget {
  const ShoppingPage({super.key});

  @override
  State<ShoppingPage> createState() => _ShoppingPageState();
}

class _ShoppingPageState extends State<ShoppingPage> with TickerProviderStateMixin {
  final Map<String, int> _quantities = {
    'Bread': 1,
    'Milk': 1,
    'Coke': 1,
    'Biscuits': 1,
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

  final List<String> _items = [];

  @override
  void initState() {
    super.initState();
    _animateItems();
  }

  // Animate items in with delay
  void _animateItems() async {
    for (var item in _quantities.keys) {
      await Future.delayed(const Duration(milliseconds: 200));
      setState(() {
        _items.add(item);
      });
    }
  }

  void _increase(String item) {
    setState(() {
      _quantities[item] = _quantities[item]! + 1;
    });
  }

  void _decrease(String item) {
    setState(() {
      if (_quantities[item]! > 1) {
        _quantities[item] = _quantities[item]! - 1;
      }
    });
  }

  void _addToCart(String item) {
    final qty = _quantities[item]!;
    if (qty > 0) {
      // Use Provider to get CartModel instance and add item
      final cart = Provider.of<CartModel>(context, listen: false);
      cart.addItem(item, qty);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$qty x $item added to cart!'),
          duration: const Duration(seconds: 2),
          backgroundColor: AppColors.success,
        ),
      );

      setState(() {
        _quantities[item] = 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('🛒 Shop Groceries'),
        backgroundColor: AppColors.primary,
        elevation: 0,
        // Optional: You can add a cart icon with badge here if you want
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final item = _items[index];
          return AnimatedOpacity(
            duration: const Duration(milliseconds: 500),
            opacity: 1.0,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.1),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: AnimationController(
                    duration: const Duration(milliseconds: 500),
                    vsync: this,
                  )..forward(),
                  curve: Curves.easeOut,
                ),
              ),
              child: _buildProductCard(item),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductCard(String item) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
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

            // Product Title
            Text(
              item,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 6),

            // Product Description
            Text(
              _descriptions[item]!,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),

            // Quantity + Add Button
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.inputBackground,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.primary),
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
                      backgroundColor: AppColors.secondary,
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
  }
}
