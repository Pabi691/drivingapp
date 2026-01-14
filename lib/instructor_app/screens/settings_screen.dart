import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../auth/auth_provider.dart';

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
    /// ✅ ONLY 2 tabs are active
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildToolsTab(context),
                const Center(child: Text('Settings Content')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= APP BAR =================

  AppBar _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      title: const Text(
        'Settings',
        style: TextStyle(
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

  // ================= TAB BAR =================

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
        ],
      ),
    );
  }

  // ================= TOOLS TAB =================

  Widget _buildToolsTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'My Profile', 
                  Icons.person, 
                  onTap: () => context.go('/profile'),
                  ),
              ),
              const SizedBox(width: 16),
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
          const SizedBox(height: 24),
          _buildSettingsList(context),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, IconData icon, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
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
      ),
    );
  }

  // ================= SETTINGS LIST =================

  Widget _buildSettingsList(BuildContext context) {
    return Column(
      children: [
        _buildSettingsItem(
          'Terms & Conditions',
          Icons.arrow_forward_ios,
          () {},
        ),
        _buildSettingsItem(
          'Help',
          Icons.arrow_forward_ios,
          () {},
        ),
        _buildSettingsItem(
          'Logout',
          Icons.logout,
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

  // ================= LOGOUT =================

  void _showLogoutDialog(BuildContext context) {
    final authProvider = context.read<AuthProvider>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () {
                authProvider.logout();
                Navigator.of(context).pop();
                context.go('/');
              },
            ),
          ],
        );
      },
    );
  }
}
