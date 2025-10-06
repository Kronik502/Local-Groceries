import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
      final cart = Provider.of<CartModel>(context, listen: false);
      cart.addItem(item, qty);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('$qty x $item added to cart!'),
            ],
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: EdgeInsets.all(16),
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
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 20,
            offset: Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image with gradient overlay
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                child: Image.asset(
                  'lib/images/${_imageFiles[item]}',
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, color: AppColors.warning, size: 16),
                      SizedBox(width: 4),
                      Text(
                        '4.8',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Title
                Text(
                  item,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),

                // Product Description
                Text(
                  _descriptions[item]!,
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),

                // Quantity + Add Button
                Row(
                  children: [
                    // Quantity Selector
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryLight.withOpacity(0.3),
                            AppColors.primaryLight.withOpacity(0.15),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.2),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => _decrease(item),
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: EdgeInsets.all(12),
                                child: Icon(
                                  Icons.remove_rounded,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              '${_quantities[item]}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => _increase(item),
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: EdgeInsets.all(12),
                                child: Icon(
                                  Icons.add_rounded,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Add to Cart Button
                    Expanded(
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: AppColors.secondaryGradient,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.secondary.withOpacity(0.3),
                              blurRadius: 12,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _addToCart(item),
                            borderRadius: BorderRadius.circular(16),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.shopping_cart_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Add to Cart',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}