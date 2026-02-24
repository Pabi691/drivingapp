import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';

import '../auth/auth_provider.dart';
import '../providers/booking_provider.dart';
import '../models/event.dart';
import 'total_drive_screen.dart';
import 'profile_screen.dart';
import 'pupils_screen.dart';
import '../auth/login_screen.dart';

class InstructorHomeScreen extends StatefulWidget {
  const InstructorHomeScreen({super.key});

  @override
  State<InstructorHomeScreen> createState() => _InstructorHomeScreenState();
}

class _InstructorHomeScreenState extends State<InstructorHomeScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.week;

  void _refreshBookings() {
    if (!mounted) return;
    final instructorId = context.read<AuthProvider>().instructorId;
    if (instructorId != null) {
      context.read<BookingProvider>().fetchBookings(instructorId);
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshBookings();
    });
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
          onPressed: _refreshBookings,
        ),
      ],
    );
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
    final parentContext = context;
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.school),
              title: const Text('Add Lesson'),
              onTap: () {
                Navigator.pop(sheetContext);
                Navigator.push(
                  parentContext,
                  MaterialPageRoute(
                    builder: (_) => TotalDriveScreen(
                      selectedDate: _selectedDay ?? DateTime.now(),
                      selectedHour: TimeOfDay.now().hour,
                      initialTabIndex: 0,
                    ),
                  ),
                ).then((_) => _refreshBookings());
              },
            ),
            ListTile(
              leading: const Icon(Icons.hourglass_empty),
              title: const Text('Add Gap'),
              onTap: () {
                Navigator.pop(sheetContext);
                Navigator.push(
                  parentContext,
                  MaterialPageRoute(
                    builder: (_) => TotalDriveScreen(
                      selectedDate: _selectedDay ?? DateTime.now(),
                      selectedHour: TimeOfDay.now().hour,
                      initialTabIndex: 1,
                    ),
                  ),
                ).then((_) => _refreshBookings());
              },
            ),
            ListTile(
              leading: const Icon(Icons.directions_car),
              title: const Text('Add Away'),
              onTap: () {
                Navigator.pop(sheetContext);
                Navigator.push(
                  parentContext,
                  MaterialPageRoute(
                    builder: (_) => TotalDriveScreen(
                      selectedDate: _selectedDay ?? DateTime.now(),
                      selectedHour: TimeOfDay.now().hour,
                      initialTabIndex: 2,
                    ),
                  ),
                ).then((_) => _refreshBookings());
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showBookingDetailsDialog(Event event) async {
    final Map<String, dynamic> rawData = event.rawData ?? {};
    
    // Extract additional details
    final pupilObj = rawData['pupil_id'] is Map ? rawData['pupil_id'] : null;
    final pupilPhone = pupilObj?['phone'] ?? 'Unknown';
    final pupilEmail = pupilObj?['email'] ?? 'Unknown';
    final gearbox = rawData['gearbox'] ?? 'Unknown';
    final pickup = rawData['pickup'] ?? 'Unknown';
    final dropoff = rawData['dropoff'] ?? 'Unknown';
    final privateNotes = rawData['private_notes'] ?? 'None';
    final durationMins = event.duration.inMinutes;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(event.title),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow(Icons.access_time, 'Start Time', DateFormat.jm().format(event.startTime)),
                const SizedBox(height: 8),
                _buildDetailRow(Icons.timer, 'Duration', '$durationMins mins'),
                const SizedBox(height: 8),
                _buildDetailRow(Icons.phone, 'Phone', '$pupilPhone'),
                const SizedBox(height: 8),
                _buildDetailRow(Icons.email, 'Email', '$pupilEmail'),
                const SizedBox(height: 8),
                _buildDetailRow(Icons.directions_car, 'Gearbox', '$gearbox'),
                const SizedBox(height: 8),
                _buildDetailRow(Icons.location_on, 'Pickup', '$pickup'),
                const SizedBox(height: 8),
                _buildDetailRow(Icons.location_on_outlined, 'Dropoff', '$dropoff'),
                const SizedBox(height: 8),
                _buildDetailRow(Icons.note, 'Notes', '$privateNotes'),
                const SizedBox(height: 16),
                const Text('Change Status:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    ActionChip(
                      label: const Text('Pending'),
                      backgroundColor: Colors.orange.withValues(alpha: 0.2),
                      onPressed: () {
                        Navigator.pop(context);
                        _updateStatus(event, 'pending');
                      },
                    ),
                    ActionChip(
                      label: const Text('Completed'),
                      backgroundColor: Colors.green.withValues(alpha: 0.2),
                      onPressed: () {
                        Navigator.pop(context);
                        _updateStatus(event, 'completed');
                      },
                    ),
                    ActionChip(
                      label: const Text('Cancelled'),
                      backgroundColor: Colors.red.withValues(alpha: 0.2),
                      onPressed: () {
                        Navigator.pop(context);
                        _updateStatus(event, 'cancelled');
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[700]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '$label: $value',
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  Future<void> _updateStatus(Event event, String selectedStatus) async {
    if (selectedStatus == event.status) return;
    if (!mounted) return;

    final instructorId = context.read<AuthProvider>().instructorId;
    if (instructorId == null || event.id.isEmpty) {
      return;
    }

    try {
      await context.read<BookingProvider>().updateBookingStatus(
            bookingId: event.id,
            status: selectedStatus,
            instructorId: instructorId,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking marked ${_formatStatus(selectedStatus)}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update status: $e')),
      );
    }
  }

  String _formatStatus(String status) {
    if (status.isEmpty) return 'Unknown';
    return status[0].toUpperCase() + status.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.lightBlueAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.directions_car, size: 60, color: Colors.white),
                  SizedBox(height: 10),
                  Text('Driving App', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home / Diary'),
              onTap: () {
                Navigator.pop(context); // Close drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Pupils'),
              onTap: () {
                Navigator.pop(context); // Close drawer
                Navigator.push(context, MaterialPageRoute(builder: (_) => const PupilsScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('My Profile'),
              onTap: () {
                Navigator.pop(context); // Close drawer
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () async {
                Navigator.pop(context); // Close drawer
                await context.read<AuthProvider>().logout();
                if (!context.mounted) return;
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
      body: Consumer<BookingProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Failed to load bookings: ${provider.error}'),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _refreshBookings,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: [
              _buildCalendar(provider),
              Expanded(child: _buildHourlyTimeline(provider)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCalendar(BookingProvider provider) {
    return Container(
      color: Colors.white,
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        calendarFormat: _calendarFormat,
        startingDayOfWeek: StartingDayOfWeek.monday,
        eventLoader: (day) {
          final normalized = DateTime(day.year, day.month, day.day);
          return provider.bookings[normalized] ?? [];
        },
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(fontSize: 0),
          leftChevronVisible: false,
          rightChevronVisible: false,
        ),
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, day, events) {
            if (events.isEmpty) return const SizedBox.shrink();
            final bookingEvents = events.whereType<Event>().toList();
            if (bookingEvents.isEmpty) return const SizedBox.shrink();

            return Padding(
              padding: const EdgeInsets.only(top: 26),
              child: Wrap(
                spacing: 2,
                runSpacing: 2,
                alignment: WrapAlignment.center,
                children: bookingEvents.take(2).map((event) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: event.color,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      event.status.length > 3
                          ? event.status.substring(0, 3).toUpperCase()
                          : event.status.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          },
        ),
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.5),
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

  Widget _buildHourlyTimeline(BookingProvider provider) {
    final selectedDate = _selectedDay ?? DateTime.now();
    final normalized = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    final todaysEvents = provider.bookings[normalized] ?? [];

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
                builder: (_) => TotalDriveScreen(
                  selectedDate: _selectedDay ?? DateTime.now(),
                  selectedHour: index,
                ),
              ),
            ).then((_) => _refreshBookings());
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
                        height: event.duration.inMinutes.toDouble() > 0
                            ? event.duration.inMinutes.toDouble()
                            : 30.0,
                        child: GestureDetector(
                          onTap: () => _showBookingDetailsDialog(event),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            color: event.color,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  event.title,
                                  style: const TextStyle(color: Colors.white, fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  _formatStatus(event.status),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
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
