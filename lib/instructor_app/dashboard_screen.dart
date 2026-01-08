import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: <Widget>[
        _buildWelcomeBanner(context),
        const SizedBox(height: 24),
        _buildUpcomingLessons(context),
        const SizedBox(height: 24),
        _buildStudentSummary(context),
        const SizedBox(height: 24),
        _buildPerformanceMetrics(context),
      ],
    );
  }

  Widget _buildWelcomeBanner(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Welcome, Instructor!',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text('Here is your dashboard for today.'),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingLessons(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Upcoming Lessons',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            const ListTile(
              leading: Icon(Icons.person),
              title: Text('John Doe'),
              subtitle: Text('10:00 AM - 11:00 AM'),
              trailing: Icon(Icons.arrow_forward_ios),
            ),
            const ListTile(
              leading: Icon(Icons.person),
              title: Text('Jane Smith'),
              subtitle: Text('2:00 PM - 3:00 PM'),
              trailing: Icon(Icons.arrow_forward_ios),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              child: const Text('View Full Schedule'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentSummary(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Student Summary',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            const Text('Active Students: 15', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            const Text('Pending Requests: 3', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Manage Students'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceMetrics(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Your Performance',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            const Text(
              'Average Rating: 4.8 / 5.0',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            const Text(
              'Completed Lessons (Month): 50',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
