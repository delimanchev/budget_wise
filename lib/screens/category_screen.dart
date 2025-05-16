// lib/screens/category_screen.dart
import 'package:flutter/material.dart';
import '../models/category.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({Key? key}) : super(key: key);

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  // Initial categories
  List<Category> _incomeCategories = [
    Category(name: 'Salary', iconData: Icons.attach_money, isIncome: true),
    Category(name: 'Investments', iconData: Icons.trending_up, isIncome: true),
    Category(name: 'Savings', iconData: Icons.savings, isIncome: true),
  ];
  List<Category> _expenseCategories = [
    Category(name: 'Food', iconData: Icons.fastfood, isIncome: false),
    Category(name: 'Bills', iconData: Icons.receipt_long, isIncome: false),
    Category(name: 'Entertainment', iconData: Icons.movie, isIncome: false),
  ];

  // Available icons for new categories
  final Map<String, IconData> _availableIcons = {
    'Money': Icons.attach_money,
    'Trending Up': Icons.trending_up,
    'Savings': Icons.savings,
    'Receipt': Icons.receipt_long,
    'Food': Icons.fastfood,
    'Entertainment': Icons.movie,
    'Health': Icons.local_hospital,
    'Transport': Icons.directions_car,
  };

  void _addCategory(bool isIncome) {
    final formKey = GlobalKey<FormState>();
    String? name;
    IconData? icon;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isIncome ? 'New Income Category' : 'New Expense Category'),
        content: Form(
          key: formKey,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Category Name'),
              validator: (val) => (val == null || val.isEmpty) ? 'Required' : null,
              onSaved: (val) => name = val,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<IconData>(
              decoration: const InputDecoration(labelText: 'Icon'),
              items: _availableIcons.entries
                  .map((e) => DropdownMenuItem(
                        value: e.value,
                        child: Row(children: [
                          Icon(e.value),
                          const SizedBox(width: 8),
                          Text(e.key),
                        ]),
                      ))
                  .toList(),
              onChanged: (val) => icon = val,
              validator: (val) => val == null ? 'Required' : null,
            ),
          ]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();
                final newCat = Category(
                  name: name!,
                  iconData: icon!,
                  isIncome: isIncome,
                );
                setState(() {
                  if (isIncome) {
                    _incomeCategories.insert(0, newCat);
                  } else {
                    _expenseCategories.insert(0, newCat);
                  }
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Income Categories', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            // Display as list instead of dropdown
            ..._incomeCategories.map((cat) => ListTile(
                  leading: Icon(cat.iconData),
                  title: Text(cat.name),
                )),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _addCategory(true),
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Add Income Category'),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Expense Categories', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ..._expenseCategories.map((cat) => ListTile(
                  leading: Icon(cat.iconData),
                  title: Text(cat.name),
                )),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _addCategory(false),
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Add Expense Category'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}