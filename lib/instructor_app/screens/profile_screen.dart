import 'package:provider/provider.dart';
import '../auth/auth_provider.dart';
import 'package:flutter/material.dart';
import '../services/profile_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool loading = true;
  bool _initialized = false;
  Map profile = {};
  List workingDays = [];

  // ✅ ADD THIS METHOD HERE (INSIDE CLASS)
  String dayName(int day) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    if (day < 1 || day > 7) return 'Unknown';
    return days[day - 1];
  }

  @override
    void didChangeDependencies() {
      super.didChangeDependencies();
      if (_initialized) return;
      final instructorId = context.read<AuthProvider>().instructorId;
      if (instructorId != null ) {
          _initialized = true;
          _loadData(instructorId);
      }
    }

  Future<void> _editWorkingHour(int index) async {
    final day = workingDays[index];

    final startCtrl = TextEditingController(text: day['start_time']);
    final endCtrl = TextEditingController(text: day['end_time']);
    final breakStartCtrl =
        TextEditingController(text: day['break_start']);
    final breakEndCtrl =
        TextEditingController(text: day['break_end']);

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('${dayName(day['day_of_week'])}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _timeField('Start', startCtrl),
            _timeField('End', endCtrl),
            _timeField('Break Start', breakStartCtrl),
            _timeField('Break End', breakEndCtrl),
          ],
        ),
        actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              workingDays[index] = {
                ...day,
                "start_time": startCtrl.text,
                "end_time": endCtrl.text,
                "break_start": breakStartCtrl.text,
                "break_end": breakEndCtrl.text,
              };
            });

            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
      ),
    );
  }

  Future<void> _loadData(String instructorId) async {
    final p = await ProfileService.getProfile(instructorId);
    final days = await ProfileService.getWorkingDays(instructorId);

    // 🔥 First-time instructor → backend already auto-creates 7 days
    // If not, backend should handle this (BEST PRACTICE)

    if (!mounted) return;

    setState(() {
      profile = p['data'];
      workingDays = days;
      loading = false;
    });
  }

  Future<void> _saveWorkingSchedule() async {
    final instructorId = context.read<AuthProvider>().instructorId;

    final Map<String, dynamic> payload = {
      "instructor_id": instructorId,
      "workingDays": {}
    };

    for (final day in workingDays) {
      final isEnabled = day['is_working'] == 1;

      payload["workingDays"][day['day_of_week'].toString()] = {
        "enabled": isEnabled,

        if (isEnabled) ...{
          "workStart": day['start_time'],
          "workEnd": day['end_time'],
          "breakStart": day['break_start'],
          "breakEnd": day['break_end'],
        }
      };
    }

    await ProfileService.upsertWorkingDays(payload);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Schedule saved')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final instructorId = context.watch<AuthProvider>().instructorId;

    if (instructorId == null) {
        return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
        );
    }

    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionTitle('Personal Info'),
          _tile(Icons.person, 'Name', profile['name']),
          _tile(Icons.email, 'Email', profile['email']),
          _tile(Icons.phone, 'Mobile', profile['mobile']),
          _tile(Icons.home, 'Address', profile['full_address']),
          _tile(Icons.info, 'Bio', profile['instructor_bio']),

          const SizedBox(height: 24),
          _sectionTitle('Working Schedule'),

          ...workingDays.map((day) {
            final index = workingDays.indexOf(day);
            final isWorking = day['is_working'] == 1;

            return Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          dayName(day['day_of_week']),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Switch(
                          value: isWorking,
                          onChanged: (val) {
                            setState(() {
                              day['is_working'] = val ? 1 : 0;
                            });
                          },
                        ),
                      ],
                    ),

                    if (isWorking) ...[
                      Text(
                        'Time: ${day['start_time']} - ${day['end_time']}',
                      ),
                      Text(
                        'Break: ${day['break_start']} - ${day['break_end']}',
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          icon: const Icon(Icons.edit),
                          label: const Text('Edit'),
                          onPressed: () => _editWorkingHour(index),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }).toList(),

          /// 👇👇 ADD THIS PART EXACTLY HERE 👇👇
            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: _saveWorkingSchedule,
              icon: const Icon(Icons.save),
              label: const Text('Save Working Schedule'),
            ),

        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _tile(IconData icon, String title, String value) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }

  Widget _timeField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

}
