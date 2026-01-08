import 'package:flutter/material.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payments')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Icon(Icons.payment, size: 100, color: Colors.grey),
              const SizedBox(height: 20),
              Text(
                'View your payment history and make new payments.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Implement payment gateway integration
                },
                icon: const Icon(Icons.credit_card),
                label: const Text('Make a Payment'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
