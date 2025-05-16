// lib/screens/expenses_screen.dart
import 'package:flutter/material.dart';
import '../models/expense.dart';

/// Types of filters available
enum ExpenseFilter {
  day,
  week,
  month,
  year,
  all,
  interval,
  specificDate,
}

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({Key? key}) : super(key: key);

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  // Placeholder expenses; replace with your real data source
  static final List<Expense> _allExpenses = [
    Expense(
      amount: 12.50,
      category: 'Food',
      description: 'Lunch',
      date: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    Expense(
      amount: 75.00,
      category: 'Bills',
      description: 'Electricity',
      date: DateTime.now().subtract(const Duration(days: 3)),
    ),
    Expense(
      amount: 45.20,
      category: 'Entertainment',
      description: 'Movie tickets',
      date: DateTime.now().subtract(const Duration(days: 10)),
    ),
  ];

  ExpenseFilter _selectedFilter = ExpenseFilter.all;
  DateTimeRange? _selectedInterval;
  DateTime? _selectedDate;

  /// Presents the filter sheet and handles user choice
  void _showFilterSheet() async {
    final choice = await showModalBottomSheet<ExpenseFilter>(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: ExpenseFilter.values.map((f) {
          final label = {
            ExpenseFilter.day: 'Day',
            ExpenseFilter.week: 'Week',
            ExpenseFilter.month: 'Month',
            ExpenseFilter.year: 'Year',
            ExpenseFilter.all: 'All',
            ExpenseFilter.interval: 'Interval',
            ExpenseFilter.specificDate: 'Specific Date',
          }[f]!;
          return ListTile(
            title: Text(label),
            onTap: () => Navigator.pop(context, f),
          );
        }).toList(),
      ),
    );

    if (choice == null) return;

    if (choice == ExpenseFilter.specificDate) {
      final date = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime.now(),
      );
      if (date != null) {
        setState(() {
          _selectedFilter = choice;
          _selectedDate = date;
        });
      }
    } else if (choice == ExpenseFilter.interval) {
      final range = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2000),
        lastDate: DateTime.now(),
      );
      if (range != null) {
        setState(() {
          _selectedFilter = choice;
          _selectedInterval = range;
        });
      }
    } else {
      setState(() {
        _selectedFilter = choice;
      });
    }
  }

  /// Returns the filtered list based on _selectedFilter
  List<Expense> get _filteredExpenses {
    final now = DateTime.now();
    switch (_selectedFilter) {
      case ExpenseFilter.day:
        return _allExpenses.where((e) =>
            e.date.year == now.year &&
            e.date.month == now.month &&
            e.date.day == now.day).toList();
      case ExpenseFilter.week:
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        return _allExpenses.where((e) =>
            e.date.isAfter(startOfWeek.subtract(const Duration(seconds: 1))) &&
            e.date.isBefore(now.add(const Duration(days: 1)))).toList();
      case ExpenseFilter.month:
        return _allExpenses.where((e) =>
            e.date.year == now.year && e.date.month == now.month).toList();
      case ExpenseFilter.year:
        return _allExpenses.where((e) => e.date.year == now.year).toList();
      case ExpenseFilter.specificDate:
        if (_selectedDate == null) return _allExpenses;
        return _allExpenses.where((e) =>
            e.date.year == _selectedDate!.year &&
            e.date.month == _selectedDate!.month &&
            e.date.day == _selectedDate!.day).toList();
      case ExpenseFilter.interval:
        if (_selectedInterval == null) return _allExpenses;
        return _allExpenses.where((e) =>
            e.date.isAfter(_selectedInterval!.start.subtract(const Duration(seconds: 1))) &&
            e.date.isBefore(_selectedInterval!.end.add(const Duration(days: 1)))).toList();
      case ExpenseFilter.all:
      return _allExpenses;
    }
  }

  @override
  Widget build(BuildContext context) {
    final expenses = _filteredExpenses;
    return Column(
      children: [
        // Filter bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text(
                'Filter: ${_selectedFilter.name}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: _showFilterSheet,
              ),
            ],
          ),
        ),

        // Expense list
        Expanded(
          child: expenses.isEmpty
              ? const Center(child: Text('No expenses found.'))
              : ListView.builder(
                  itemCount: expenses.length,
                  itemBuilder: (context, i) {
                    final e = expenses[i];
                    return ListTile(
                      title: Text('${e.category} — €${e.amount.toStringAsFixed(2)}'),
                      subtitle: Text(e.description),
                      trailing: Text(
                        '${e.date.day}.${e.date.month}.${e.date.year}',
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
