import 'package:flutter/material.dart';

class FeedbackScreen extends StatelessWidget {
  const FeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Feedback')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Icon(Icons.rate_review, size: 100, color: Colors.grey),
              const SizedBox(height: 20),
              Text(
                'View and manage feedback from your students.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Implement feedback viewing UI
                },
                icon: const Icon(Icons.reviews),
                label: const Text('View Feedback'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
