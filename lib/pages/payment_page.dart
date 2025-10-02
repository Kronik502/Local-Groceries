import 'package:flutter/material.dart';
import '../styles/colors.dart';

class PaymentPage extends StatelessWidget {
  const PaymentPage({super.key});

  final List<Map<String, String>> _banks = const [
    {'name': 'Capitec', 'image': 'capitec.png'},
    {'name': 'Standard Bank', 'image': 'standard.jpg'},
    {'name': 'FNB', 'image': 'fnb.png'},
    {'name': 'Discovery', 'image': 'discovery.png'},
    {'name': 'Nedbank', 'image': 'nedbank.png'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Bank'),
        backgroundColor: AppColors.primary,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _banks.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final bank = _banks[index];

          return ListTile(
            contentPadding: const EdgeInsets.all(12),
            tileColor: AppColors.inputBackground,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: AppColors.primary.withOpacity(0.2)),
            ),
            leading: Image.asset(
              'lib/images/${bank['image']}',
              width: 50,
              height: 50,
              fit: BoxFit.contain,
            ),
            title: Text(
              bank['name']!,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              // Show confirmation or perform transaction logic
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Payment Confirmed'),
                  content: Text('You selected ${bank['name']} for payment.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
