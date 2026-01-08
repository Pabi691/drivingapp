import 'package:flutter/material.dart';

class EnquiriesScreen extends StatelessWidget {
  const EnquiriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> enquiries = [
      'Enquiry from John Doe about automatic lessons',
      'Enquiry from Jane Smith about pricing',
      'Enquiry from Peter Jones about availability',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Enquiries'),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView.builder(
        itemCount: enquiries.length,
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
                child: Icon(Icons.message, color: Colors.white),
              ),
              title: Text(enquiries[index]),
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
