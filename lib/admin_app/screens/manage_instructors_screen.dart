import 'package:flutter/material.dart';

class ManageInstructorsScreen extends StatelessWidget {
  const ManageInstructorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> instructors = [
      'John Doe',
      'Jane Smith',
      'Peter Jones',
      'Mary Williams',
      'David Brown',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Instructors'),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView.builder(
        itemCount: instructors.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            elevation: 2.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16.0),
              leading: const CircleAvatar(
                backgroundColor: Colors.deepPurple,
                child: Icon(Icons.person, color: Colors.white),
              ),
              title: Text(
                instructors[index],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text('View'),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add),
      ),
    );
  }
}
