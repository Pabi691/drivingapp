import 'package:flutter/material.dart';

class DocumentUploadScreen extends StatelessWidget {
  const DocumentUploadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Documents')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Icon(Icons.cloud_upload, size: 100, color: Colors.grey),
              const SizedBox(height: 20),
              Text(
                'Upload your driving licence and other required documents.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Implement file picking logic
                },
                icon: const Icon(Icons.attach_file),
                label: const Text('Select File'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
