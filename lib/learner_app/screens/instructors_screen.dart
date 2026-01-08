import 'package:flutter/material.dart';

class InstructorsScreen extends StatelessWidget {
  const InstructorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Find an Instructor')),
      body: const Center(child: Text('Instructors Screen')),
    );
  }
}
