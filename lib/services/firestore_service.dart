import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/expense.dart';
import '../models/category.dart';
import 'encryption_service.dart';

class FirestoreService {
  FirestoreService._();
  static final instance = FirestoreService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<String> getCurrentUid() async {
    var user = FirebaseAuth.instance.currentUser;
    if (user != null) return user.uid;
    user = await FirebaseAuth.instance
        .authStateChanges()
        .firstWhere((u) => u != null);
    return user!.uid;
  }

  CollectionReference<Map<String, dynamic>> _userCol(String uid, String col) =>
      _db.collection('users').doc(uid).collection(col);

  Future<void> addExpense(Expense e) async {
    final uid = await getCurrentUid();
    await _userCol(uid, 'expenses').add({
      'amount': EncryptionService.encryptText(e.amount.toString()),
      'category': EncryptionService.encryptText(e.category),
      'description': EncryptionService.encryptText(e.description),
      'date': e.date.toIso8601String(),
      'userId': uid,
    });
  }

  Stream<List<Expense>> watchExpenses() async* {
    final uid = await getCurrentUid();
    yield* _userCol(uid, 'expenses')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) {
              final d = doc.data();
              try {
                return Expense(
                  amount: double.tryParse(
                          EncryptionService.safeDecrypt(d['amount'])) ??
                      0.0,
                  category: EncryptionService.safeDecrypt(d['category']),
                  description: EncryptionService.safeDecrypt(d['description']),
                  date: DateTime.parse(d['date'] as String),
                );
              } catch (e) {
                print('Greška pri čitanju expenses: $e');
                return null;
              }
            })
            .whereType<Expense>()
            .toList());
  }

  Future<void> addIncome(Expense e) async {
    final uid = await getCurrentUid();
    await _userCol(uid, 'incomes').add({
      'amount': EncryptionService.encryptText(e.amount.toString()),
      'category': EncryptionService.encryptText(e.category),
      'description': EncryptionService.encryptText(e.description),
      'date': e.date.toIso8601String(),
      'userId': uid,
    });
  }

  Stream<List<Expense>> watchIncomes() async* {
    final uid = await getCurrentUid();
    yield* _userCol(uid, 'incomes')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) {
              final d = doc.data();
              try {
                return Expense(
                  amount: double.tryParse(
                          EncryptionService.safeDecrypt(d['amount'])) ??
                      0.0,
                  category: EncryptionService.safeDecrypt(d['category']),
                  description: EncryptionService.safeDecrypt(d['description']),
                  date: DateTime.parse(d['date'] as String),
                );
              } catch (e) {
                print('Greška pri čitanju incomes: $e');
                return null;
              }
            })
            .whereType<Expense>()
            .toList());
  }

  Future<void> addCategory(Category c) async {
    final uid = await getCurrentUid();
    await _userCol(uid, 'categories').add({
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

  Future<void> deleteCategory(String id) async {
    final uid = await getCurrentUid();
    await _userCol(uid, 'categories').doc(id).delete();
  }

  Future<List<Category>> getCategoriesOnce() async {
    final uid = await getCurrentUid();
    final snap = await _userCol(uid, 'categories').get();
    return snap.docs.map((doc) => Category.fromFirestore(doc)).toList();
  }

  Stream<List<Category>> watchCategories() async* {
    final uid = await getCurrentUid();
    yield* _userCol(uid, 'categories').snapshots().map(
        (snap) => snap.docs.map((doc) => Category.fromFirestore(doc)).toList());
  }

  Future<List<Expense>> getIncomes() async {
    final uid = await getCurrentUid();
    final snapshot = await _userCol(uid, 'incomes').get();
    return snapshot.docs
        .map((doc) => Expense.fromEncryptedFirestore(doc))
        .toList();
  }

  Future<List<Expense>> getExpenses() async {
    final uid = await getCurrentUid();
    final snapshot = await _userCol(uid, 'expenses').get();
    return snapshot.docs
        .map((doc) => Expense.fromEncryptedFirestore(doc))
        .toList();
  }

  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.exists ? doc.data() : null;
  }

  Future<void> deleteUserProfile(String uid) async {
    await _db.collection('users').doc(uid).delete();
  }
}
