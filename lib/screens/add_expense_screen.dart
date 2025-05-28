import 'package:flutter/material.dart';
import '../models/expense.dart';

class AddExpenseScreen extends StatefulWidget {
  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  double? _amount;
  String? _category;
  String? _description;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Expense')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Amount (€)'),
                keyboardType: TextInputType.number,
                onSaved: (val) => _amount = double.tryParse(val!),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Category'),
                onSaved: (val) => _category = val,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Description'),
                onSaved: (val) => _description = val,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _formKey.currentState!.save();
                  if (_amount != null && _category != null) {
                    Navigator.pop(
                        context,
                        Expense(
                            amount: _amount!,
                            category: _category!,
                            description: _description ?? '',
                            date: DateTime.now()));
                  }
                },
                child: Text('Add'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
