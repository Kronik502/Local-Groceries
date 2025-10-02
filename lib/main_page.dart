import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'dart:async'; 
import 'pages/intro_page.dart';
import 'pages/shopping_page.dart';
import 'pages/cart_page.dart';
import 'pages/profile_page.dart';
import 'pages/cart_model.dart';

class MainPage extends StatefulWidget {
  final User? user;  // Current logged-in user, can be null
  final int initialIndex; // Initial tab index

  const MainPage({Key? key, this.user, this.initialIndex = 0}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late int _selectedIndex;
  User? _currentUser;
  late final StreamSubscription<User?> _authSubscription;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _currentUser = widget.user;

    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (mounted) {
        setState(() {
          _currentUser = user;
          // If logged out while on Profile tab, redirect to Home tab
          if (_selectedIndex == 3 && _currentUser == null) {
            _selectedIndex = 0;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

 List<Widget> get _pages => [
  const IntroPage(key: ValueKey('IntroPage')),
  const ShoppingPage(key: ValueKey('ShoppingPage')),
  CartPage(key: const ValueKey('CartPage')),  // remove const before CartPage if constructor not const
  ProfilePage(key: const ValueKey('ProfilePage'), user: _currentUser),
];


  Future<void> _handleProfileTap() async {
    final result = await Navigator.pushNamed(context, '/login');
    if (mounted) {
      setState(() {
        _currentUser = FirebaseAuth.instance.currentUser;
        if (_currentUser != null) {
          _selectedIndex = 3;
        }
      });
    }
  }

  void _onItemTapped(int index) {
    if (index == 3 && _currentUser == null) {
      _handleProfileTap();
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  // Build BottomNavigationBarItem with optional badge for cart
  BottomNavigationBarItem _buildCartNavItem(int cartCount) {
    return BottomNavigationBarItem(
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(Icons.shopping_cart),
          if (cartCount > 0)
            Positioned(
              right: -6,
              top: -6,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                constraints: const BoxConstraints(
                  minWidth: 18,
                  minHeight: 18,
                ),
                child: Text(
                  '$cartCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
      label: 'Cart',
    );
  }

  @override
  Widget build(BuildContext context) {
    // Listen to cart changes
    final cartCount = context.watch<CartModel>().totalItemsCount;

    final navItems = <BottomNavigationBarItem>[
      const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      const BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Shop'),
      _buildCartNavItem(cartCount),
      const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: navItems,
      ),
    );
  }
}
