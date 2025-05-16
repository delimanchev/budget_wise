// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'category_screen.dart';
import 'expenses_screen.dart';
import 'account_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Dashboard in the center
  int _selectedIndex = 2;
  static const List<Widget> _pages = [
    CategoryScreen(),
    ExpensesScreen(),
    DashboardScreen(),
    AccountScreen(),
    SettingsScreen(),
  ];
  static const List<String> _titles = [
    'Categories',
    'Expenses',
    'BudgetWise',
    'Account',
    'Settings',
  ];

  void _onNavTap(int idx) => setState(() => _selectedIndex = idx);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Light blue accent header
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        title: Text(
          _titles[_selectedIndex],
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Help'),
                  content: const Text(
                    'Use the bottom navigation to switch tabs.\n'
                    'On BudgetWise you’ll see your pie chart and piggy.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    )
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavTap,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.lightBlueAccent,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.category), label: 'Cat.'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Exp.'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Acct.'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Sett.'),
        ],
      ),
    );
  }
}
