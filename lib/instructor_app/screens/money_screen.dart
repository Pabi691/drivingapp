
import 'package:flutter/material.dart';

class MoneyScreen extends StatelessWidget {
  const MoneyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Money'),
          actions: [
            IconButton(icon: const Icon(Icons.add), onPressed: () {}),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Income'),
              Tab(text: 'Expenses'),
              Tab(text: 'Mileage'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildIncomeTab(),
            const Center(child: Text('Expenses')),
            const Center(child: Text('Mileage')),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomeTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Add a pupil payment for your income to show'),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }
}
