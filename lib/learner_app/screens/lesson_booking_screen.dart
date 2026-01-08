import 'package:flutter/material.dart';

class LessonBookingScreen extends StatelessWidget {
  const LessonBookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book a Lesson')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Icon(Icons.calendar_today, size: 100, color: Colors.grey),
              const SizedBox(height: 20),
              Text(
                'Choose a date and time for your lesson.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Implement date/time picker
                },
                icon: const Icon(Icons.event),
                label: const Text('Select Date & Time'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
