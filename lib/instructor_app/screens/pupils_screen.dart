
import 'package:flutter/material.dart';

class PupilsScreen extends StatelessWidget {
  const PupilsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pupils'),
          actions: [
            IconButton(icon: const Icon(Icons.search), onPressed: () {}),
            IconButton(icon: const Icon(Icons.add), onPressed: () {}),
          ],
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Active'),
              Tab(text: 'Waiting'),
              Tab(text: 'Inactive'),
              Tab(text: 'Enquiries'),
              Tab(text: 'Passed'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildPupilList(),
            const Center(child: Text('Waiting List')),
            const Center(child: Text('Inactive Pupils')),
            const Center(child: Text('Enquiries')),
            const Center(child: Text('Passed Pupils')),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildPupilList() {
    return ListView(
      children: [
        ListTile(
          leading: const CircleAvatar(
            child: Text('EL'),
          ),
          title: const Text('Example Learner'),
          subtitle: const Text('No Lesson Booked'),
          trailing: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('0 hrs credit', style: TextStyle(color: Colors.green)),
              Icon(Icons.chevron_right),
            ],
          ),
          onTap: () {},
        ),
      ],
    );
  }
}
