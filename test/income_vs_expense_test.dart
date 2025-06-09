import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Income should be greater than expenses', () {
    final totalIncome = 1200.0;
    final totalExpenses = 800.0;

    expect(totalIncome > totalExpenses, true);
  });

  test('Fails when expenses exceed income', () {
    final totalIncome = 500.0;
    final totalExpenses = 800.0;

    expect(totalIncome > totalExpenses, false);
  });
}
