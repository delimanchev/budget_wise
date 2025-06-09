import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budget_wise/models/category.dart';

void main() {
  test('Filter only income categories', () {
    final categories = [
      Category(
          name: 'Salary',
          iconData: const IconData(0xe227, fontFamily: 'MaterialIcons'),
          isIncome: true,
          id: ''),
      Category(
          name: 'Food',
          iconData: const IconData(0xe56c, fontFamily: 'MaterialIcons'),
          isIncome: false,
          id: ''),
      Category(
          name: 'Freelance',
          iconData: const IconData(0xe227, fontFamily: 'MaterialIcons'),
          isIncome: true,
          id: ''),
    ];

    final incomeCategories = categories.where((c) => c.isIncome).toList();

    expect(incomeCategories.length, 2);
    expect(incomeCategories.every((c) => c.isIncome), true);
  });
}
