
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../models/event.dart';
import 'total_drive_screen.dart';

class InstructorHomeScreen extends StatefulWidget {
  const InstructorHomeScreen({super.key});

  @override
  State<InstructorHomeScreen> createState() => _InstructorHomeScreenState();
}

class _InstructorHomeScreenState extends State<InstructorHomeScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.week;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDay ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDay) {
      setState(() {
        _selectedDay = picked;
        _focusedDay = picked;
      });
    }
  }

  void _showAddOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.school),
              title: const Text('Add Lesson'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TotalDriveScreen(
                      selectedDate: _selectedDay ?? DateTime.now(),
                      selectedHour: TimeOfDay.now().hour,
                      initialTabIndex: 0,
                    ),
                  ),
                ).then((_) => setState(() {}));
              },
            ),
            ListTile(
              leading: const Icon(Icons.hourglass_empty),
              title: const Text('Add Gap'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TotalDriveScreen(
                      selectedDate: _selectedDay ?? DateTime.now(),
                      selectedHour: TimeOfDay.now().hour,
                      initialTabIndex: 1,
                    ),
                  ),
                ).then((_) => setState(() {}));
              },
            ),
            ListTile(
              leading: const Icon(Icons.directions_car),
              title: const Text('Add Away'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TotalDriveScreen(
                      selectedDate: _selectedDay ?? DateTime.now(),
                      selectedHour: TimeOfDay.now().hour,
                      initialTabIndex: 2,
                    ),
                  ),
                ).then((_) => setState(() {}));
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildCalendar(),
          Expanded(child: _buildHourlyTimeline()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddOptions(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.lightBlueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      title: Text(
        DateFormat.yMMMM().format(_focusedDay),
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      leading: IconButton(
        icon: const Icon(Icons.menu, color: Colors.white),
        onPressed: () {
          // Handle drawer opening
        },
      ),
      actions: [
        TextButton(
          onPressed: () {
            setState(() {
              _focusedDay = DateTime.now();
              _selectedDay = _focusedDay;
            });
          },
          child: const Text('Now', style: TextStyle(color: Colors.white)),
        ),
        IconButton(
          icon: const Icon(Icons.calendar_today, color: Colors.white),
          onPressed: () => _selectDate(context),
        ),
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: () {
            // Handle refreshing data
          },
        ),
      ],
    );
  }

  Widget _buildCalendar() {
    return Container(
      color: Colors.white,
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        calendarFormat: _calendarFormat,
        startingDayOfWeek: StartingDayOfWeek.monday,
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(fontSize: 0), // Hide original title
          leftChevronVisible: false,
          rightChevronVisible: false,
        ),
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          selectedDecoration: const BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
          ),
          weekendTextStyle: const TextStyle(color: Colors.black87),
        ),
        daysOfWeekStyle: const DaysOfWeekStyle(
          weekendStyle: TextStyle(fontWeight: FontWeight.bold),
          weekdayStyle: TextStyle(fontWeight: FontWeight.bold),
        ),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        onPageChanged: (focusedDay) {
          setState(() {
            _focusedDay = focusedDay;
          });
        },
        onFormatChanged: (format) {
          if (_calendarFormat != format) {
            setState(() {
              _calendarFormat = format;
            });
          }
        },
      ),
    );
  }

  Widget _buildHourlyTimeline() {
    final selectedDate = _selectedDay ?? DateTime.now();
    final todaysEvents = events.where((event) {
      return event.startTime.year == selectedDate.year &&
          event.startTime.month == selectedDate.month &&
          event.startTime.day == selectedDate.day;
    }).toList();

    return ListView.builder(
      itemCount: 24,
      itemBuilder: (context, index) {
        final hour = index.toString().padLeft(2, '0');
        final hourEvents = todaysEvents.where((event) => event.startTime.hour == index).toList();

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TotalDriveScreen(
                  selectedDate: _selectedDay ?? DateTime.now(),
                  selectedHour: index,
                ),
              ),
            ).then((_) => setState(() {}));
          },
          child: Container(
            height: 60.0,
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  padding: const EdgeInsets.only(right: 8.0),
                  alignment: Alignment.topRight,
                  child: Text('$hour:00'),
                ),
                Expanded(
                  child: Stack(
                    children: hourEvents.map((event) {
                      return Positioned(
                        top: event.startTime.minute.toDouble(),
                        left: 0,
                        right: 0,
                        height: event.duration.inMinutes.toDouble(),
                        child: Container(
                          color: event.color,
                          child: Text(event.title, style: const TextStyle(color: Colors.white)),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
