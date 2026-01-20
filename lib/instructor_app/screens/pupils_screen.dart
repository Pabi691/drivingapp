import 'package:flutter/material.dart';
import '../services/pupil_service.dart';
import 'add_pupil_screen.dart';
import 'pupil_details_screen.dart';

class PupilsScreen extends StatefulWidget {
  const PupilsScreen({super.key});

  @override
  State<PupilsScreen> createState() => _PupilsScreenState();
}

class _PupilsScreenState extends State<PupilsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pupils'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Add search functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _openAddPupil,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Waiting'),
            Tab(text: 'Inactive'),
            Tab(text: 'Enquiries'),
            Tab(text: 'Passed'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPupilList(status: 'active'),
          _buildPupilList(status: 'waiting'),
          _buildPupilList(status: 'inactive'),
          _buildPupilList(status: 'enquiry'),
          _buildPupilList(status: 'passed'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddPupil,
        child: const Icon(Icons.add),
      ),
    );
  }

  // -------------------------------
  // OPEN ADD PUPIL SCREEN
  // -------------------------------
  Future<void> _openAddPupil() async {
    final added = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddPupilScreen()),
    );

    if (added == true) {
      setState(() {}); // reload list
    }
  }
  // -------------------------------
  // PUPIL LIST (API)
  // -------------------------------
  Widget _buildPupilList({required String status}) {
    return FutureBuilder<List>(
      future: PupilService.getAllPupils(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No pupils found'));
        }

        // Optional status filter (future-ready)
        final pupils = snapshot.data!;

        return ListView.separated(
          itemCount: pupils.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final p = pupils[index];

            final name = p['full_name'] ?? '';
            final phone = p['phone'] ?? '';
            final hours = p['remaining_hour'] ?? 0;

            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue.shade100,
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(name),
              subtitle: Text(phone.isNotEmpty ? phone : 'No lesson booked'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$hours hrs',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PupilDetailsScreen(pupil: p),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
