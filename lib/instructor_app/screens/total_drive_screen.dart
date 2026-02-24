
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../auth/auth_provider.dart';
import '../providers/booking_provider.dart';
import '../providers/pupil_provider.dart';

class TotalDriveScreen extends StatefulWidget {
  final DateTime selectedDate;
  final int selectedHour;
  final int initialTabIndex;

  const TotalDriveScreen({
    super.key,
    required this.selectedDate,
    required this.selectedHour,
    this.initialTabIndex = 0,
  });

  @override
  State<TotalDriveScreen> createState() => _TotalDriveScreenState();
}

class _TotalDriveScreenState extends State<TotalDriveScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late DateTime _date;
  late TimeOfDay _time;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: widget.initialTabIndex);
    _date = widget.selectedDate;
    _time = TimeOfDay(hour: widget.selectedHour, minute: 0);

    // Ensure pupils are loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pupilProvider = context.read<PupilProvider>();
      if (pupilProvider.pupils.isEmpty) {
        pupilProvider.fetchPupils();
      }
    });
  }
  

  String? _selectedPupilId;
  int _durationInMinutes = 60;
  bool _isLoading = false;
  bool _showLessonAdvanced = false;
  bool _showGapAdvanced = false;
  bool _showAwayAdvanced = false;
  String _repeat = 'no repeat';
  String _gearbox = 'manual';
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _dropoffController = TextEditingController();
  final TextEditingController _privateNotesController = TextEditingController();
  final TextEditingController _pupilSummaryController = TextEditingController();

  @override
  void dispose() {
    _tabController.dispose();
    _pickupController.dispose();
    _dropoffController.dispose();
    _privateNotesController.dispose();
    _pupilSummaryController.dispose();
    super.dispose();
  }

  void _saveEvent() async {
    if (_tabController.index != 0) {
      // TODO: Handle Gap/Away saving if API supports it
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Only Lessons supported via API for now')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final instructorId = context.read<AuthProvider>().instructorId;
      if (instructorId == null) throw Exception('Instructor not logged in');

      final dateStr = DateFormat('yyyy-MM-dd').format(_date);
      final startHour = _time.hour.toString().padLeft(2, '0');
      final startMinute = _time.minute.toString().padLeft(2, '0');
      final formattedStartTime = '$startHour:$startMinute';
      
      // Calculate End Time
      final startDateTime = DateTime(_date.year, _date.month, _date.day, _time.hour, _time.minute);
      final endDateTime = startDateTime.add(Duration(minutes: _durationInMinutes));
      final endHour = endDateTime.hour.toString().padLeft(2, '0');
      final endMinute = endDateTime.minute.toString().padLeft(2, '0');
      final formattedEndTime = '$endHour:$endMinute';

      final bookingData = {
        "pupil_id": _selectedPupilId ?? '',
        "instructor_id": instructorId,
        "title": "Lesson",
        "booking_date": dateStr,
        "start_time": formattedStartTime,
        "end_time": formattedEndTime,
        "repeat": _repeat,
        "gearbox": _gearbox,
        "pickup": _pickupController.text.trim(),
        "dropoff": _dropoffController.text.trim(),
        "private_notes": _privateNotesController.text.trim(),
        "pupil_summary": _pupilSummaryController.text.trim(),
        "status": "booking_request",
        "payment_status": "pending",
        "payment_type": "cash",
      };

      await context.read<BookingProvider>().createBooking(bookingData);

      if (mounted) {
        Navigator.pop(context); // Close screen
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking created successfully')));
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
       if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Total Drive'),
        actions: [
          if (_isLoading)
            const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator(color: Colors.white)))
          else
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _saveEvent,
            ),
        ],
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Lesson'),
              Tab(text: 'Gap'),
              Tab(text: 'Away'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildLessonTab(),
                _buildGapTab(),
                _buildAwayTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonTab() {
    // Access pupils from provider
    final pupils = context.watch<PupilProvider>().activePupils;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            initialValue: _selectedPupilId,
            decoration: const InputDecoration(
              labelText: 'Pupil',
              border: OutlineInputBorder(),
            ),
            items: pupils.map<DropdownMenuItem<String>>((p) {
              return DropdownMenuItem(
                value: p['_id'],
                child: Text(p['full_name'] ?? 'Unnamed'),
              );
            }).toList(),
            onChanged: (val) => setState(() => _selectedPupilId = val),
          ),
          const SizedBox(height: 16),
          _buildDateTimeField(label: 'Date', value: DateFormat.yMMMMd().format(_date)),
          const SizedBox(height: 16),
          _buildDateTimeField(label: 'Start Time', value: _time.format(context)),
          const SizedBox(height: 16),
          _buildDurationField(),
          const SizedBox(height: 16),
          _buildDropdownField(
            label: 'Repeat',
            value: _repeat,
            items: const ['no repeat', 'repeat'],
            onChanged: (val) {
              if (val != null) setState(() => _repeat = val);
            },
          ),
          const SizedBox(height: 24),
          _buildAdvancedOptionsToggle('Lesson'),
          if (_showLessonAdvanced) _buildAdvancedLessonOptions(),
        ],
      ),
    );
  }

  Widget _buildGapTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDateTimeField(label: 'Date', value: DateFormat.yMMMMd().format(_date)),
          const SizedBox(height: 16),
          _buildDateTimeField(label: 'Start Time', value: _time.format(context)),
          const SizedBox(height: 16),
          _buildDurationField(),
          const SizedBox(height: 16),
          _buildDropdownField(
            label: 'Gearbox',
            value: _gearbox,
            items: const ['manual', 'automatic'],
            onChanged: (val) {
              if (val != null) setState(() => _gearbox = val);
            },
          ),
          const SizedBox(height: 16),
          _buildDropdownField(label: 'Notify', value: 'Send Notification', items: ['Send Notification']),
          const SizedBox(height: 24),
          _buildAdvancedOptionsToggle('Gap'),
          if (_showGapAdvanced) _buildAdvancedGapOptions(),
        ],
      ),
    );
  }

  Widget _buildAwayTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDateTimeField(label: 'Date', value: DateFormat.yMMMMd().format(_date)),
          const SizedBox(height: 16),
          _buildDateTimeField(label: 'Start Time', value: _time.format(context)),
          const SizedBox(height: 16),
          _buildDateTimeField(label: 'End Time', value: _time.format(context)),
          const SizedBox(height: 24),
          _buildAdvancedOptionsToggle('Away'),
          if (_showAwayAdvanced) _buildAdvancedAwayOptions(),
        ],
      ),
    );
  }

  Widget _buildTextField({required String label, TextEditingController? controller}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildDateTimeField({required String label, required String value}) {
    return Row(
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        const Spacer(),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildDurationField() {
    return Row(
      children: [
        const Text('Duration', style: TextStyle(fontSize: 16)),
        const Spacer(),
        Expanded(
          child: TextFormField(
            initialValue: '$_durationInMinutes',
            keyboardType: TextInputType.number,
            onChanged: (value) {
              _durationInMinutes = int.tryParse(value) ?? 60;
            },
            decoration: const InputDecoration(
              labelText: 'Minutes',
              border: OutlineInputBorder(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    ValueChanged<String?>? onChanged,
  }) {
    return Row(
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        const Spacer(),
        DropdownButton<String>(
          value: value,
          items: items.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildAdvancedOptionsToggle(String type) {
    bool isExpanded = false;
    if (type == 'Lesson') isExpanded = _showLessonAdvanced;
    if (type == 'Gap') isExpanded = _showGapAdvanced;
    if (type == 'Away') isExpanded = _showAwayAdvanced;

    return InkWell(
      onTap: () {
        setState(() {
          if (type == 'Lesson') _showLessonAdvanced = !_showLessonAdvanced;
          if (type == 'Gap') _showGapAdvanced = !_showGapAdvanced;
          if (type == 'Away') _showAwayAdvanced = !_showAwayAdvanced;
        });
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Advanced Options', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
        ],
      ),
    );
  }

  Widget _buildAdvancedLessonOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        _buildDropdownField(
          label: 'Gearbox',
          value: _gearbox,
          items: const ['manual', 'automatic'],
          onChanged: (val) {
            if (val != null) setState(() => _gearbox = val);
          },
        ),
        const SizedBox(height: 16),
        _buildDropdownField(label: 'Type', value: 'Lesson', items: ['Lesson']),
        const SizedBox(height: 16),
        _buildTextField(label: 'Pick-up (optional)', controller: _pickupController),
        const SizedBox(height: 16),
        _buildTextField(label: 'Drop-off (optional)', controller: _dropoffController),
        const SizedBox(height: 16),
        _buildTextField(label: 'Private Notes (optional)', controller: _privateNotesController),
        const SizedBox(height: 16),
        _buildTextField(label: 'Shared Pupil Summary (optional)', controller: _pupilSummaryController),
      ],
    );
  }

  Widget _buildAdvancedGapOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        _buildDropdownField(
          label: 'Repeat',
          value: _repeat,
          items: const ['no repeat', 'repeat'],
          onChanged: (val) {
            if (val != null) setState(() => _repeat = val);
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(label: 'Location (optional)'),
        const SizedBox(height: 16),
        _buildDropdownField(label: 'Send To', value: 'Active Pupils', items: ['Active Pupils']),
      ],
    );
  }

  Widget _buildAdvancedAwayOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        _buildDropdownField(
          label: 'Repeat',
          value: _repeat,
          items: const ['no repeat', 'repeat'],
          onChanged: (val) {
            if (val != null) setState(() => _repeat = val);
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(label: 'Private Notes (optional)'),
      ],
    );
  }
}
