import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/expense.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({Key? key}) : super(key: key);

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool _darkTheme = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService.instance.userChanges,
      builder: (ctx, authSnap) {
        if (authSnap.connectionState != ConnectionState.active) {
          return const Center(child: CircularProgressIndicator());
        }
        final user = authSnap.data;
        if (user == null) {
          return const Center(child: Text('No user logged in'));
        }

        final displayName = user.displayName ?? user.email?.split('@').first ?? 'User';
        final email       = user.email ?? '';
        final initials    = displayName.isNotEmpty ? displayName[0] : '';

        return Theme(
          data: _darkTheme ? ThemeData.dark() : ThemeData.light(),
          child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.lightBlueAccent,
                    child: Text(initials, style: const TextStyle(fontSize: 32, color: Colors.white)),
                  ),
                  const SizedBox(height: 12),
                  Text(displayName,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(email, style: TextStyle(color: Colors.grey.shade700)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Profile'),
                    onPressed: () {
                      // TODO: navigate to edit‐profile screen
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.logout),
                    label: const Text('Log Out'),
                    onPressed: () async {
                      await AuthService.instance.signOut();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text('Account Summary',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const Divider(),

                    StreamBuilder<List<Expense>>(
                      stream: FirestoreService.instance.watchIncomes(),
                      builder: (ctxI, snapI) {
                        final incs = snapI.data ?? [];
                        final totalInc = incs.fold(0.0, (s, e) => s + e.amount);
                        return ListTile(
                          leading: const Icon(Icons.arrow_circle_down, color: Colors.green),
                          title: const Text('Total Income'),
                          trailing: Text('€${totalInc.toStringAsFixed(2)}'),
                        );
                      },
                    ),

                    StreamBuilder<List<Expense>>(
                      stream: FirestoreService.instance.watchExpenses(),
                      builder: (ctxE, snapE) {
                        final exps = snapE.data ?? [];
                        final totalExp = exps.fold(0.0, (s, e) => s + e.amount);
                        return ListTile(
                          leading: const Icon(Icons.arrow_circle_up, color: Colors.red),
                          title: const Text('Total Expenses'),
                          trailing: Text('€${totalExp.toStringAsFixed(2)}'),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Preferences',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                        // TODO: trigger update logic
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.copy_outlined),
                      title: const Text('Copy User ID'),
                      onTap: () {
                        final uid = user.uid;
                        Clipboard.setData(ClipboardData(text: uid));
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
          ),
        );
      },
    );
  }
}
