// lib/screens/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lottie/lottie.dart';

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

            // Stream your live categories here:
            StreamBuilder<List<Category>>(
              stream: FirestoreService.instance.watchCategories(),
              builder: (cCtx, snapC) {
                if (snapC.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                // Filter by income vs expense
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
                  validator: (v) => v == null ? 'Select a category' : null,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BudgetWise'), centerTitle: true),
      body: StreamBuilder<List<Category>>(
        // First layer: load your categories
        stream: FirestoreService.instance.watchCategories(),
        builder: (ctxCat, snapCat) {
          if (snapCat.connectionState != ConnectionState.active) {
            return const Center(child: CircularProgressIndicator());
          }
          final allCats = snapCat.data ?? [];

          // Extract expense-only category names
          final expenseCats = allCats.where((c) => !c.isIncome).toList();

          return StreamBuilder<List<Expense>>(
            stream: FirestoreService.instance.watchExpenses(),
            builder: (ctxE, snapE) {
              if (snapE.connectionState != ConnectionState.active) {
                return const Center(child: CircularProgressIndicator());
              }
              final expenses = snapE.data ?? [];

              return StreamBuilder<List<Expense>>(
                stream: FirestoreService.instance.watchIncomes(),
                builder: (ctxI, snapI) {
                  if (snapI.connectionState != ConnectionState.active) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final incomes = snapI.data ?? [];

                  // Totals
                  final totalExp = expenses.fold(0.0, (s,e) => s + e.amount);
                  final totalInc = incomes.fold(0.0, (s,e) => s + e.amount);
                  final balance  = totalInc - totalExp;

                  // Per-category sums
                  final sums = expenseCats.map((cat) {
                    return expenses
                        .where((e) => e.category == cat.name)
                        .fold<double>(0, (s, e) => s + e.amount);
                  }).toList();

                  // Build pie sections & icon columns
                  final sections = <PieChartSectionData>[];
                  final icons    = <Widget>[];

                  for (var i = 0; i < expenseCats.length; i++) {
                    final cat = expenseCats[i];
                    final value = sums[i];
                    final color = Colors.primaries[i % Colors.primaries.length];

                    // pie slice
                    sections.add(PieChartSectionData(
                      value    : value,
                      color    : color,
                      radius   : 40,
                      showTitle: false,
                    ));

                    // icon + label + sum
                    icons.add(Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(cat.iconData, size: 32, color: color),
                        const SizedBox(height: 4),
                        Text(cat.name, style: TextStyle(fontSize: 12, color: color)),
                        Text('€${value.toStringAsFixed(2)}',
                            style: TextStyle(fontSize: 12, color: color)),
                      ],
                    ));
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Column(children: [
                      // balance text
                      Text(
                        'Balance: €${balance.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize   : 24,
                          fontWeight : FontWeight.bold,
                          color      : balance >= 0 ? Colors.green : Colors.red,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // pie chart + pig
                      SizedBox(
                        width : 260, height: 260,
                        child: Stack(alignment: Alignment.center, children: [
                          PieChart(PieChartData(sections: sections, centerSpaceRadius: 80)),
                          Image.asset('assets/images/pig_idle.png', width: 120),
                        ]),
                      ),
                      const SizedBox(height: 24),

                      // dynamic icons under chart
                      Wrap(spacing: 24, runSpacing: 16, alignment: WrapAlignment.center, children: icons),

                      const SizedBox(height: 32),

                      // add expense/income buttons
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

                      // totals at bottom
                      Text('Income this month: €${totalInc.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 16, color: Colors.green)),
                      Text('Expenses this month: €${totalExp.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 16, color: Colors.red)),
                    ]),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
