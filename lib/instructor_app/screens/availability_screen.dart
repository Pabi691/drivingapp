import 'package:flutter/material.dart';

class AvailabilityScreen extends StatelessWidget {
  const AvailabilityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set Availability')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Icon(Icons.event_available, size: 100, color: Colors.grey),
              const SizedBox(height: 20),
              Text(
                'Set your weekly availability for lessons.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Implement availability setting logic
                },
                icon: const Icon(Icons.edit_calendar),
                label: const Text('Update Availability'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
