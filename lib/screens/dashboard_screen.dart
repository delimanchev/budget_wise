// lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lottie/lottie.dart';

enum PigState { idle, happy, sad }

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final List<String> incomeCategories = ['Salary', 'Investments', 'Savings'];
  final List<String> expenseCategories = [
    'Bills', 'Car', 'Clothes', 'Food', 'Entertainment', 'Health'
  ];
  final Map<String, IconData> categoryIcons = {
    'Salary': Icons.attach_money,
    'Investments': Icons.trending_up,
    'Savings': Icons.savings,
    'Bills': Icons.receipt_long,
    'Car': Icons.directions_car,
    'Clothes': Icons.checkroom,
    'Food': Icons.fastfood,
    'Entertainment': Icons.movie,
    'Health': Icons.local_hospital,
  };

  /// Shows a full-screen animated popup: Lottie above pig image, scales in.
  void _showAnimatedPig(PigState state) {
    final pigAsset = state == PigState.happy
        ? 'assets/images/pig_happy.png'
        : 'assets/images/pig_sad.png';
    final animationAsset = state == PigState.happy
        ? 'assets/animations/coins.json'
        : 'assets/animations/cloud_rain.json';

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (_, animation, __, ___) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutBack);
        return ScaleTransition(
          scale: Tween<double>(begin: 0.5, end: 1.0).animate(curved),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(
                  animationAsset,
                  width: 300,
                  repeat: false,
                ),
            //  const SizedBox(height: 16),
                Image.asset(pigAsset, width: 250),
              ],
            ),
          ),
        );
      },
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    });
  }

  /// Bottom-sheet form for income/expense, then trigger the animated pig.
  void _addTransaction({required bool isIncome}) {
    final cats = isIncome ? incomeCategories : expenseCategories;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        String? selectedCategory;
        final amountCtrl = TextEditingController();
        final descCtrl = TextEditingController();
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16, right: 16, top: 16,
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(
              isIncome ? 'Add Income' : 'Add Expense',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              items: cats
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              decoration: const InputDecoration(labelText: 'Category'),
              onChanged: (v) => selectedCategory = v,
            ),
            TextField(
              controller: amountCtrl,
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
                final amt = double.tryParse(amountCtrl.text);
                if (amt != null && selectedCategory != null) {
                  Navigator.pop(context);
                  _showAnimatedPig(
                      isIncome ? PigState.happy : PigState.sad);
                }
              },
              child: const Text('Confirm'),
            ),
            const SizedBox(height: 16),
          ]),
        );
      },
    );
  }

  /// Renders the center pie chart with your piggy in the middle.
  Widget _buildChartWithPig() {
    return SizedBox(
      width: 260,
      height: 260,
      child: Stack(alignment: Alignment.center, children: [
        PieChart(
          PieChartData(
            sections: List.generate(expenseCategories.length, (i) {
              return PieChartSectionData(
                value: 1,
                color: Colors.primaries[i % Colors.primaries.length],
                radius: 40,
                showTitle: false,
              );
            }),
            centerSpaceRadius: 80,
          ),
        ),
        Image.asset('assets/images/pig_idle.png', width: 120),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        _buildChartWithPig(),
        const SizedBox(height: 24),
        Wrap(
          spacing: 24,
          runSpacing: 16,
          alignment: WrapAlignment.center,
          children: expenseCategories.map((c) {
            return Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(categoryIcons[c]!, size: 32),
              const SizedBox(height: 4),
              Text(c, style: const TextStyle(fontSize: 12)),
            ]);
          }).toList(),
        ),
        const SizedBox(height: 32),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48),
          child: Row(children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
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
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                ),
                onPressed: () => _addTransaction(isIncome: true),
                child: Icon(Icons.add, size: 32, color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}
