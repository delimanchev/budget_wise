// lib/screens/category_screen.dart

import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/firestore_service.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({Key? key}) : super(key: key);
  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  /// Your built-in defaults
  final _initialDefaults = <Category>[
    Category(id: '', name: 'Salary',       iconData: Icons.attach_money,   isIncome: true),
    Category(id: '', name: 'Investments',  iconData: Icons.trending_up,    isIncome: true),
    Category(id: '', name: 'Savings',      iconData: Icons.savings,        isIncome: true),
    Category(id: '', name: 'Food',         iconData: Icons.fastfood,       isIncome: false),
    Category(id: '', name: 'Bills',        iconData: Icons.receipt_long,   isIncome: false),
    Category(id: '', name: 'Entertainment',iconData: Icons.movie,          isIncome: false),
    Category(id: '', name: 'Health',       iconData: Icons.local_hospital, isIncome: false),
  ];

  bool _didSeedDefaults = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Categories'), centerTitle: true),
      body: StreamBuilder<List<Category>>(
        stream: FirestoreService.instance.watchCategories(),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          var cats = snap.data ?? [];

          // Seed defaults once if empty
          if (!_didSeedDefaults && cats.isEmpty) {
            _didSeedDefaults = true;
            for (var c in _initialDefaults) {
              FirestoreService.instance.addCategory(c);
            }
            cats = _initialDefaults;
          }

          // Split into income vs expense
          final incomes  = cats.where((c) => c.isIncome).toList();
          final expenses = cats.where((c) => !c.isIncome).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text('Income Categories',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...incomes.map((c) => ListTile(
                    leading: Icon(c.iconData, color: Colors.green),
                    title: Text(c.name),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () =>
                          FirestoreService.instance.deleteCategory(c.id),
                    ),
                  )),
              const Divider(),

              const Text('Expense Categories',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...expenses.map((c) => ListTile(
                    leading: Icon(c.iconData, color: Colors.red),
                    title: Text(c.name),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () =>
                          FirestoreService.instance.deleteCategory(c.id),
                    ),
                  )),
            ],
          );
        },
      ),

      // TWO FABs: one for income, one for expense
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'addIncome',
            onPressed: () => _showAddDialog(isIncome: true),
            tooltip: 'Add Income Category',
            backgroundColor: Colors.green,
            child: const Icon(Icons.attach_money),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'addExpense',
            onPressed: () => _showAddDialog(isIncome: false),
            tooltip: 'Add Expense Category',
            backgroundColor: Colors.red,
            child: const Icon(Icons.fastfood),
          ),
        ],
      ),
    );
  }

  void _showAddDialog({ required bool isIncome }) {
    final formKey = GlobalKey<FormState>();
    String? name;
    IconData? icon;

    final availableIcons = {
      'Money': Icons.attach_money,
      'Trending Up': Icons.trending_up,
      'Savings': Icons.savings,
      'Receipt': Icons.receipt_long,
      'Food': Icons.fastfood,
      'Entertainment': Icons.movie,
      'Health': Icons.local_hospital,
      'Transport': Icons.directions_car,
    };

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isIncome ? 'New Income Category' : 'New Expense Category'),
        content: Form(
          key: formKey,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Category Name'),
              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              onSaved: (v) => name = v,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<IconData>(
              decoration: const InputDecoration(labelText: 'Icon'),
              items: availableIcons.entries
                  .map((e) => DropdownMenuItem(
                        value: e.value,
                        child: Row(children: [
                          Icon(e.value),
                          const SizedBox(width: 8),
                          Text(e.key),
                        ]),
                      ))
                  .toList(),
              onChanged: (v) => icon = v,
              validator: (v) => v == null ? 'Required' : null,
            ),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();
                final newCat = Category(
                  id: '',
                  name: name!,
                  iconData: icon!,
                  isIncome: isIncome,
                );
                FirestoreService.instance.addCategory(newCat);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
