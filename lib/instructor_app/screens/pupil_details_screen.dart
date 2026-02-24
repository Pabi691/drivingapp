import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/pupil_provider.dart';
import '../services/pupil_service.dart';
import 'add_pupil_screen.dart';

class PupilDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> pupil;

  const PupilDetailsScreen({
    super.key,
    required this.pupil,
  });

  @override
  State<PupilDetailsScreen> createState() => _PupilDetailsScreenState();
}

class _PupilDetailsScreenState extends State<PupilDetailsScreen> {
  bool _loadingBookings = true;
  String? _bookingsError;
  List<dynamic> _bookings = [];

  double _totalPending = 0;
  double _totalCompleted = 0;
  double _totalRequested = 0;
  double _totalCancelled = 0;

  void _calculateBookingStats() {
    _totalPending = 0;
    _totalCompleted = 0;
    _totalRequested = 0;
    _totalCancelled = 0;

    for (var b in _bookings) {
      final status = _text(b['status']).toLowerCase();
      final creditStr = _text(b['credit_use']);
      final double credit = double.tryParse(creditStr) ?? 0.0;

      if (status == 'pending') {
        _totalPending += credit;
      } else if (status == 'completed') {
        _totalCompleted += credit;
      } else if (status == 'booking_request') {
        _totalRequested += credit;
      } else if (status == 'cancelled') {
        _totalCancelled += credit;
      }
    }
  }

  double _getPackageDuration(dynamic packageData) {
    if (packageData == null) return 0.0;
    final durationStr = packageData['duration']?.toString() ?? '0';
    return double.tryParse(durationStr) ?? 0.0;
  }

  String _calculateRemaining(dynamic packageData) {
    final duration = _getPackageDuration(packageData);
    double consumed = _totalCompleted;
    double remaining = duration - consumed;
    if (remaining < 0) remaining = 0;
    return remaining.toStringAsFixed(1).replaceAll('.0', '');
  }

  String _calculateProgress(dynamic packageData) {
    final duration = _getPackageDuration(packageData);
    if (duration <= 0) return '0';
    double consumed = _totalCompleted;
    int progress = ((consumed / duration) * 100).round();
    if (progress > 100) progress = 100;
    return progress.toString();
  }

  String _formatDouble(double val) {
    return val.toStringAsFixed(1).replaceAll('.0', '');
  }

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    final pupilId = widget.pupil['_id']?.toString();
    if (pupilId == null || pupilId.isEmpty) {
      setState(() {
        _loadingBookings = false;
        _bookingsError = 'Pupil ID not found';
      });
      return;
    }

    setState(() {
      _loadingBookings = true;
      _bookingsError = null;
    });

    try {
      final bookings = await PupilService.getBookingsByPupilId(pupilId);
      if (!mounted) return;
      setState(() {
        _bookings = bookings;
        _loadingBookings = false;
        _calculateBookingStats();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingBookings = false;
        _bookingsError = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final area = widget.pupil['area_id'];
    final instructor = widget.pupil['instructor_id'];
    final packageData = widget.pupil['package_id'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pupil Details'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadBookings,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 16),
            _buildInfoCard(
              title: 'Personal Information',
              children: [
                _infoTile(Icons.person, 'Full Name', _text(widget.pupil['full_name'])),
                _infoTile(Icons.phone, 'Phone', _text(widget.pupil['phone'])),
                _infoTile(Icons.email, 'Email', _text(widget.pupil['email'])),
                _infoTile(Icons.flag, 'Status', widget.pupil['active'] == 1 ? 'Active' : 'Inactive'),
                _infoTile(Icons.payments, 'Payment Status', _text(widget.pupil['payment_status'])),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              title: 'Learning Information',
              children: [
                _infoTile(Icons.timer, 'Remaining Hours', '${_calculateRemaining(packageData)} hrs'),
                _infoTile(Icons.trending_up, 'Progress', '${_calculateProgress(packageData)}%'),
                _infoTile(Icons.location_on, 'Area', _text(area?['name'])),
                _infoTile(Icons.school, 'Instructor', _text(instructor?['name'] ?? instructor?['email'])),
                _infoTile(
                  Icons.inventory_2,
                  'Package Duration',
                  packageData != null ? '${_formatDouble(_getPackageDuration(packageData))} hrs' : 'N/A',
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              title: 'Booking Hours Summary',
              children: [
                _infoTile(Icons.hourglass_empty, 'Total Pending', '${_formatDouble(_totalPending)} hrs'),
                _infoTile(Icons.assignment, 'Booking Requests', '${_formatDouble(_totalRequested)} hrs'),
                _infoTile(Icons.check_circle, 'Total Completed', '${_formatDouble(_totalCompleted)} hrs'),
                _infoTile(Icons.cancel, 'Total Cancelled', '${_formatDouble(_totalCancelled)} hrs'),
              ],
            ),
            const SizedBox(height: 12),
            _buildBookingsSection(),
            const SizedBox(height: 20),
            _actionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    final name = _text(widget.pupil['full_name']);
    final initial = name.isNotEmpty && name != '-' ? name[0].toUpperCase() : '?';

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [Colors.blue.shade700, Colors.blue.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Text(
              initial,
              style: TextStyle(
                color: Colors.blue.shade700,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _text(widget.pupil['email']),
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          _chip('${_calculateProgress(widget.pupil['package_id'])}%'),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.blueGrey),
          const SizedBox(width: 8),
          SizedBox(
            width: 135,
            child: Text(
              label,
              style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingsSection() {
    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Bookings',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
                _chip('${_bookings.length}'),
                const SizedBox(width: 6),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadingBookings ? null : _loadBookings,
                  tooltip: 'Refresh bookings',
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_loadingBookings)
              const Center(child: Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(),
              ))
            else if (_bookingsError != null)
              Text(
                _bookingsError!,
                style: const TextStyle(color: Colors.red),
              )
            else if (_bookings.isEmpty)
              const Text(
                'No bookings found for this pupil.',
                style: TextStyle(color: Colors.black54),
              )
            else
              ..._bookings.map(_bookingCard),
          ],
        ),
      ),
    );
  }

  Widget _bookingCard(dynamic booking) {
    final instructor = booking['instructor_id'];
    final status = _text(booking['status']);
    final paymentStatus = _text(booking['payment_status']);
    final paymentType = _text(booking['payment_type']);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _formatDate(booking['booking_date']),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              _tag(status, _statusColor(status)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${_text(booking['start_time'])} - ${_text(booking['end_time'])}',
            style: const TextStyle(color: Colors.black87),
          ),
          const SizedBox(height: 6),
          Text('Instructor: ${_text(instructor?['name'])}'),
          Text('Email: ${_text(instructor?['email'])}'),
          Text('Mobile: ${_text(instructor?['mobile'])}'),
          const SizedBox(height: 8),
          Row(
            children: [
              _tag(paymentStatus, _paymentColor(paymentStatus)),
              const SizedBox(width: 8),
              _tag(paymentType, Colors.teal),
              const SizedBox(width: 8),
              _tag('Credit ${_text(booking['credit_use'])}', Colors.deepPurple),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'cancelled':
      case 'rejected':
        return Colors.red;
      case 'booking_request':
        return Colors.orange;
      default:
        return Colors.blueGrey;
    }
  }

  Color _paymentColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'failed':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String _formatDate(dynamic rawDate) {
    final value = rawDate?.toString();
    if (value == null || value.isEmpty) return '-';
    try {
      return DateFormat('dd MMM yyyy').format(DateTime.parse(value).toLocal());
    } catch (_) {
      return value;
    }
  }

  String _text(dynamic value) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? '-' : text;
  }

  Widget _actionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.edit),
            label: const Text('Edit'),
            onPressed: () async {
              final updated = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddPupilScreen(pupil: widget.pupil),
                ),
              );
              if (!mounted) return;
              if (updated == true) {
                Navigator.pop(context);
              }
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
              foregroundColor: Colors.white,
            ),
            onPressed: _confirmDelete,
          ),
        ),
      ],
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Pupil'),
        content: Text('Are you sure you want to delete ${widget.pupil['full_name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final provider = Provider.of<PupilProvider>(context, listen: false);
              await provider.deletePupil(widget.pupil['_id']);

              if (!mounted) return;
              Navigator.of(context).pop();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
