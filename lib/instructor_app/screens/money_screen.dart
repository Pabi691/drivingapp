import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/auth_provider.dart';
import '../providers/money_provider.dart';
import '../providers/pupil_provider.dart';

class MoneyScreen extends StatefulWidget {
  const MoneyScreen({super.key});

  @override
  State<MoneyScreen> createState() => _MoneyScreenState();
}

class _MoneyScreenState extends State<MoneyScreen> {
  static const List<String> _paymentMethods = [
    'cash',
    'card',
    'bank_transfer',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final instructorId = context.read<AuthProvider>().instructorId;
      if (instructorId != null) {
        context.read<MoneyProvider>().fetchMoneyRecords(instructorId);
      }

      final pupilProvider = context.read<PupilProvider>();
      if (pupilProvider.pupils.isEmpty) {
        pupilProvider.fetchPupils();
      }
    });
  }

  Future<void> _refresh() async {
    final instructorId = context.read<AuthProvider>().instructorId;
    if (instructorId != null) {
      await context.read<MoneyProvider>().fetchMoneyRecords(instructorId);
    }
  }

  Future<void> _showAddEditDialog({Map<String, dynamic>? record}) async {
    final instructorId = context.read<AuthProvider>().instructorId;
    if (instructorId == null) return;

    final pupils = context.read<PupilProvider>().activePupils;
    if (record == null && pupils.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No active pupils available')),
      );
      return;
    }

    final formKey = GlobalKey<FormState>();
    String? selectedPupilId = record == null
        ? pupils.first['_id']?.toString()
        : (record['pupil_id'] is Map
              ? record['pupil_id']['_id']?.toString()
              : record['pupil_id']?.toString());
    String paymentMethod =
        record?['payment_method']?.toString() ?? _paymentMethods.first;
    final amountController = TextEditingController(
      text: (record?['amount']?.toString() ?? '').replaceAll('.0', ''),
    );

    final bool isEdit = record != null;

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(isEdit ? 'Edit Money Record' : 'Add Money Record'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isEdit)
                  DropdownButtonFormField<String>(
                    initialValue: selectedPupilId,
                    decoration: const InputDecoration(labelText: 'Pupil'),
                    items: pupils
                        .map<DropdownMenuItem<String>>((pupil) => DropdownMenuItem(
                              value: pupil['_id']?.toString(),
                              child: Text(pupil['full_name']?.toString() ?? 'Unnamed'),
                            ))
                        .toList(),
                    onChanged: (value) => selectedPupilId = value,
                    validator: (value) =>
                        (value == null || value.isEmpty) ? 'Please select pupil' : null,
                  ),
                DropdownButtonFormField<String>(
                  initialValue: _paymentMethods.contains(paymentMethod)
                      ? paymentMethod
                      : _paymentMethods.first,
                  decoration: const InputDecoration(labelText: 'Payment Method'),
                  items: _paymentMethods
                      .map((method) => DropdownMenuItem(
                            value: method,
                            child: Text(method),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) paymentMethod = value;
                  },
                ),
                TextFormField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Amount'),
                  validator: (value) {
                    final amount = double.tryParse(value ?? '');
                    if (amount == null || amount <= 0) return 'Enter valid amount';
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!(formKey.currentState?.validate() ?? false)) return;

                final amount = double.parse(amountController.text.trim());
                final moneyProvider = context.read<MoneyProvider>();
                try {
                  if (isEdit) {
                    await moneyProvider.editMoneyRecord(
                      moneyId: record['_id']?.toString() ?? '',
                      instructorId: instructorId,
                      paymentMethod: paymentMethod,
                      amount: amount,
                    );
                  } else {
                    await moneyProvider.addMoneyRecord(
                      pupilId: selectedPupilId ?? '',
                      instructorId: instructorId,
                      paymentMethod: paymentMethod,
                      amount: amount,
                    );
                  }

                  if (!dialogContext.mounted) return;
                  Navigator.pop(dialogContext, true);
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    amountController.dispose();

    if (saved == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEdit ? 'Money record updated' : 'Money record added',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Money'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _refresh,
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showAddEditDialog(),
            ),
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
    return Consumer2<MoneyProvider, PupilProvider>(
      builder: (context, moneyProvider, pupilProvider, _) {
        if (moneyProvider.isLoading && moneyProvider.records.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (moneyProvider.error != null && moneyProvider.records.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(moneyProvider.error!),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _refresh,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        if (moneyProvider.records.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Add a pupil payment for your income to show'),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _showAddEditDialog(),
                  child: const Text('Add Payment'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: moneyProvider.records.length,
            separatorBuilder: (_, __) => const Divider(height: 0),
            itemBuilder: (context, index) {
              final record = moneyProvider.records[index];
              final pupil = record['pupil_id'];
              final pupilId = pupil is Map
                  ? pupil['_id']?.toString()
                  : pupil?.toString();
              final matchedPupil = pupilProvider.pupils.cast<dynamic>().firstWhere(
                    (p) => p is Map && p['_id']?.toString() == pupilId,
                    orElse: () => null,
                  );
              final pupilName = pupil is Map
                  ? (pupil['full_name']?.toString() ?? 'Unknown')
                  : (matchedPupil is Map
                      ? (matchedPupil['full_name']?.toString() ?? 'Unknown')
                      : 'Unknown');
              final paymentMethod = record['payment_method']?.toString() ?? '-';
              final amount = (record['amount'] as num?)?.toDouble() ?? 0;
              final dateText = record['createdAt']?.toString() ?? '';

              return ListTile(
                title: Text(pupilName),
                subtitle: Text('Method: $paymentMethod${dateText.isNotEmpty ? ' • $dateText' : ''}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      amount.toStringAsFixed(2),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showAddEditDialog(record: record),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
