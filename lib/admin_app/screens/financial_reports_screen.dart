import 'package:flutter/material.dart';

class FinancialReportsScreen extends StatelessWidget {
  const FinancialReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Financial Reports')),
      body: const Center(child: Text('Financial Reports Screen')),
    );
  }
}
