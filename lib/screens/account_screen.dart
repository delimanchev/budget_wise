// lib/screens/account_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // for Clipboard if needed

class AccountScreen extends StatefulWidget {
  const AccountScreen({Key? key}) : super(key: key);

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final String _userName = 'Andrej Delimanchev';
  final String _userEmail = 'andrej.delimanchev@student.um.si';

  final double _totalIncome = 5230.75;
  final double _totalExpenses = 4120.40;

  bool _darkTheme = false;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      children: [
        // Profile section
        Center(
          child: Column(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.lightBlueAccent,
                child: Text(
                  _userName.substring(0,1),
                  style: const TextStyle(fontSize: 32, color: Colors.white),
                ),
              ),
              const SizedBox(height: 12),
              Text(_userName,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(_userEmail,
                  style: TextStyle(color: Colors.grey.shade700)),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Action buttons
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.edit),
                label: const Text('Edit Profile'),
                onPressed: () {
                  // TODO: navigate to edit profile screen
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text('Log Out'),
                onPressed: () {
                  // TODO: perform logout
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),

        // Account statistics
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text('Account Summary',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.arrow_circle_down, color: Colors.green),
                  title: const Text('Total Income'),
                  trailing:
                      Text('€${_totalIncome.toStringAsFixed(2)}'),
                ),
                ListTile(
                  leading: const Icon(Icons.arrow_circle_up, color: Colors.red),
                  title: const Text('Total Expenses'),
                  trailing:
                      Text('€${_totalExpenses.toStringAsFixed(2)}'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),

        // App info & preferences
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Preferences',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SwitchListTile(
                  title: const Text('Dark Theme'),
                  value: _darkTheme,
                  onChanged: (v) => setState(() => _darkTheme = v),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('App Version'),
                  trailing: const Text('1.0.0'),
                ),
                ListTile(
                  leading: const Icon(Icons.system_update_alt),
                  title: const Text('Check for Updates'),
                  onTap: () {
                    // TODO: trigger update check
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.copy_outlined),
                  title: const Text('Copy User ID'),
                  onTap: () {
                    const userId = 'USER-123-XYZ';
                    Clipboard.setData(const ClipboardData(text: userId));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('User ID copied')),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
