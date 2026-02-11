import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';

import '../auth/auth_provider.dart';
import '../providers/booking_provider.dart';
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final instructorId = context.read<AuthProvider>().instructorId;
      if (instructorId != null) {
        context.read<BookingProvider>().fetchBookings(instructorId);
      }
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
      leading: IconButton(
        icon: const Icon(Icons.menu, color: Colors.white),
        onPressed: () {},
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
            final instructorId = context.read<AuthProvider>().instructorId;
            if (instructorId != null) {
              context.read<BookingProvider>().fetchBookings(instructorId);
            }
          },
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
                ).then((_) {
                  final instructorId = context.read<AuthProvider>().instructorId;
                  if (instructorId != null) {
                    context.read<BookingProvider>().fetchBookings(instructorId);
                  }
                });
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
                ).then((_) {
                  final instructorId = context.read<AuthProvider>().instructorId;
                  if (instructorId != null) {
                    context.read<BookingProvider>().fetchBookings(instructorId);
                  }
                });
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
                ).then((_) {
                  final instructorId = context.read<AuthProvider>().instructorId;
                  if (instructorId != null) {
                    context.read<BookingProvider>().fetchBookings(instructorId);
                  }
                });
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showBookingStatusSheet(Event event) async {
    final String? selectedStatus = await showModalBottomSheet<String>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(event.title),
                subtitle: Text('Current status: ${_formatStatus(event.status)}'),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.check_circle_outline, color: Colors.green),
                title: const Text('Completed'),
                onTap: () => Navigator.pop(context, 'completed'),
              ),
              ListTile(
                leading: const Icon(Icons.cancel_outlined, color: Colors.red),
                title: const Text('Cancelled'),
                onTap: () => Navigator.pop(context, 'cancelled'),
              ),
              ListTile(
                leading: const Icon(Icons.pending_outlined, color: Colors.orange),
                title: const Text('Pending'),
                onTap: () => Navigator.pop(context, 'pending'),
              ),
            ],
          ),
        );
      },
    );

    if (selectedStatus == null || selectedStatus == event.status) {
      return;
    }

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
                      onPressed: () {
                        final instructorId = context.read<AuthProvider>().instructorId;
                        if (instructorId != null) {
                          context.read<BookingProvider>().fetchBookings(instructorId);
                        }
                      },
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddOptions(context),
        child: const Icon(Icons.add),
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
                builder: (context) => TotalDriveScreen(
                  selectedDate: _selectedDay ?? DateTime.now(),
                  selectedHour: index,
                ),
              ),
            ).then((_) {
              final instructorId = context.read<AuthProvider>().instructorId;
              if (instructorId != null) {
                context.read<BookingProvider>().fetchBookings(instructorId);
              }
            });
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
                          onTap: () => _showBookingStatusSheet(event),
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
