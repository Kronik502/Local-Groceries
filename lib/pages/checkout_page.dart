import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../styles/colors.dart';
import 'payment_page.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();

  String _fullName = '';
  String _surname = '';
  String _phone = '';
  String _whatsapp = '';
  bool _sameWhatsapp = true;
  String _street1 = '';
  String _street2 = '';
  String _township = '';
  String _postalCode = '';
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists) {
          final data = doc.data()!;
          setState(() {
            _fullName = data['fullName'] ?? '';
            _surname = data['surname'] ?? '';
         
            _phone = data['phone'] ?? '';
            _whatsapp = data['whatsapp'] ?? '';
            _sameWhatsapp = data['sameWhatsapp'] ?? true;
            _street1 = data['street1'] ?? '';
            _street2 = data['street2'] ?? '';
            _township = data['township'] ?? '';
            _postalCode = data['postalCode'] ?? '';
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = 'No user data found.';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'User not logged in.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading user data: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ListView(
                  children: [
                    const Text(
                      'Enter your details',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Full Name
                    TextFormField(
                      initialValue: _fullName,
                      decoration: const InputDecoration(labelText: 'Full Name'),
                      validator: (value) => value == null || value.isEmpty ? 'Enter your name' : null,
                      onSaved: (value) => _fullName = value!,
                    ),
                    const SizedBox(height: 12),

                    // Surname
                    TextFormField(
                      initialValue: _surname,
                      decoration: const InputDecoration(labelText: 'Surname'),
                      validator: (value) => value == null || value.isEmpty ? 'Enter your surname' : null,
                      onSaved: (value) => _surname = value!,
                    ),
                    const SizedBox(height: 12),

                

                    // Phone Number
                    TextFormField(
                      keyboardType: TextInputType.phone,
                      initialValue: _phone,
                      decoration: const InputDecoration(labelText: 'Phone Number'),
                      validator: (value) =>
                          value == null || value.length < 10 ? 'Enter a valid phone number' : null,
                      onSaved: (value) => _phone = value!,
                    ),
                    const SizedBox(height: 12),

                    // WhatsApp Checkbox
                    CheckboxListTile(
                      value: _sameWhatsapp,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _sameWhatsapp = value;
                          });
                        }
                      },
                      title: const Text("Use same number for WhatsApp"),
                    ),

                    // WhatsApp Number (if not same)
                    if (!_sameWhatsapp)
                      TextFormField(
                        initialValue: _whatsapp,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(labelText: 'WhatsApp Number'),
                        validator: (value) => value == null || value.isEmpty ? 'Enter your WhatsApp number' : null,
                        onSaved: (value) => _whatsapp = value!,
                      ),

                    const SizedBox(height: 12),

                    // Street Address 1
                    TextFormField(
                      initialValue: _street1,
                      decoration: const InputDecoration(labelText: 'Street Address 1'),
                      onSaved: (value) => _street1 = value!,
                    ),
                    const SizedBox(height: 12),

                    // Street Address 2
                    TextFormField(
                      initialValue: _street2,
                      decoration: const InputDecoration(labelText: 'Street Address 2'),
                      onSaved: (value) => _street2 = value!,
                    ),
                    const SizedBox(height: 12),

                    // Township
                    TextFormField(
                      initialValue: _township,
                      decoration: const InputDecoration(labelText: 'Township'),
                      onSaved: (value) => _township = value!,
                    ),
                    const SizedBox(height: 12),

                    // Postal Code
                    TextFormField(
                      initialValue: _postalCode,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Postal Code'),
                      onSaved: (value) => _postalCode = value!,
                    ),
                    const SizedBox(height: 30),

                    // Continue to Payment Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const PaymentPage()),
                          );
                        }
                      },
                      child: const Text(
                        'Continue to Payment',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),

                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}
