import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../auth/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final pin = authService.userPin ?? 'N/A';

    return Scaffold(
      appBar: _buildAppBar(pin),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildToolsTab(context),
                const Center(child: Text('Settings Content')),
                const Center(child: Text('Resources Content')),
                const Center(child: Text('Membership Content')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar(String pin) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Text(
        'My PIN $pin',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.lightBlueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Material(
      color: Colors.blue[800],
      child: TabBar(
        controller: _tabController,
        indicatorColor: Colors.white,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        tabs: const [
          Tab(text: 'Tools'),
          Tab(text: 'Settings'),
          // Tab(text: 'Resources'),
          // Tab(text: 'Membership'),
        ],
      ),
    );
  }

  Widget _buildToolsTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildMetricCard('School Metrics', Icons.bar_chart),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricCard(
                  'Practical Tests',
                  Icons.check_circle_outline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Teaching Aids',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          // _buildDoodlePadCard(),
          const SizedBox(height: 24),
          _buildSettingsList(context),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, IconData icon) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 40, color: Colors.blue),
            const SizedBox(height: 8),
            Text(title, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildDoodlePadCard() {
    return Card(
      color: Colors.blue[900],
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 32),
        child: Column(
          children: [
            Text(
              'Doodle Pad',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
            ),
            SizedBox(height: 8),
            Text('Draw on Maps', style: TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsList(BuildContext context) {
    return Column(
      children: [
        _buildSettingsItem(
          'Terms & Conditions',
          Icons.arrow_forward_ios,
          () {},
        ),
        _buildSettingsItem('Help', Icons.arrow_forward_ios, () {}),
        _buildSettingsItem(
          'Logout',
          Icons.arrow_forward_ios,
          () => _showLogoutDialog(context),
        ),
      ],
    );
  }

  Widget _buildSettingsItem(
    String title,
    IconData trailingIcon,
    VoidCallback onTap,
  ) {
    return ListTile(
      title: Text(title),
      trailing: Icon(trailingIcon, size: 16),
      onTap: onTap,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () {
                authService.logout();
                context.go('/');
              },
            ),
          ],
        );
      },
    );
  }
}
