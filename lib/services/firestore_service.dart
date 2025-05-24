// lib/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/expense.dart';
import '../models/category.dart';

class FirestoreService {
  FirestoreService._();
  static final instance = FirestoreService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Helper to point at a user's sub-collection
  CollectionReference<Map<String, dynamic>> _userCol(String uid, String col) =>
      _db.collection('users').doc(uid).collection(col);

  // ─── Expenses ───────────────────────────────────────────────────────────────

  Future<void> addExpense(Expense e) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return _userCol(uid, 'expenses').add({
      'amount'     : e.amount,
      'category'   : e.category,
      'description': e.description,
      'date'       : e.date.toIso8601String(),
      'userId'     : uid,
    });
  }

  Stream<List<Expense>> watchExpenses() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return _userCol(uid, 'expenses')
      .orderBy('date', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map((doc) {
        final d = doc.data();
        return Expense(
          amount     : (d['amount'] as num).toDouble(),
          category   : d['category'] as String,
          description: d['description'] as String,
          date       : DateTime.parse(d['date'] as String),
        );
      }).toList());
  }

  // ─── Incomes ────────────────────────────────────────────────────────────────

  Future<void> addIncome(Expense e) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return _userCol(uid, 'incomes').add({
      'amount'     : e.amount,
      'category'   : e.category,
      'description': e.description,
      'date'       : e.date.toIso8601String(),
      'userId'     : uid,
    });
  }

  Stream<List<Expense>> watchIncomes() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return _userCol(uid, 'incomes')
      .orderBy('date', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map((doc) {
        final d = doc.data();
        return Expense(
          amount     : (d['amount'] as num).toDouble(),
          category   : d['category'] as String,
          description: d['description'] as String,
          date       : DateTime.parse(d['date'] as String),
        );
      }).toList());
  }

  // ─── Categories ────────────────────────────────────────────────────────────

  /// Add or seed a category document
  Future<void> addCategory(Category c) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return _userCol(uid, 'categories').add({
      'name'    : c.name,
      'iconCode': c.iconData.codePoint,
      'iconFont': c.iconData.fontFamily,
      'isIncome': c.isIncome,
      'userId'  : uid,
    });
  }

  /// Remove a category by its document ID
  Future<void> deleteCategory(String id) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return _userCol(uid, 'categories').doc(id).delete();
  }

  /// One-time fetch of all categories
  Future<List<Category>> getCategoriesOnce() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final snap = await _userCol(uid, 'categories').get();
    return snap.docs.map((doc) => Category.fromFirestore(doc)).toList();
  }

  /// Real-time stream of all categories
  Stream<List<Category>> watchCategories() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return _userCol(uid, 'categories')
      .snapshots()
      .map((snap) => snap.docs.map((doc) => Category.fromFirestore(doc)).toList());
  }
}
