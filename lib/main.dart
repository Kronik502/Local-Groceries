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
import 'pages/chat_list_page.dart';

// Main layout
import 'main_page.dart';

// Cart model
import 'pages/cart_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("✅ Firebase initialized successfully");
  } catch (e) {
    print("❌ Firebase initialization failed: $e");
  }

  final cartModel = CartModel();
  await cartModel.loadCart();

  runApp(MyApp(cartModel: cartModel));
}

class AppRoutes {
  static const intro = '/intro';
  static const login = '/login';
  static const signup = '/signup';
  static const main = '/main';
  static const shop = '/shop';
  static const cart = '/cart';
  static const profile = '/profile';
  static const chat = '/chat';
}

class MyApp extends StatelessWidget {
  final CartModel cartModel;

  const MyApp({Key? key, required this.cartModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CartModel>.value(
      value: cartModel,
      child: MaterialApp(
        title: 'Local Groceries',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.green,
        ),

        // Use home instead of initialRoute to dynamically show based on auth state
        home: const AuthStateHandler(),

        // Define routes
        routes: {
          AppRoutes.intro: (context) => const IntroPage(),
          AppRoutes.login: (context) => const LoginPage(),
          AppRoutes.signup: (context) => const SignUpPage(),
          AppRoutes.main: (context) => MainPage(user: FirebaseAuth.instance.currentUser),
          AppRoutes.shop: (context) => const ShoppingPage(),
          AppRoutes.cart: (context) => CartPage(),
          AppRoutes.profile: (context) => const ProfilePage(),
          AppRoutes.chat: (context) => const ChatListPage(),
        },
      ),
    );
  }
}

class AuthStateHandler extends StatelessWidget {
  const AuthStateHandler({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // While waiting for Firebase to restore auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // User is signed in
        if (snapshot.hasData && snapshot.data != null) {
          return MainPage(user: snapshot.data);
        }

        // User is NOT signed in
        return const IntroPage();
      },
    );
  }
}
