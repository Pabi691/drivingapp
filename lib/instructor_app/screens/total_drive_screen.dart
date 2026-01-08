
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/event.dart';

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
  int _durationInMinutes = 60;

  bool _showLessonAdvanced = false;
  bool _showGapAdvanced = false;
  bool _showAwayAdvanced = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: widget.initialTabIndex);
    _date = widget.selectedDate;
    _time = TimeOfDay(hour: widget.selectedHour, minute: 0);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _saveEvent() {
    final startTime = DateTime(_date.year, _date.month, _date.day, _time.hour, _time.minute);
    final duration = Duration(minutes: _durationInMinutes);
    String title = '';
    Color color = Colors.grey;

    switch (_tabController.index) {
      case 0:
        title = 'Lesson';
        color = Colors.blue;
        break;
      case 1:
        title = 'Gap';
        color = Colors.orange;
        break;
      case 2:
        title = 'Away';
        color = Colors.red;
        break;
    }

    final newEvent = Event(
      title: title,
      startTime: startTime,
      duration: duration,
      color: color,
    );

    setState(() {
      events.add(newEvent);
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Total Drive'),
        actions: [
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(label: 'Pupil'),
          const SizedBox(height: 16),
          _buildDateTimeField(label: 'Date', value: DateFormat.yMMMMd().format(_date)),
          const SizedBox(height: 16),
          _buildDateTimeField(label: 'Start Time', value: _time.format(context)),
          const SizedBox(height: 16),
          _buildDurationField(),
          const SizedBox(height: 16),
          _buildDropdownField(label: 'Repeat', value: 'No Repeat', items: ['No Repeat']),
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
          _buildDropdownField(label: 'Gearbox', value: 'Manual Drive', items: ['Manual Drive']),
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

  Widget _buildTextField({required String label}) {
    return TextFormField(
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

  Widget _buildDropdownField({required String label, required String value, required List<String> items}) {
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
          onChanged: (_) {},
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
        _buildDropdownField(label: 'Gearbox', value: 'Manual Drive', items: ['Manual Drive']),
        const SizedBox(height: 16),
        _buildDropdownField(label: 'Type', value: 'Lesson', items: ['Lesson']),
        const SizedBox(height: 16),
        _buildTextField(label: 'Pick-up (optional)'),
        const SizedBox(height: 16),
        _buildTextField(label: 'Drop-off (optional)'),
        const SizedBox(height: 16),
        _buildTextField(label: 'Private Notes (optional)'),
        const SizedBox(height: 16),
        _buildTextField(label: 'Shared Pupil Summary (optional)'),
      ],
    );
  }

  Widget _buildAdvancedGapOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        _buildDropdownField(label: 'Repeat', value: 'No Repeat', items: ['No Repeat']),
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
        _buildDropdownField(label: 'Repeat', value: 'No Repeat', items: ['No Repeat']),
        const SizedBox(height: 16),
        _buildTextField(label: 'Private Notes (optional)'),
      ],
    );
  }
}
