import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/expense.dart';
import '../models/category.dart';
import '../services/firestore_service.dart';

enum PigState { idle, happy, sad }

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  PigState _pigState = PigState.idle;
  DateTime _selectedMonth = DateTime.now();
  bool _budgetMode = false;
  double _dailyBudget = 0;

  @override
  void initState() {
    super.initState();
    _loadBudgetInfo();
  }

  Future<void> _loadBudgetInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _budgetMode = prefs.getBool('budgetMode') ?? false;
      final monthly = prefs.getDouble('monthlyBudget') ?? 0;
      if (_budgetMode && monthly > 0) {
        final now = DateTime.now();
        final daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);
        _dailyBudget = monthly / daysInMonth;
      }
    });
  }

  void _showAnimatedPig(PigState state) {
    final pigAsset  = state == PigState.happy ? 'assets/images/pig_happy.png'  : 'assets/images/pig_sad.png';
    final animAsset = state == PigState.happy ? 'assets/animations/coins.json' : 'assets/animations/cloud_rain.json';

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (_, anim, __, ___) {
        final curve = CurvedAnimation(parent: anim, curve: Curves.easeOutBack);
        return ScaleTransition(
          scale: Tween<double>(begin: 0.5, end: 1.0).animate(curve),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(animAsset, width: 200, repeat: false),
                const SizedBox(height: 16),
                Image.asset(pigAsset, width: 200),
              ],
            ),
          ),
        );
      },
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (Navigator.of(context).canPop()) Navigator.of(context).pop();
      setState(() => _pigState = PigState.idle);
    });
  }

  void _addTransaction({ required bool isIncome }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        String? selectedCategory;
        final amtCtrl  = TextEditingController();
        final descCtrl = TextEditingController();

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 16, right: 16, top: 16,
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(
              isIncome ? 'Add Income' : 'Add Expense',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            StreamBuilder<List<Category>>(
              stream: FirestoreService.instance.watchCategories(),
              builder: (cCtx, snapC) {
                if (snapC.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final cats = (snapC.data ?? [])
                    .where((c) => c.isIncome == isIncome)
                    .toList();

                return DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: cats.map((c) => DropdownMenuItem(
                    value: c.name,
                    child: Text(c.name),
                  )).toList(),
                  onChanged: (v) => selectedCategory = v,
                );
              },
            ),

            TextField(
              controller: amtCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount (€)'),
            ),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final amt = double.tryParse(amtCtrl.text);
                if (amt != null && selectedCategory != null) {
                  final entry = Expense(
                    amount     : amt,
                    category   : selectedCategory!,
                    description: descCtrl.text,
                    date       : DateTime.now(),
                  );
                  Navigator.pop(ctx);
                  if (isIncome) {
                    FirestoreService.instance.addIncome(entry);
                    _showAnimatedPig(PigState.happy);
                  } else {
                    FirestoreService.instance.addExpense(entry);
                    _showAnimatedPig(PigState.sad);
                  }
                  setState(() {});
                }
              },
              child: const Text('Confirm'),
            ),
          ]),
        );
      },
    );
  }

  void _changeMonth(int months) {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + months,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final monthLabel = DateFormat.yMMMM().format(_selectedMonth);

    return Scaffold(
      appBar: AppBar(title: const Text('BudgetWise'), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(icon: const Icon(Icons.chevron_left), onPressed: () => _changeMonth(-1)),
                Text(monthLabel, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    final now = DateTime.now();
                    if (!(_selectedMonth.year == now.year && _selectedMonth.month == now.month)) {
                      _changeMonth(1);
                    }
                  },
                ),
              ],
            ),
          ),

          Expanded(
            child: StreamBuilder<List<Expense>>(
              stream: FirestoreService.instance.watchExpenses(),
              builder: (ctxE, snapE) {
                if (snapE.connectionState != ConnectionState.active) {
                  return const Center(child: CircularProgressIndicator());
                }
                final allExp = snapE.data ?? [];
                final expenses = allExp.where((e) => e.date.year == _selectedMonth.year && e.date.month == _selectedMonth.month).toList();

                return StreamBuilder<List<Expense>>(
                  stream: FirestoreService.instance.watchIncomes(),
                  builder: (ctxI, snapI) {
                    if (snapI.connectionState != ConnectionState.active) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final allInc = snapI.data ?? [];
                    final incomes = allInc.where((e) => e.date.year == _selectedMonth.year && e.date.month == _selectedMonth.month).toList();

                    final totalExp = expenses.fold(0.0, (s, e) => s + e.amount);
                    final totalInc = incomes.fold(0.0, (s, e) => s + e.amount);
                    final balance  = totalInc - totalExp;

                    return StreamBuilder<List<Category>>(
                      stream: FirestoreService.instance.watchCategories(),
                      builder: (ctxC, snapC) {
                        if (snapC.connectionState != ConnectionState.active) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        final cats = (snapC.data ?? []).where((c) => !c.isIncome).toList();
                        final sums = cats.map((cat) =>
                          expenses.where((e) => e.category == cat.name).fold<double>(0, (s, e) => s + e.amount)).toList();

                        final sections = <PieChartSectionData>[];
                        final icons    = <Widget>[];

                        for (var i = 0; i < cats.length; i++) {
                          final cat   = cats[i];
                          final value = sums[i];
                          final color = Colors.primaries[i % Colors.primaries.length];

                          sections.add(PieChartSectionData(
                            value    : value,
                            color    : color,
                            radius   : 40,
                            showTitle: false,
                          ));

                          icons.add(Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(cat.iconData, size: 32, color: color),
                              const SizedBox(height: 4),
                              Text(cat.name, style: TextStyle(fontSize: 12, color: color)),
                              Text('€${value.toStringAsFixed(2)}', style: TextStyle(fontSize: 12, color: color)),
                            ],
                          ));
                        }

                        return SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Column(children: [
                            Column(
                              children: [
                                Text(
                                  'Balance: €${balance.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: balance >= 0 ? Colors.green : Colors.red,
                                  ),
                                ),
                                if (_budgetMode && _dailyBudget > 0)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Text(
                                      'Budget: €${_dailyBudget.toStringAsFixed(2)} / day',
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width : 260, height: 260,
                              child: Stack(alignment: Alignment.center, children: [
                                PieChart(PieChartData(sections: sections, centerSpaceRadius: 80)),
                                Image.asset('assets/images/pig_idle.png', width: 120),
                              ]),
                            ),
                            const SizedBox(height: 24),
                            Wrap(spacing: 24, runSpacing: 16, alignment: WrapAlignment.center, children: icons),
                            const SizedBox(height: 32),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 48),
                              child: Row(children: [
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      side: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                    ),
                                    onPressed: () => _addTransaction(isIncome: false),
                                    child: Icon(Icons.remove, size: 32, color: Theme.of(context).colorScheme.primary),
                                  ),
                                ),
                                const SizedBox(width: 24),
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      side: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                    ),
                                    onPressed: () => _addTransaction(isIncome: true),
                                    child: Icon(Icons.add, size: 32, color: Theme.of(context).colorScheme.primary),
                                  ),
                                ),
                              ]),
                            ),
                            const SizedBox(height: 16),
                            Text('Income this month: €${totalInc.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, color: Colors.green)),
                            Text('Expenses this month: €${totalExp.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, color: Colors.red)),
                          ]),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}