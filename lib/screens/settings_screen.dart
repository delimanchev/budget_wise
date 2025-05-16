// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // BALANCE
  bool _budgetMode = false;
  bool _carryOver = false;

  // GENERAL SETTINGS
  bool _darkTheme = false;
  String _language = 'English';
  String _currency = 'EUR';
  String _firstDayOfWeek = 'Sun';
  int _firstDayOfMonth = 1;
  bool _passcodeProtection = false;

  // SYNCHRONIZATION
  bool _syncGoogleDrive = false;
  bool _syncDropbox = false;

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    return Scaffold(
      body: ListView(
        children: [
          // BALANCE SECTION
          _sectionHeader('BALANCE'),
          CheckboxListTile(
            title: const Text('Budget mode'),
            value: _budgetMode,
            onChanged: (v) => setState(() => _budgetMode = v!),
          ),
          CheckboxListTile(
            title: const Text('Carry over'),
            value: _carryOver,
            onChanged: (v) => setState(() => _carryOver = v!),
          ),

          // GENERAL SETTINGS
          _sectionHeader('GENERAL SETTINGS'),
          ListTile(
            leading: const Icon(Icons.diamond_outlined),
            title: const Text('BudgetWise'),
            onTap: () {
              // TODO: navigate to purchase screen
            },
          ),
          SwitchListTile(
            title: const Text('Dark theme'),
            value: _darkTheme,
            onChanged: (v) => setState(() => _darkTheme = v),
          ),
          _navItem(
            title: 'Language',
            value: _language,
            onTap: () {
              // TODO: show language picker
            },
          ),
          _navItem(
            title: 'Currency',
            value: _currency,
            onTap: () {
              // TODO: show currency picker
            },
          ),
          _navItem(
            title: 'First day of week',
            value: _firstDayOfWeek,
            onTap: () {
              // TODO: show day-of-week picker
            },
          ),
          _navItem(
            title: 'First day of month',
            value: _firstDayOfMonth.toString(),
            onTap: () {
              // TODO: show day-of-month picker
            },
          ),
          SwitchListTile(
            title: const Text('Passcode protection'),
            value: _passcodeProtection,
            onChanged: (v) => setState(() => _passcodeProtection = v),
          ),
          ListTile(
            leading: const Icon(Icons.thumb_up_alt_outlined),
            title: const Text('Review application'),
            onTap: () {
              // TODO: launch app store review link
            },
          ),
          ListTile(
            leading: const Icon(Icons.share_outlined),
            title: const Text('Export to file'),
            onTap: () {
              // TODO: export data
            },
          ),
          ListTile(
            leading: const Icon(Icons.support_agent_outlined),
            title: const Text('Contact support'),
            onTap: () {
              // TODO: open email or support chat
            },
          ),

          // SYNCHRONIZATION
          _sectionHeader('SYNCHRONIZATION'),
          CheckboxListTile(
            title: const Text('Google Drive'),
            value: _syncGoogleDrive,
            onChanged: (v) => setState(() => _syncGoogleDrive = v!),
          ),
          CheckboxListTile(
            title: const Text('Dropbox'),
            value: _syncDropbox,
            onChanged: (v) => setState(() => _syncDropbox = v!),
          ),

          // DATA BACKUP
          _sectionHeader('DATA BACKUP'),
          ListTile(
            leading: const Icon(Icons.cloud_upload_outlined),
            title: const Text('Create data backup'),
            onTap: () {
              // TODO: backup data
            },
          ),
          ListTile(
            leading: const Icon(Icons.cloud_download_outlined),
            title: const Text('Restore data'),
            onTap: () {
              // TODO: restore data
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: const Text('Clear data'),
            onTap: () {
              // TODO: clear all data
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Container(
      width: double.infinity,
      color: Colors.grey.shade200,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(title,
          style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54)),
    );
  }

  Widget _navItem({
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(title),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(value, style: TextStyle(color: Theme.of(context).primaryColor)),
        const SizedBox(width: 8),
        const Icon(Icons.chevron_right),
      ]),
      onTap: onTap,
    );
  }
}
