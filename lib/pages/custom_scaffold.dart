import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'custom_app_bar.dart';

class CustomScaffold extends StatelessWidget {
  final User? user;
  final Widget body;

  const CustomScaffold({
    super.key,
    required this.user,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(user: user),
      body: body,
    );
  }
}
