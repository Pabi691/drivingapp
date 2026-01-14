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
  List workingHours = [];

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

  Future<void> _editWorkingHour(int dayOfWeek, Map hour) async {
    final instructorId = context.read<AuthProvider>().instructorId;

    final startCtrl = TextEditingController(text: hour['start_time']);
    final endCtrl = TextEditingController(text: hour['end_time']);
    final breakStartCtrl =
        TextEditingController(text: hour['break_start']);
    final breakEndCtrl =
        TextEditingController(text: hour['break_end']);

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('${dayName(dayOfWeek)} Time'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _timeField('Start Time', startCtrl),
            _timeField('End Time', endCtrl),
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
            onPressed: () async {
              await ProfileService.createWorkingHour({
                "instructor_id": instructorId,
                "day_of_week": dayOfWeek,
                "start_time": startCtrl.text,
                "end_time": endCtrl.text,
                "break_start": breakStartCtrl.text,
                "break_end": breakEndCtrl.text,
              });

              setState(() {
                final index = workingHours.indexWhere(
                    (h) => h['day_of_week'] == dayOfWeek);
                if (index != -1) {
                  workingHours[index] = {
                    ...workingHours[index],
                    "start_time": startCtrl.text,
                    "end_time": endCtrl.text,
                    "break_start": breakStartCtrl.text,
                    "break_end": breakEndCtrl.text,
                  };
                }
              });

              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateWorkingDay(int dayOfWeek, bool isWorking) async {
  final instructorId = context.read<AuthProvider>().instructorId;

  await ProfileService.createWorkingDay({
    "instructor_id": instructorId,
    "day_of_week": dayOfWeek,
    "is_working": isWorking ? 1 : 0,
  });

  setState(() {
    final index =
        workingDays.indexWhere((d) => d['day_of_week'] == dayOfWeek);
    if (index != -1) {
      workingDays[index]['is_working'] = isWorking ? 1 : 0;
    }
  });
}

  Future<void> _loadData(String instructorId) async {
    final p = await ProfileService.getProfile(instructorId);
    final days = await ProfileService.getWorkingDays(instructorId);
    final hours = await ProfileService.getWorkingHours(instructorId);

    print('Instructor Profile: ${p}');
    print('Working Days: ${days}');
    print('Working Hours: ${hours}');
    // Auto create if empty
    if (days.isEmpty) {
      for (int i = 1; i <= 7; i++) {
        await ProfileService.createWorkingDay({
          "instructor_id": instructorId,
          "day_of_week": i,
          "is_working": i <= 5 ? 1 : 0, // Mon–Fri ON
        });

        await ProfileService.createWorkingHour({
          "instructor_id": instructorId,
          "day_of_week": i,
          "start_time": "09:00",
          "end_time": "18:00",
          "break_start": "13:00",
          "break_end": "14:00",
        });
      }
    }

    if (hours.isEmpty) {
      await ProfileService.createWorkingHour({
        "instructor_id": instructorId,
        "day_of_week": 1,
        "start_time": "09:00",
        "end_time": "18:00",
        "break_start": "13:00",
        "break_end": "14:00"
      });
    }

    /// 🔥 RE-FETCH
    final newDays = await ProfileService.getWorkingDays(instructorId);
    final newHours = await ProfileService.getWorkingHours(instructorId);

    if (!mounted) return;

    setState(() {
      profile = p['data'];
      workingDays = days;
      workingHours = hours;
      loading = false;
    });
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
          final int dayOfWeek = day['day_of_week'];
          final bool isWorking = day['is_working'] == 1;

          Map? hour;
          try {
            hour = workingHours.firstWhere(
              (h) => h['day_of_week'] == dayOfWeek,
            );
          } catch (_) {
            hour = null;
          }

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        dayName(dayOfWeek),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Switch(
                        value: isWorking,
                        onChanged: (val) async {
                          await _updateWorkingDay(dayOfWeek, val);
                        },
                      ),
                    ],
                  ),

                  Text(
                    isWorking ? 'Working Day' : 'Off Day',
                    style: TextStyle(
                      color: isWorking ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  if (isWorking && hour != null) ...[
                    const SizedBox(height: 8),
                    Text('Time: ${hour['start_time']} - ${hour['end_time']}'),
                    Text('Break: ${hour['break_start']} - ${hour['break_end']}'),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit'),
                        onPressed: () {
                          _editWorkingHour(dayOfWeek, hour!);
                        },
                      ),
                    )
                  ],
                ],
              ),
            ),
          );
        }).toList(),

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
