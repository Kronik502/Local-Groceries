import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import 'styles/colors.dart';
import 'pages/intro_page.dart';
import 'pages/shopping_page.dart';
import 'pages/cart_page.dart';
import 'pages/profile_page.dart';
import 'pages/login_page.dart';
import 'pages/chat_list_page.dart'; // ✅ Correct import
import 'pages/cart_model.dart';
import 'pages/custom_app_bar.dart';

/// Enum to identify tabs without magic numbers
enum TabItem { home, shop, cart, chat, profile, login }

class MainPage extends StatefulWidget {
  final User? user;

  const MainPage({Key? key, required this.user}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late TabItem _currentTab;
  User? _currentUser;
  late final StreamSubscription<User?> _authSubscription;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
    _currentTab = TabItem.home;

    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (!mounted) return;

      final wasLoggedIn = _currentUser != null;
      setState(() {
        _currentUser = user;

        if (wasLoggedIn && user == null) {
          if (_currentTab == TabItem.profile || _currentTab == TabItem.chat) {
            _currentTab = TabItem.home;
          }
        }

        if (!wasLoggedIn && user != null) {
          _currentTab = TabItem.profile;
        }

        if (user != null && _currentTab == TabItem.login) {
          _currentTab = TabItem.profile;
        }
      });
    });
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  void _selectTab(TabItem tab) {
    if ((tab == TabItem.profile || tab == TabItem.chat) && _currentUser == null) {
      setState(() => _currentTab = TabItem.login);
      return;
    }

    if (tab == TabItem.login && _currentUser != null) {
      return;
    }

    setState(() => _currentTab = tab);
  }

  BottomNavigationBarItem _buildCartNavItem(int cartCount) {
    return BottomNavigationBarItem(
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(Icons.shopping_cart, size: 28, color: AppColors.gray),
          if (cartCount > 0)
            Positioned(
              right: -8,
              top: -8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                constraints: const BoxConstraints(
                  minWidth: 20,
                  minHeight: 20,
                ),
                child: Text(
                  '$cartCount',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
      activeIcon: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(Icons.shopping_cart, size: 28, color: AppColors.primary),
          if (cartCount > 0)
            Positioned(
              right: -8,
              top: -8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                constraints: const BoxConstraints(
                  minWidth: 20,
                  minHeight: 20,
                ),
                child: Text(
                  '$cartCount',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter',
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
    final cartCount = context.watch<CartModel>().totalItemsCount;

    final pages = <TabItem, Widget>{
      TabItem.home: const IntroPage(key: ValueKey('IntroPage')),
      TabItem.shop: const ShoppingPage(key: ValueKey('ShoppingPage')),
      TabItem.cart: CartPage(key: const ValueKey('CartPage')),
      TabItem.chat: const ChatListPage(), // ✅ Fixed: no undefined ChatPage
      TabItem.profile: ProfilePage(
        key: const ValueKey('ProfilePage'),
        user: _currentUser,
      ),
      TabItem.login: const LoginPage(key: ValueKey('LoginPage')),
    };

    final navItems = <TabItem, BottomNavigationBarItem>{
      TabItem.home: BottomNavigationBarItem(
        icon: Icon(Icons.home, size: 28, color: AppColors.gray),
        activeIcon: Icon(Icons.home, size: 28, color: AppColors.primary),
        label: 'Home',
      ),
      TabItem.shop: BottomNavigationBarItem(
        icon: Icon(Icons.store, size: 28, color: AppColors.gray),
        activeIcon: Icon(Icons.store, size: 28, color: AppColors.primary),
        label: 'Shop',
      ),
      TabItem.cart: _buildCartNavItem(cartCount),
      TabItem.chat: BottomNavigationBarItem(
        icon: Icon(Icons.chat_rounded, size: 28, color: AppColors.gray),
        activeIcon: Icon(Icons.chat_rounded, size: 28, color: AppColors.primary),
        label: 'Chat',
      ),
      TabItem.profile: BottomNavigationBarItem(
        icon: Icon(Icons.person, size: 28, color: AppColors.gray),
        activeIcon: Icon(Icons.person, size: 28, color: AppColors.primary),
        label: 'Profile',
      ),
      TabItem.login: BottomNavigationBarItem(
        icon: Icon(Icons.login, size: 28, color: AppColors.gray),
        activeIcon: Icon(Icons.login, size: 28, color: AppColors.primary),
        label: 'Login',
      ),
    };

    final visibleTabs = [
      TabItem.home,
      TabItem.shop,
      TabItem.cart,
      TabItem.chat,
      TabItem.profile,
      if (_currentUser == null) TabItem.login,
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(user: _currentUser),
      body: SafeArea(
        child: IndexedStack(
          index: visibleTabs.indexOf(_currentTab),
          children: visibleTabs.map((tab) => pages[tab]!).toList(),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: visibleTabs.indexOf(_currentTab),
        onTap: (index) => _selectTab(visibleTabs[index]),
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.cardBackground,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.gray,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          fontFamily: 'Inter',
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 14,
          fontFamily: 'Inter',
        ),
        elevation: 8,
        items: visibleTabs.map((tab) => navItems[tab]!).toList(),
      ),
    );
  }
}
