import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/expense.dart';
import '../providers/theme_provider.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({Key? key}) : super(key: key);

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  String? _name;
  String? _surname;
  String? _workplace;
  DateTime? _dob;
  String _currencySymbol = '€';

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadCurrency();
  }

  Future<void> _loadCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    final currency = prefs.getString('currency') ?? 'EUR';
    setState(() {
      _currencySymbol = currency == 'USD' ? '\$' : '€';
    });
  }

  Future<void> _loadUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        _name = data['name'];
        _surname = data['surname'];
        _workplace = data['workplace'];
        final ts = data['dob'];
        if (ts != null && ts is Timestamp) {
          _dob = ts.toDate();
        }
      });
    }
  }

  Future<bool> _reauthenticateUser(BuildContext context) async {
    final email = FirebaseAuth.instance.currentUser?.email;
    if (email == null) return false;

    final passwordController = TextEditingController();

    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Text('Re-authenticate'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Enter your password to confirm account deletion:'),
                const SizedBox(height: 12),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    final cred = EmailAuthProvider.credential(
                      email: email,
                      password: passwordController.text,
                    );
                    await FirebaseAuth.instance.currentUser!
                        .reauthenticateWithCredential(cred);
                    Navigator.pop(ctx, true);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Reauthentication failed')),
                    );
                  }
                },
                child: const Text('Confirm'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _editProfile() {
    final nameCtrl = TextEditingController(text: _name);
    final surnameCtrl = TextEditingController(text: _surname);
    final workplaceCtrl = TextEditingController(text: _workplace);
    DateTime? newDob = _dob;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Profile'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'First Name'),
              ),
              TextField(
                controller: surnameCtrl,
                decoration: const InputDecoration(labelText: 'Last Name'),
              ),
              TextField(
                controller: workplaceCtrl,
                decoration: const InputDecoration(labelText: 'Workplace'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Date of Birth:'),
                  const SizedBox(width: 12),
                  Text(
                    newDob != null
                        ? DateFormat.yMMMd().format(newDob!)
                        : 'Not set',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: newDob ?? DateTime(2000),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() => newDob = picked);
                      }
                    },
                  )
                ],
              )
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Save'),
            onPressed: () async {
              final uid = FirebaseAuth.instance.currentUser?.uid;
              if (uid != null) {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .set({
                  'name': nameCtrl.text,
                  'surname': surnameCtrl.text,
                  'workplace': workplaceCtrl.text,
                  'dob': newDob,
                }, SetOptions(merge: true));
                _loadUserData();
                Navigator.pop(ctx);
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final uid = user.uid;
      try {
        await FirestoreService.instance.deleteUserProfile(uid);
        await user.delete();
        await AuthService.instance.signOut();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete account: $e')),
        );
      }
    }
  }

  void _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
            'Are you sure you want to permanently delete your account?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete')),
        ],
      ),
    );

    if (confirmed != true) return;

    final success = await _reauthenticateUser(context);
    if (success) {
      _deleteAccount();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
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

        final email = user.email ?? '';
        final initials = (_name?.isNotEmpty ?? false)
            ? _name![0]
            : (user.displayName?.isNotEmpty ?? false)
                ? user.displayName![0]
                : 'U';

        return Theme(
          data: themeProvider.isDarkMode ? ThemeData.dark() : ThemeData.light(),
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            children: [
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.lightBlueAccent,
                      child: Text(initials,
                          style: const TextStyle(
                              fontSize: 32, color: Colors.white)),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      (_name != null || _surname != null)
                          ? '${_name ?? ''} ${_surname ?? ''}'.trim()
                          : user.displayName ?? 'User',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(email, style: TextStyle(color: Colors.grey.shade700)),
                    const SizedBox(height: 12),
                    if (_workplace != null || _dob != null)
                      Column(
                        children: [
                          if (_workplace != null)
                            Text('Workplace: $_workplace'),
                          if (_dob != null)
                            Text('DOB: ${DateFormat.yMMMd().format(_dob!)}'),
                        ],
                      )
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
                      onPressed: _editProfile,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.logout),
                      label: const Text('Log Out'),
                      onPressed: () async {
                        await AuthService.instance.signOut();
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  child: const Text('Delete Account',
                      style: TextStyle(color: Colors.red)),
                  onPressed: _confirmDelete,
                ),
              ),
              const SizedBox(height: 32),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text('Account Summary',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const Divider(),
                      StreamBuilder<List<Expense>>(
                        stream: FirestoreService.instance.watchIncomes(),
                        builder: (ctxI, snapI) {
                          final incs = snapI.data ?? [];
                          final totalInc =
                              incs.fold(0.0, (s, e) => s + e.amount);
                          return ListTile(
                            leading: const Icon(Icons.arrow_circle_down,
                                color: Colors.green),
                            title: const Text('Total Income'),
                            trailing: Text(
                                '$_currencySymbol${totalInc.toStringAsFixed(2)}'),
                          );
                        },
                      ),
                      StreamBuilder<List<Expense>>(
                        stream: FirestoreService.instance.watchExpenses(),
                        builder: (ctxE, snapE) {
                          final exps = snapE.data ?? [];
                          final totalExp =
                              exps.fold(0.0, (s, e) => s + e.amount);
                          return ListTile(
                            leading: const Icon(Icons.arrow_circle_up,
                                color: Colors.red),
                            title: const Text('Total Expenses'),
                            trailing: Text(
                                '$_currencySymbol${totalExp.toStringAsFixed(2)}'),
                          );
                        },
                      ),
                      const Divider(),
                      // ADDING DARK MODE SWITCH:
                      SwitchListTile(
                        title: const Text('Dark Mode'),
                        value: themeProvider.isDarkMode,
                        onChanged: (value) {
                          themeProvider.toggleTheme(value);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
