import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    }

    void _decreaseQty(String product) {
      if (items[product]! > 1) {
        cart.addItem(product, -1); // subtract 1
      } else {
        cart.removeItem(product);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
        backgroundColor: Colors.brown,
      ),
      body: items.isEmpty
          ? const Center(
              child: Text(
                'Your cart is empty',
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: items.entries.map((entry) {
                final product = entry.key;
                final quantity = entry.value;

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
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
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.brown,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  // Decrease button
                                  IconButton(
                                    icon: const Icon(
                                        Icons.remove_circle_outline,
                                        color: Colors.brown),
                                    onPressed: () => _decreaseQty(product),
                                  ),

                                  // Quantity display
                                  Text(
                                    '$quantity',
                                    style: const TextStyle(fontSize: 18),
                                  ),

                                  // Increase button
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline,
                                        color: Colors.brown),
                                    onPressed: () => _increaseQty(product),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Remove item button
                        IconButton(
                          icon: const Icon(Icons.delete_forever, color: Colors.red),
                          onPressed: () {
                            cart.removeItem(product);
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
                  backgroundColor: Colors.brown,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Checkout',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
            ),
    );
  }
}
