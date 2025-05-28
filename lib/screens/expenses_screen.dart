import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/firestore_service.dart';

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
  ExpenseFilter _selectedFilter = ExpenseFilter.all;
  DateTimeRange? _selectedInterval;
  DateTime? _selectedDate;

  /// Shows the bottom‐sheet for picking a filter
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

  List<Expense> _applyFilter(List<Expense> all) {
    final now = DateTime.now();
    switch (_selectedFilter) {
      case ExpenseFilter.day:
        return all.where((e) =>
          e.date.year == now.year &&
          e.date.month == now.month &&
          e.date.day == now.day
        ).toList();
      case ExpenseFilter.week:
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        return all.where((e) =>
          e.date.isAfter(startOfWeek.subtract(const Duration(seconds: 1))) &&
          e.date.isBefore(now.add(const Duration(days: 1)))
        ).toList();
      case ExpenseFilter.month:
        return all.where((e) =>
          e.date.year == now.year && e.date.month == now.month
        ).toList();
      case ExpenseFilter.year:
        return all.where((e) =>
          e.date.year == now.year
        ).toList();
      case ExpenseFilter.specificDate:
        if (_selectedDate == null) return all;
        return all.where((e) =>
          e.date.year == _selectedDate!.year &&
          e.date.month == _selectedDate!.month &&
          e.date.day == _selectedDate!.day
        ).toList();
      case ExpenseFilter.interval:
        if (_selectedInterval == null) return all;
        return all.where((e) =>
          e.date.isAfter(_selectedInterval!.start.subtract(const Duration(seconds: 1))) &&
          e.date.isBefore(_selectedInterval!.end.add(const Duration(days: 1)))
        ).toList();
      case ExpenseFilter.all:
      default:
        return all;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text(
                'Filter: ${_selectedFilter.name}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: _showFilterSheet,
              ),
            ],
          ),
        ),

        Expanded(
          child: StreamBuilder<List<Expense>>(
            stream: FirestoreService.instance.watchExpenses(),
            builder: (ctx, snapshot) {
              if (snapshot.connectionState != ConnectionState.active) {
                return const Center(child: CircularProgressIndicator());
              }
              final all = snapshot.data ?? [];
              final expenses = _applyFilter(all);

              if (expenses.isEmpty) {
                return const Center(child: Text('No expenses found.'));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: expenses.length,
                itemBuilder: (context, i) {
                  final e = expenses[i];
                  return ListTile(
                    leading: const Icon(
                      Icons.arrow_circle_up,
                      color: Colors.redAccent,
                    ),
                    title: Text(
                      '${e.category} — €${e.amount.toStringAsFixed(2)}',
                    ),
                    subtitle: Text(e.description),
                    trailing: Text(
                      '${e.date.day}.${e.date.month}.${e.date.year}',
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
