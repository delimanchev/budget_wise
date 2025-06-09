import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/expense.dart';
import '../models/category.dart';
import 'encryption_service.dart';

class FirestoreService {
  FirestoreService._();
  static final instance = FirestoreService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _userCol(String uid, String col) =>
      _db.collection('users').doc(uid).collection(col);

  Future<void> addExpense(Expense e) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return _userCol(uid, 'expenses').add({
      'amount': EncryptionService.encryptText(e.amount.toString()),
      'category': EncryptionService.encryptText(e.category),
      'description': EncryptionService.encryptText(e.description),
      'date': e.date.toIso8601String(),
      'userId': uid,
    });
  }

  Stream<List<Expense>> watchExpenses() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return _userCol(uid, 'expenses')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) {
              final d = doc.data();
              try {
                return Expense(
                  amount:
                      double.parse(EncryptionService.decryptText(d['amount'])),
                  category: EncryptionService.decryptText(d['category']),
                  description: EncryptionService.decryptText(d['description']),
                  date: DateTime.parse(d['date'] as String),
                );
              } catch (e) {
                print('Greška prilikom dekripcije expense: $e');
                return null;
              }
            })
            .whereType<Expense>()
            .toList());
  }

  Future<void> addIncome(Expense e) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return _userCol(uid, 'incomes').add({
      'amount': EncryptionService.encryptText(e.amount.toString()),
      'category': EncryptionService.encryptText(e.category),
      'description': EncryptionService.encryptText(e.description),
      'date': e.date.toIso8601String(),
      'userId': uid,
    });
  }

  Stream<List<Expense>> watchIncomes() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return _userCol(uid, 'incomes')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) {
              final d = doc.data();
              try {
                return Expense(
                  amount:
                      double.parse(EncryptionService.decryptText(d['amount'])),
                  category: EncryptionService.decryptText(d['category']),
                  description: EncryptionService.decryptText(d['description']),
                  date: DateTime.parse(d['date'] as String),
                );
              } catch (e) {
                print('Greška prilikom dekripcije income: $e');
                return null;
              }
            })
            .whereType<Expense>()
            .toList());
  }

  Future<void> addCategory(Category c) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return _userCol(uid, 'categories').add({
      'name': c.name,
      'iconCode': c.iconData.codePoint,
      'iconFont': c.iconData.fontFamily,
      'isIncome': c.isIncome,
      'userId': uid,
    });
  }

  Future<void> createUserIfNotExists(User user) async {
    final docRef = _db.collection('users').doc(user.uid);
    final doc = await docRef.get();

    if (!doc.exists) {
      await docRef.set({
        'email': user.email,
        'name': user.displayName ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> deleteCategory(String id) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return _userCol(uid, 'categories').doc(id).delete();
  }

  Future<List<Category>> getCategoriesOnce() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final snap = await _userCol(uid, 'categories').get();
    return snap.docs.map((doc) => Category.fromFirestore(doc)).toList();
  }

  Stream<List<Category>> watchCategories() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return _userCol(uid, 'categories').snapshots().map(
        (snap) => snap.docs.map((doc) => Category.fromFirestore(doc)).toList());
  }

  Future<List<Expense>> getIncomes() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('incomes').get();
    return snapshot.docs.map((doc) => Expense.fromFirestore(doc)).toList();
  }

  Future<List<Expense>> getExpenses() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('expenses').get();
    return snapshot.docs.map((doc) => Expense.fromFirestore(doc)).toList();
  }

  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.exists ? doc.data() : null;
  }

  Future<void> deleteUserProfile(String uid) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).delete();
  }
}
