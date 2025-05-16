// lib/models/expense.dart
// Model representing an expense entry
class Expense {
  final double amount;
  final String category;
  final String description;
  final DateTime date;

  Expense({
    required this.amount,
    required this.category,
    required this.description,
    required this.date,
  });
}