import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

// Firebase options
import 'firebase_options.dart';

// Pages
import 'pages/intro_page.dart';
import 'pages/login_page.dart';
import 'pages/signup_page.dart';
import 'pages/shopping_page.dart';
import 'pages/cart_page.dart';
import 'pages/profile_page.dart';

// Main layout
import 'main_page.dart';

// Cart model
import 'pages/cart_model.dart';  // Add this line

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final User? currentUser = FirebaseAuth.instance.currentUser;

  runApp(MyApp(currentUser: currentUser));
}

/// Route name constants
class AppRoutes {
  static const intro = '/intro';
  static const login = '/login';
  static const signup = '/signup';
  static const main = '/main';
  static const shop = '/shop';
  static const cart = '/cart';
  static const profile = '/profile';
}

class MyApp extends StatelessWidget {
  final User? currentUser;
  const MyApp({Key? key, this.currentUser}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CartModel>(
      create: (_) => CartModel(),
      child: MaterialApp(
        title: 'Local Groceries',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.green,
        ),
  routes: {
  AppRoutes.intro: (context) => const IntroPage(),
  AppRoutes.login: (context) => const LoginPage(),
  AppRoutes.signup: (context) => const SignUpPage(),
  AppRoutes.main: (context) => const MainPage(),
  AppRoutes.shop: (context) => const ShoppingPage(),
  AppRoutes.cart: (context) => CartPage(),   // removed const
  AppRoutes.profile: (context) => const ProfilePage(),
},

        home: MainPage(user: currentUser),
      ),
    );
  }
}
