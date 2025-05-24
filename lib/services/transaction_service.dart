// lib/services/transaction_service.dart
import '../models/expense.dart';

class TransactionService {
  TransactionService._();
  static final TransactionService instance = TransactionService._();

  final List<Expense> _expenses = [];
  final List<Expense> _incomes  = [];

  List<Expense> get expenses => _expenses;
  List<Expense> get incomes  => _incomes;

  void addExpense(Expense e) => _expenses.add(e);
  void addIncome (Expense e) => _incomes .add(e);
}
