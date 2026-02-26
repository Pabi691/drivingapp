import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../auth/auth_provider.dart';
import 'package:flutter/material.dart';
import '../services/profile_service.dart';
import 'package:image_picker/image_picker.dart';

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

  /// Parses a time string like "08:00" or "8:00" into a TimeOfDay.
  TimeOfDay _parseTime(String? timeStr) {
    if (timeStr == null || timeStr.trim().isEmpty) {
      return const TimeOfDay(hour: 9, minute: 0);
    }
    final parts = timeStr.trim().split(':');
    if (parts.length >= 2) {
      final hour = int.tryParse(parts[0]) ?? 9;
      final minute = int.tryParse(parts[1]) ?? 0;
      return TimeOfDay(hour: hour, minute: minute);
    }
    return const TimeOfDay(hour: 9, minute: 0);
  }

  /// Formats a TimeOfDay into "HH:mm" string.
  String _formatTime(TimeOfDay time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _editWorkingHour(int index) async {
    final day = workingDays[index];

    TimeOfDay startTime = _parseTime(day['start_time']);
    TimeOfDay endTime = _parseTime(day['end_time']);
    TimeOfDay breakStart = _parseTime(day['break_start']);
    TimeOfDay breakEnd = _parseTime(day['break_end']);

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          Future<void> pickTime(String label, TimeOfDay initial, ValueChanged<TimeOfDay> onPicked) async {
            final picked = await showTimePicker(
              context: dialogContext,
              initialTime: initial,
              helpText: 'Select $label',
              builder: (context, child) {
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                  child: child!,
                );
              },
            );
            if (picked != null) {
              setDialogState(() => onPicked(picked));
            }
          }

          return AlertDialog(
            title: Text(dayName(day['day_of_week'])),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _timePickerTile('Start Time', startTime, (t) => pickTime('Start Time', startTime, (v) => startTime = v)),
                _timePickerTile('End Time', endTime, (t) => pickTime('End Time', endTime, (v) => endTime = v)),
                const Divider(),
                _timePickerTile('Break Start', breakStart, (t) => pickTime('Break Start', breakStart, (v) => breakStart = v)),
                _timePickerTile('Break End', breakEnd, (t) => pickTime('Break End', breakEnd, (v) => breakEnd = v)),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    workingDays[index] = {
                      ...day,
                      "start_time": _formatTime(startTime),
                      "end_time": _formatTime(endTime),
                      "break_start": _formatTime(breakStart),
                      "break_end": _formatTime(breakEnd),
                    };
                  });
                  Navigator.pop(dialogContext);
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _loadData(String instructorId) async {
    final p = await ProfileService.getProfile(instructorId);
    final days = await ProfileService.getWorkingDays(instructorId);

    if (!mounted) return;

    // Fill in any missing days (1–7) so all 7 are always visible
    final existingDayNumbers = days.map((d) => d['day_of_week']).toSet();
    for (int i = 1; i <= 7; i++) {
      if (!existingDayNumbers.contains(i)) {
        days.add({
          'day_of_week': i,
          'is_working': 0,
          'start_time': null,
          'end_time': null,
          'break_start': null,
          'break_end': null,
        });
      }
    }
    // Sort by day_of_week so Mon=1 … Sun=7
    days.sort((a, b) => (a['day_of_week'] as int).compareTo(b['day_of_week'] as int));

    setState(() {
      profile = p['data'];
      workingDays = days;
      loading = false;
    });
  }

  Future<void> _editProfile() async {
    final instructorId = context.read<AuthProvider>().instructorId;
    if (instructorId == null) return;

    final formKey = GlobalKey<FormState>();

    String getVal(String key) {
      final val = _text(profile[key]);
      return val == '-' ? '' : val;
    }

    String getDateVal(String key) {
      final val = _dateText(profile[key]);
      return val == '-' ? '' : val;
    }

    final nameCtrl = TextEditingController(text: getVal('name'));
    final emailCtrl = TextEditingController(text: getVal('email'));
    final mobileCtrl = TextEditingController(text: getVal('mobile'));
    final addressCtrl = TextEditingController(text: getVal('full_address'));
    final bioCtrl = TextEditingController(text: getVal('instructor_bio'));
    
    final licenceNoCtrl = TextEditingController(text: getVal('driving_lichence_number'));
    final licenceExpiryCtrl = TextEditingController(text: getDateVal('licence_expiry_date'));
    final badgeNoCtrl = TextEditingController(text: getVal('pdi_badge_number'));
    final badgeExpiryCtrl = TextEditingController(text: getDateVal('badge_expiry_date'));
    final experienceCtrl = TextEditingController(text: getVal('experience'));

    String transmissionType = getVal('transmission_type');
    if (transmissionType.isEmpty || !['Manual', 'Automatic', 'Both'].contains(transmissionType)) {
      transmissionType = 'Manual';
    }

    XFile? selectedProfileImage;

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Update Profile'),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () async {
                        final picker = ImagePicker();
                        final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                        if (image != null) {
                          setDialogState(() => selectedProfileImage = image);
                        }
                      },
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.grey.shade300,
                        child: selectedProfileImage == null
                            ? const Icon(Icons.add_a_photo, size: 30, color: Colors.black54)
                            : const Icon(Icons.check, size: 30, color: Colors.green),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (selectedProfileImage != null)
                      Text('Selected: ${selectedProfileImage!.name}', style: const TextStyle(fontSize: 12)),
                    const SizedBox(height: 12),
                    _formField('Name', nameCtrl, isRequired: true),
                    _formField('Email', emailCtrl, isRequired: true,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter Email';
                        }
                        final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$');
                        if (!emailRegex.hasMatch(value.trim())) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    _formField('Mobile', mobileCtrl, isRequired: true,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter Mobile';
                        }
                        final cleaned = value.trim().replaceAll(RegExp(r'[\s\-\(\)\+]'), '');
                        if (!RegExp(r'^\d{7,15}$').hasMatch(cleaned)) {
                          return 'Please enter a valid mobile number (7-15 digits)';
                        }
                        return null;
                      },
                    ),
                    _formField('Address', addressCtrl, isRequired: true),
                    _formField('Bio', bioCtrl, isRequired: true),
                    
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: DropdownButtonFormField<String>(
                        value: transmissionType,
                        decoration: const InputDecoration(
                          labelText: 'Transmission Type',
                          border: OutlineInputBorder(),
                        ),
                        validator: (val) => val == null || val.isEmpty ? 'Please select Transmission Type' : null,
                        items: ['Manual', 'Automatic', 'Both'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                        onChanged: (val) {
                          if (val != null) setDialogState(() => transmissionType = val);
                        },
                      ),
                    ),

                    _formField('Driving Licence Number', licenceNoCtrl, isRequired: true),
                    _formField('Licence Expiry (YYYY-MM-DD)', licenceExpiryCtrl, isRequired: true),
                    _formField('PDI Badge Number', badgeNoCtrl, isRequired: true),
                    _formField('Badge Expiry (YYYY-MM-DD)', badgeExpiryCtrl, isRequired: true),
                    _formField('Experience', experienceCtrl, isRequired: true),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;

                  final payload = <String, String>{
                    'name': nameCtrl.text.trim(),
                    'email': emailCtrl.text.trim(),
                    'mobile': mobileCtrl.text.trim(),
                    'full_address': addressCtrl.text.trim(),
                    'instructor_bio': bioCtrl.text.trim(),
                    'transmission_type': transmissionType,
                    'driving_lichence_number': licenceNoCtrl.text.trim(),
                    'licence_expiry_date': licenceExpiryCtrl.text.trim(),
                    'pdi_badge_number': badgeNoCtrl.text.trim(),
                    'badge_expiry_date': badgeExpiryCtrl.text.trim(),
                    'experience': experienceCtrl.text.trim(),
                  };

                  Navigator.pop(context);
                  setState(() => _savingProfile = true);

                  try {
                    List<int>? profileBytes;
                    String? profileFilename;
                    if (selectedProfileImage != null) {
                      profileBytes = await selectedProfileImage!.readAsBytes();
                      profileFilename = selectedProfileImage!.name;
                    }

                    await ProfileService.updateProfileMultipart(
                      instructorId, 
                      payload,
                      profileBytes: profileBytes,
                      profileFilename: profileFilename,
                    );
                    await _loadData(instructorId);

                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Profile updated')),
                    );
                  } catch (e) {
                    if (!mounted) return;
                    final errorMsg = e.toString().replaceAll('Exception: ', '');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Update failed: $errorMsg'), backgroundColor: Colors.red),
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
          );
        }
      ),
    );
  }

  Future<void> _saveWorkingSchedule() async {
    final instructorId = context.read<AuthProvider>().instructorId;
    debugPrint('🟡 [SaveSchedule] instructorId = $instructorId');

    if (instructorId == null) {
      debugPrint('🔴 [SaveSchedule] instructorId is null — aborting');
      return;
    }

    final Map<String, dynamic> payload = {
      "instructor_id": instructorId,
      "workingDays": {}
    };

    for (final day in workingDays) {
      final isEnabled = day['is_working'] == 1;
      debugPrint('🟡 [SaveSchedule] day=${day['day_of_week']}, isWorking=$isEnabled, start=${day['start_time']}, end=${day['end_time']}, breakStart=${day['break_start']}, breakEnd=${day['break_end']}');

      payload["workingDays"][day['day_of_week'].toString()] = {
        "is_working": isEnabled,
        if (isEnabled) ...{
          "workStart": day['start_time'],
          "workEnd": day['end_time'],
          "breakStart": day['break_start'],
          "breakEnd": day['break_end'],
        }
      };
    }

    debugPrint('🟢 [SaveSchedule] Final payload: $payload');

    try {
      await ProfileService.upsertWorkingDays(payload);
      debugPrint('✅ [SaveSchedule] upsertWorkingDays completed successfully');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Schedule saved')),
      );
    } catch (e, stackTrace) {
      debugPrint('🔴 [SaveSchedule] ERROR: $e');
      debugPrint('🔴 [SaveSchedule] StackTrace: $stackTrace');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Schedule save failed: ${e.toString().replaceAll("Exception: ", "")}'),
          backgroundColor: Colors.red,
        ),
      );
    }
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

  Widget _formField(String label, TextEditingController controller, {
    bool isRequired = false,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator ?? (value) {
          if (isRequired && (value == null || value.trim().isEmpty)) {
            return 'Please enter $label';
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          errorBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red, width: 1.5),
          ),
          focusedErrorBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _timePickerTile(String label, TimeOfDay time, ValueChanged<TimeOfDay> onTap) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      trailing: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => onTap(time),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.access_time, size: 18, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                _formatTime(time),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
