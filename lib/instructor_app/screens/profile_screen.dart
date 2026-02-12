import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
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
  bool _savingProfile = false;
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
        title: Text(dayName(day['day_of_week'])),
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

  Future<void> _editProfile() async {
    final instructorId = context.read<AuthProvider>().instructorId;
    if (instructorId == null) return;

    final nameCtrl = TextEditingController(text: _text(profile['name']));
    final emailCtrl = TextEditingController(text: _text(profile['email']));
    final mobileCtrl = TextEditingController(text: _text(profile['mobile']));
    final addressCtrl =
        TextEditingController(text: _text(profile['full_address']));
    final bioCtrl =
        TextEditingController(text: _text(profile['instructor_bio']));
    final transmissionCtrl =
        TextEditingController(text: _text(profile['transmission_type']));
    final licenceNoCtrl = TextEditingController(
      text: _text(profile['driving_lichence_number']),
    );
    final licenceExpiryCtrl = TextEditingController(
      text: _dateText(profile['licence_expiry_date']),
    );
    final badgeNoCtrl =
        TextEditingController(text: _text(profile['pdi_badge_number']));
    final badgeExpiryCtrl = TextEditingController(
      text: _dateText(profile['badge_expiry_date']),
    );
    final experienceCtrl =
        TextEditingController(text: _text(profile['experience']));

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Update Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _formField('Name', nameCtrl),
              _formField('Email', emailCtrl),
              _formField('Mobile', mobileCtrl),
              _formField('Address', addressCtrl),
              _formField('Bio', bioCtrl),
              _formField('Transmission Type', transmissionCtrl),
              _formField('Driving Licence Number', licenceNoCtrl),
              _formField('Licence Expiry (YYYY-MM-DD)', licenceExpiryCtrl),
              _formField('PDI Badge Number', badgeNoCtrl),
              _formField('Badge Expiry (YYYY-MM-DD)', badgeExpiryCtrl),
              _formField('Experience', experienceCtrl),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final payload = <String, dynamic>{
                'name': nameCtrl.text.trim(),
                'email': emailCtrl.text.trim(),
                'mobile': mobileCtrl.text.trim(),
                'full_address': addressCtrl.text.trim(),
                'instructor_bio': bioCtrl.text.trim(),
                'transmission_type': transmissionCtrl.text.trim(),
                'driving_lichence_number': licenceNoCtrl.text.trim(),
                'licence_expiry_date': licenceExpiryCtrl.text.trim(),
                'pdi_badge_number': badgeNoCtrl.text.trim(),
                'badge_expiry_date': badgeExpiryCtrl.text.trim(),
                'experience': experienceCtrl.text.trim(),
              };

              Navigator.pop(context);
              setState(() => _savingProfile = true);

              try {
                await ProfileService.updateProfile(instructorId, payload);
                await _loadData(instructorId);

                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile updated')),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Update failed: $e')),
                );
              } finally {
                if (mounted) {
                  setState(() => _savingProfile = false);
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
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

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Schedule saved')),
    );
  }

  Future<void> _openDocument(String url) async {
    final rawUrl = url.trim();
    if (rawUrl.isEmpty || rawUrl == '-') {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Document URL not available')),
      );
      return;
    }

    final uri = Uri.tryParse(rawUrl);
    if (uri == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid document URL')),
      );
      return;
    }

    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open document')),
      );
    }
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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/dashboard');
            }
          },
        ),
        title: const Text('My Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionTitle('Profile Image'),
          _buildProfileImageCard(),

          const SizedBox(height: 12),
          _sectionTitle('Personal Info'),
          _tile(Icons.person, 'Name', _text(profile['name'])),
          _tile(Icons.email, 'Email', _text(profile['email'])),
          _tile(Icons.phone, 'Mobile', _text(profile['mobile'])),
          _tile(Icons.home, 'Address', _text(profile['full_address'])),
          _tile(Icons.info, 'Bio', _text(profile['instructor_bio'])),

          const SizedBox(height: 12),
          _sectionTitle('Driving Details'),
          _tile(
            Icons.sync_alt,
            'Transmission Type',
            _text(profile['transmission_type']),
          ),
          _tile(
            Icons.badge,
            'Driving Licence Number',
            _text(profile['driving_lichence_number']),
          ),
          _tile(
            Icons.calendar_month,
            'Licence Expiry Date',
            _dateText(profile['licence_expiry_date']),
          ),
          _tile(
            Icons.workspace_premium,
            'PDI Badge Number',
            _text(profile['pdi_badge_number']),
          ),
          _tile(
            Icons.event_available,
            'Badge Expiry Date',
            _dateText(profile['badge_expiry_date']),
          ),
          _tile(Icons.timeline, 'Experience', _text(profile['experience'])),

          const SizedBox(height: 12),
          _sectionTitle('Documents'),
          _buildLicenceDocumentCard(),

          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _savingProfile ? null : _editProfile,
            icon: _savingProfile
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.edit),
            label: const Text('Edit Profile Details'),
          ),

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
          }),

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

  Widget _buildProfileImageCard() {
    final profileUrl = _text(profile['profile']);
    final hasProfileImage = profileUrl != '-';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey.shade200,
              backgroundImage:
                  hasProfileImage ? NetworkImage(profileUrl) : null,
              child: hasProfileImage
                  ? null
                  : const Icon(Icons.person, size: 42, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            Text(
              _text(profile['name']),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            TextButton.icon(
              onPressed: hasProfileImage
                  ? () => _openDocument(profileUrl)
                  : null,
              icon: const Icon(Icons.visibility),
              label: const Text('View'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLicenceDocumentCard() {
    final licenceUrl = _text(profile['upload_licence_copy']);
    final hasLicence = licenceUrl != '-';

    return Card(
      child: ListTile(
        leading: const Icon(Icons.description),
        title: const Text('Driving Licence Document'),
        subtitle: Text(hasLicence ? 'Tap view to open document' : 'Not uploaded'),
        trailing: TextButton(
          onPressed: hasLicence ? () => _openDocument(licenceUrl) : null,
          child: const Text('View'),
        ),
      ),
    );
  }

  String _text(dynamic value) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? '-' : text;
  }

  String _dateText(dynamic value) {
    final raw = _text(value);
    if (raw == '-') return raw;
    final split = raw.split('T');
    return split.isNotEmpty ? split.first : raw;
  }

  Widget _formField(String label, TextEditingController controller) {
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
