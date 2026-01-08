
import 'package:flutter/material.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Message'),
          actions: [
            IconButton(icon: const Icon(Icons.add), onPressed: () {}),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Inbox'),
              Tab(text: 'Sent'),
              Tab(text: 'Broadcast'),
              Tab(text: 'News'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            Center(child: Text('There are no messages from your pupils')),
            Center(child: Text('Sent Messages')),
            Center(child: Text('Broadcast Messages')),
            Center(child: Text('News')),
          ],
        ),
      ),
    );
  }
}
