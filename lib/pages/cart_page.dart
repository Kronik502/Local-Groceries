import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../styles/colors.dart'; // Assuming AppColors is in a separate file
import 'cart_model.dart';
import 'checkout_page.dart';

class CartPage extends StatelessWidget {
  CartPage({super.key});

  // Map for image files same as shopping page
  final Map<String, String> _imageFiles = {
    'Bread': 'bread.jpg',
    'Milk': 'milk.png',
    'Coke': 'coke.png',
    'Biscuits': 'biscuits.png',
  };

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartModel>(context);
    final items = cart.items;

    void _increaseQty(String product) {
      cart.addItem(product, 1);
      // saveCart is automatically called inside addItem()
    }

    void _decreaseQty(String product) {
      if (items[product]! > 1) {
        cart.addItem(product, -1); // subtract 1
      } else {
        cart.removeItem(product);
      }
      // saveCart is automatically called inside addItem() or removeItem()
    }

    return Scaffold(
      backgroundColor: AppColors.background, // Soft slate background
      body: items.isEmpty
          ? Center(
              child: Text(
                'Your cart is empty',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                  fontFamily: 'Inter',
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: items.entries.map((entry) {
                final product = entry.key;
                final quantity = entry.value;

                return Card(
                  elevation: 4, // Subtle shadow for depth
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16), // Softer corners
                  ),
                  color: AppColors.cardBackground, // White card background
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Product Image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            'lib/images/${_imageFiles[product]}',
                            height: 80,
                            width: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              height: 80,
                              width: 80,
                              color: AppColors.lightGray,
                              child: Icon(
                                Icons.image_not_supported,
                                color: AppColors.gray,
                                size: 40,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Product name and quantity controls
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                  fontFamily: 'Inter',
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  // Decrease button
                                  IconButton(
                                    icon: Icon(
                                      Icons.remove_circle_outline,
                                      color: AppColors.secondary,
                                      size: 28,
                                    ),
                                    onPressed: () => _decreaseQty(product),
                                  ),

                                  // Quantity display
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppColors.inputBackground,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '$quantity',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textPrimary,
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                                  ),

                                  // Increase button
                                  IconButton(
                                    icon: Icon(
                                      Icons.add_circle_outline,
                                      color: AppColors.secondary,
                                      size: 28,
                                    ),
                                    onPressed: () => _increaseQty(product),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Remove item button
                        IconButton(
                          icon: Icon(
                            Icons.delete_forever,
                            color: AppColors.error,
                            size: 28,
                          ),
                          onPressed: () {
                            cart.removeItem(product);
                            // saveCart is called inside removeItem()
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
      bottomNavigationBar: items.isEmpty
          ? null
          : Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CheckoutPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary, // Vibrant indigo
                  foregroundColor: AppColors.textOnPrimary, // White text
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2, // Subtle shadow
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter',
                  ),
                ),
                child: const Text('Checkout'),
              ),
            ),
    );
  }
}