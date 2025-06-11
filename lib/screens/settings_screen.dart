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

  bool _darkTheme = false;
  String _language = 'English';
  String _currency = 'EUR';
  String _firstDayOfWeek = 'Sun';
  int _firstDayOfMonth = 1;
  bool _passcodeProtection = false;

  bool _syncGoogleDrive = false;
  bool _syncDropbox = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _saveAllSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('budgetMode', _budgetMode);
    await prefs.setDouble('monthlyBudget', _monthlyBudget);
    await prefs.setString('language', _language);
    await prefs.setString('currency', _currency);
    await prefs.setString('firstDayOfWeek', _firstDayOfWeek);
    await prefs.setInt('firstDayOfMonth', _firstDayOfMonth);
    await prefs.setBool('darkTheme', _darkTheme);
    await prefs.setBool('passcodeProtection', _passcodeProtection);
    await prefs.setBool('syncGoogleDrive', _syncGoogleDrive);
    await prefs.setBool('syncDropbox', _syncDropbox);
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _budgetMode = prefs.getBool('budgetMode') ?? false;
      _monthlyBudget = prefs.getDouble('monthlyBudget') ?? 0;
      _language = prefs.getString('language') ?? 'English';
      _currency = prefs.getString('currency') ?? 'EUR';
      _firstDayOfWeek = prefs.getString('firstDayOfWeek') ?? 'Sun';
      _firstDayOfMonth = prefs.getInt('firstDayOfMonth') ?? 1;
      _darkTheme = prefs.getBool('darkTheme') ?? false;
      _passcodeProtection = prefs.getBool('passcodeProtection') ?? false;
      _syncGoogleDrive = prefs.getBool('syncGoogleDrive') ?? false;
      _syncDropbox = prefs.getBool('syncDropbox') ?? false;

      if (_budgetMode && _monthlyBudget > 0) {
        final now = DateTime.now();
        final days = DateUtils.getDaysInMonth(now.year, now.month);
        _dailyBudget = _monthlyBudget / days;
      }
    });
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
      setState(() => _language = result);
      _saveAllSettings();
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
      setState(() => _currency = result);
      _saveAllSettings();
    }
  }

  void _showDayOfWeekPicker() async {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Select First Day of Week'),
        children: days
            .map((d) => SimpleDialogOption(
                  child: Text(d),
                  onPressed: () => Navigator.pop(ctx, d),
                ))
            .toList(),
      ),
    );
    if (result != null) {
      setState(() => _firstDayOfWeek = result);
      _saveAllSettings();
    }
  }

  void _showDayOfMonthPicker() async {
    final result = await showDatePicker(
      context: context,
      initialDate:
          DateTime(DateTime.now().year, DateTime.now().month, _firstDayOfMonth),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'Pick any date to use its day as first of month',
    );
    if (result != null) {
      setState(() => _firstDayOfMonth = result.day);
      _saveAllSettings();
    }
  }

  Future<void> _saveBudgetSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('budgetMode', _budgetMode);
    await prefs.setDouble('monthlyBudget', _monthlyBudget);
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
            decoration: const InputDecoration(labelText: '€'),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final value = double.tryParse(controller.text);
                if (value != null) {
                  final now = DateTime.now();
                  final daysInMonth =
                      DateUtils.getDaysInMonth(now.year, now.month);
                  setState(() {
                    _monthlyBudget = value;
                    _dailyBudget = value / daysInMonth;
                  });
                  await _saveBudgetSettings();
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
                'Carried over €${balance.toStringAsFixed(2)} to ${DateFormat.yMMMM().format(thisMonth)}')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No positive balance to carry over.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = _darkTheme ? ThemeData.dark() : ThemeData.light();

    return Theme(
      data: theme,
      child: Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: ListView(
          children: [
            _sectionHeader('BALANCE'),
            CheckboxListTile(
              title: const Text('Budget mode'),
              value: _budgetMode,
              onChanged: (v) => setState(() {
                _budgetMode = v!;
                _saveBudgetSettings();
                if (_budgetMode) _showBudgetInputDialog();
              }),
              subtitle: _budgetMode && _dailyBudget > 0
                  ? Text('Budget: €${_dailyBudget.toStringAsFixed(2)} / day')
                  : null,
            ),
            CheckboxListTile(
              title: const Text('Carry over'),
              value: _carryOver,
              onChanged: (v) => setState(() {
                _carryOver = v!;
                if (_carryOver) _applyCarryOver();
              }),
            ),
            _sectionHeader('GENERAL SETTINGS'),
            _navItem(
                title: 'Language',
                value: _language,
                onTap: _showLanguagePicker),
            _navItem(
                title: 'Currency',
                value: _currency,
                onTap: _showCurrencyPicker),
            _navItem(
                title: 'First day of week',
                value: _firstDayOfWeek,
                onTap: _showDayOfWeekPicker),
            _navItem(
                title: 'First day of month',
                value: _firstDayOfMonth.toString(),
                onTap: _showDayOfMonthPicker),
            SwitchListTile(
              title: const Text('Passcode protection'),
              value: _passcodeProtection,
              onChanged: (v) => setState(() => _passcodeProtection = v),
            ),
            _sectionHeader('SYNCHRONIZATION'),
            CheckboxListTile(
                title: const Text('Google Drive'),
                value: _syncGoogleDrive,
                onChanged: (v) => setState(() => _syncGoogleDrive = v!)),
            CheckboxListTile(
                title: const Text('Dropbox'),
                value: _syncDropbox,
                onChanged: (v) => setState(() => _syncDropbox = v!)),
            _sectionHeader('DATA BACKUP'),
            ListTile(
                leading: const Icon(Icons.cloud_upload_outlined),
                title: const Text('Create data backup'),
                onTap: () {}),
            ListTile(
                leading: const Icon(Icons.cloud_download_outlined),
                title: const Text('Restore data'),
                onTap: () {}),
            ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Clear data'),
                onTap: () {}),
            const SizedBox(height: 24),
          ],
        ),
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
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black54)),
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
