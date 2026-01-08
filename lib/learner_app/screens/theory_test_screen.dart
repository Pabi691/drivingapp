import 'package:flutter/material.dart';

class TheoryTestScreen extends StatelessWidget {
  const TheoryTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Theory Test Practice')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Icon(Icons.school, size: 100, color: Colors.grey),
              const SizedBox(height: 20),
              Text(
                'Practice for your theory test with mock exams and exercises.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Navigate to theory test practice module
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start Practice'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
