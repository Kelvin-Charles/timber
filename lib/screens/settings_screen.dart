import 'package:flutter/material.dart';
import '../models/user.dart';
import '../widgets/app_drawer.dart';
import '../theme/app_theme.dart';
import '../utils/role_permissions.dart';

class SettingsScreen extends StatefulWidget {
  final User? user;
  
  const SettingsScreen({super.key, this.user});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;
  bool _notifications = true;
  String _language = 'English';
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      drawer: AppDrawer(user: widget.user),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Card(
              child: Column(
                children: [
                  ListTile(
                    title: const Text('App Settings'),
                    subtitle: const Text('Customize your app experience'),
                    leading: const Icon(Icons.settings),
                  ),
                  const Divider(),
                  SwitchListTile(
                    title: const Text('Dark Mode'),
                    subtitle: const Text('Enable dark theme'),
                    value: _darkMode,
                    onChanged: (value) {
                      setState(() {
                        _darkMode = value;
                      });
                    },
                    secondary: const Icon(Icons.dark_mode),
                  ),
                  SwitchListTile(
                    title: const Text('Notifications'),
                    subtitle: const Text('Enable push notifications'),
                    value: _notifications,
                    onChanged: (value) {
                      setState(() {
                        _notifications = value;
                      });
                    },
                    secondary: const Icon(Icons.notifications),
                  ),
                  ListTile(
                    title: const Text('Language'),
                    subtitle: Text(_language),
                    leading: const Icon(Icons.language),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // Show language selection dialog
                      _showLanguageDialog();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Account Settings'),
                    subtitle: const Text('Manage your account'),
                    leading: const Icon(Icons.account_circle),
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Edit Profile'),
                    leading: const Icon(Icons.edit),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // Navigate to edit profile screen
                    },
                  ),
                  ListTile(
                    title: const Text('Change Password'),
                    leading: const Icon(Icons.lock),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // Navigate to change password screen
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (RolePermissions.hasRole(widget.user?.role ?? 'worker', 'admin'))
              Card(
                child: Column(
                  children: [
                    ListTile(
                      title: const Text('System Settings'),
                      subtitle: const Text('Configure system parameters'),
                      leading: const Icon(Icons.admin_panel_settings),
                    ),
                    const Divider(),
                    ListTile(
                      title: const Text('Database Backup'),
                      leading: const Icon(Icons.backup),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        // Show backup dialog
                      },
                    ),
                    ListTile(
                      title: const Text('System Logs'),
                      leading: const Icon(Icons.list_alt),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        // Navigate to system logs screen
                      },
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Save settings
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Settings saved successfully'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('SAVE SETTINGS'),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Select Language'),
        children: [
          SimpleDialogOption(
            onPressed: () {
              setState(() {
                _language = 'English';
              });
              Navigator.pop(context);
            },
            child: const Text('English'),
          ),
          SimpleDialogOption(
            onPressed: () {
              setState(() {
                _language = 'Swahili';
              });
              Navigator.pop(context);
            },
            child: const Text('Swahili'),
          ),
          SimpleDialogOption(
            onPressed: () {
              setState(() {
                _language = 'French';
              });
              Navigator.pop(context);
            },
            child: const Text('French'),
          ),
        ],
      ),
    );
  }
} 