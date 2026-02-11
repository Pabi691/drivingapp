import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pupil_provider.dart';
// import '../services/pupil_service.dart'; // No longer needed directly checking provider
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
    
            // Fetch pupils once when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PupilProvider>().fetchPupils();
    });
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
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<PupilProvider>().fetchPupils(),
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
            Tab(text: 'All'), // Debugging
            Tab(text: 'Active'),
            Tab(text: 'Waiting'),
            Tab(text: 'Inactive'),
            Tab(text: 'Enquiries'),
            Tab(text: 'Passed'),
          ],
        ),
      ),
      body: Consumer<PupilProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${provider.error}'),
                  ElevatedButton(
                    onPressed: () => provider.fetchPupils(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildPupilList(provider.pupils), // Show all
              _buildPupilList(provider.activePupils),
              _buildPupilList(provider.waitingPupils),
              _buildPupilList(provider.inactivePupils),
              _buildPupilList(provider.enquiryPupils),
              _buildPupilList(provider.passedPupils),
            ],
          );
        },
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

    if (added == true && mounted) {
      context.read<PupilProvider>().fetchPupils();
    }
  }

  // -------------------------------
  // PUPIL LIST (LOCAL)
  // -------------------------------
  Widget _buildPupilList(List<dynamic> pupils) {
    if (pupils.isEmpty) {
      return const Center(child: Text('No pupils found'));
    }

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
  }
}
