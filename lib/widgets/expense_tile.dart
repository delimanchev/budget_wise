// lib/widgets/expense_tile.dart
import 'package:flutter/material.dart';
import '../models/expense.dart';

class ExpenseTile extends StatelessWidget {
  final Expense expense;
  const ExpenseTile({required this.expense});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('${expense.category} - €${expense.amount.toStringAsFixed(2)}'),
      subtitle: Text(expense.description),
      trailing: Text(
          '${expense.date.day}.${expense.date.month}.${expense.date.year}'),
    );
  }
}
