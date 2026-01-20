import 'package:flutter/material.dart';

class PupilDetailsScreen extends StatelessWidget {
    final Map pupil;

    const PupilDetailsScreen({
        super.key,
        required this.pupil,
    });

    @override

    Widget build(BuildContext context) {

        final area = pupil['area_id'];
        final instructor = pupil['instructor_id'];
        final package = pupil['package_id'];

        return Scaffold(
            appBar: AppBar(
                title: const Text('Pupil Details')
            ),
            body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        _header(),
                        const SizedBox(height: 24),

                        _infoTile('Full Name', pupil['full_name']),
                        _infoTile('Phone', pupil['phone']),
                        _infoTile('Email', pupil['email']),
                        _infoTile('Remaining Hours', '${pupil['remaining_hour'] ?? 0} hrs'),
                        _infoTile('Progress', '${pupil['progress']}%'),
                        _infoTile('Payment Status', pupil['payment_status']),
                        _infoTile('Status', pupil['active'] == 1 ? 'Active' : 'Inactive'),

                        const Divider(height: 32),

                        _infoTile('Area', area?['name']),
                        _infoTile('Instructor', instructor?['email']),
                        _infoTile(
                            'Package Duration',
                            package != null ? '${package['duration']} hrs' : 'N/A',
                            ),

                        const SizedBox(height: 40),

                        _actionButtons(context),
                    ],
                ),
            ),
        );
    }
    // -------------------------
  // HEADER
  // -------------------------
  Widget _header() {
    final name = pupil['full_name'] ?? '';

    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: Colors.blue.shade100,
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------
  // INFO ROW
  // -------------------------
  Widget _infoTile(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value ?? '-',
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------
  // ACTION BUTTONS
  // -------------------------
  Widget _actionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.edit),
            label: const Text('Edit'),
            onPressed: () {
              // TODO: Open edit screen
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.delete),
            label: const Text('Delete'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              // TODO: Delete pupil
            },
          ),
        ),
      ],
    );
  }
}