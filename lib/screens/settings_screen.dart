import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/firestore_service.dart';
import '../models/expense.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _budgetMode = false;
  bool _carryOver = false;
  double _monthlyBudget = 0;
  double _dailyBudget = 0;
  String _language = 'English';
  String _currency = 'EUR';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _budgetMode = prefs.getBool('budgetMode') ?? false;
      _monthlyBudget = prefs.getDouble('monthlyBudget') ?? 0;
      _language = prefs.getString('language') ?? 'English';
      _currency = prefs.getString('currency') ?? 'EUR';

      if (_budgetMode && _monthlyBudget > 0) {
        final now = DateTime.now();
        final days = DateUtils.getDaysInMonth(now.year, now.month);
        _dailyBudget = _monthlyBudget / days;
      }
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('budgetMode', _budgetMode);
    await prefs.setDouble('monthlyBudget', _monthlyBudget);
    await prefs.setString('language', _language);
    await prefs.setString('currency', _currency);
  }

  void _showLanguagePicker() async {
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Select Language'),
        children: [
          SimpleDialogOption(
            child: const Text('English'),
            onPressed: () => Navigator.pop(ctx, 'English'),
          ),
          SimpleDialogOption(
            child: const Text('English (US)'),
            onPressed: () => Navigator.pop(ctx, 'English (US)'),
          ),
        ],
      ),
    );
    if (result != null) {
      setState(() {
        _language = result;
      });
      _saveSettings();
    }
  }

  void _showCurrencyPicker() async {
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Select Currency'),
        children: [
          SimpleDialogOption(
            child: const Text('€ Euro'),
            onPressed: () => Navigator.pop(ctx, 'EUR'),
          ),
          SimpleDialogOption(
            child: const Text('\$ Dollar'),
            onPressed: () => Navigator.pop(ctx, 'USD'),
          ),
        ],
      ),
    );
    if (result != null) {
      setState(() {
        _currency = result;
      });
      _saveSettings();
    }
  }

  void _showBudgetInputDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Enter Monthly Budget'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Amount'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                final value = double.tryParse(controller.text);
                if (value != null) {
                  final now = DateTime.now();
                  final days = DateUtils.getDaysInMonth(now.year, now.month);
                  setState(() {
                    _monthlyBudget = value;
                    _dailyBudget = value / days;
                  });
                  _saveSettings();
                }
                Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _applyCarryOver() async {
    final now = DateTime.now();
    final prevMonth = DateTime(now.year, now.month - 1);
    final thisMonth = DateTime(now.year, now.month, 1);

    final incomes = await FirestoreService.instance.getIncomes();
    final expenses = await FirestoreService.instance.getExpenses();

    final prevIncomes = incomes.where((e) =>
        e.date.year == prevMonth.year && e.date.month == prevMonth.month);
    final prevExpenses = expenses.where((e) =>
        e.date.year == prevMonth.year && e.date.month == prevMonth.month);

    final balance = prevIncomes.fold(0.0, (s, e) => s + e.amount) -
        prevExpenses.fold(0.0, (s, e) => s + e.amount);

    if (balance > 0) {
      final carry = Expense(
        amount: balance,
        category: 'Carry Over',
        description: 'Balance from ${DateFormat.yMMMM().format(prevMonth)}',
        date: thisMonth,
      );
      await FirestoreService.instance.addIncome(carry);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Carried over ${_currencySymbol()}${balance.toStringAsFixed(2)} to ${DateFormat.yMMMM().format(thisMonth)}')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No positive balance to carry over.')),
      );
    }
  }

  String _currencySymbol() {
    return _currency == 'USD' ? '\$' : '€';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          _sectionHeader('BALANCE'),
          CheckboxListTile(
            title: const Text('Budget mode'),
            value: _budgetMode,
            onChanged: (v) {
              setState(() {
                _budgetMode = v!;
              });
              _saveSettings();
              if (_budgetMode) _showBudgetInputDialog();
            },
            subtitle: _budgetMode && _dailyBudget > 0
                ? Text(
                    'Budget: ${_currencySymbol()}${_dailyBudget.toStringAsFixed(2)} / day')
                : null,
          ),
          CheckboxListTile(
            title: const Text('Carry over'),
            value: _carryOver,
            onChanged: (v) {
              setState(() {
                _carryOver = v!;
                if (_carryOver) _applyCarryOver();
              });
            },
          ),
          _sectionHeader('GENERAL SETTINGS'),
          _navItem(
            title: 'Language',
            value: _language,
            onTap: _showLanguagePicker,
          ),
          _navItem(
            title: 'Currency',
            value: _currency,
            onTap: _showCurrencyPicker,
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
      child: Text(
        title,
        style: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54),
      ),
    );
  }

  Widget _navItem(
      {required String title,
      required String value,
      required VoidCallback onTap}) {
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
