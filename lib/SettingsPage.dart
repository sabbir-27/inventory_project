import 'package:flutter/material.dart';
import 'UsersListPage.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF0066CC), // Changed to #0066CC
        foregroundColor: Colors.white,
        title: const Text("Settings"),
      ),
      body: ListView(
        children: [
          _buildSettingsItem(
            context,
            Icons.group,
            "Users Management",
            "Manage app users and permissions",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UsersListPage()),
              );
            },
          ),
          _buildSettingsItem(
            context,
            Icons.sms,
            "SMS Settings",
            "Configure SMS notifications",
            onTap: () {
              // SMS settings implementation
            },
          ),
          // Add more settings here
        ],
      ),
    );
  }

  Widget _buildSettingsItem(BuildContext context, IconData icon, String title, String subtitle, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF0066CC)), // Changed to #0066CC
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}
