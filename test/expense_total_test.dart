import 'package:flutter_test/flutter_test.dart';
import 'package:budget_wise/models/expense.dart';

void main() {
  test('Calculate total expenses', () {
    final expenses = [
      Expense(
          amount: 10.0,
          category: 'Food',
          description: 'Lunch',
          date: DateTime.now()),
      Expense(
          amount: 25.5,
          category: 'Transport',
          description: 'Bus ticket',
          date: DateTime.now()),
      Expense(
          amount: 14.2,
          category: 'Other',
          description: 'Coffee',
          date: DateTime.now()),
    ];

    final total = expenses.fold(0.0, (sum, e) => sum + e.amount);

    expect(total, closeTo(49.7, 0.001));
  });
}
