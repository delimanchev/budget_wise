import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/expense.dart';
import '../models/category.dart';
import 'encryption_service.dart';

class FirestoreService {
  FirestoreService._();
  static final instance = FirestoreService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Helper koji uvek sigurno vrati UID (čeka da FirebaseAuth završi učitavanje)
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

  // Dodavanje Expense
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

  // Praćenje Expense streama
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

  // Dodavanje Income
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

  // Praćenje Income streama
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

  // Dodavanje kategorije
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

  // Čuvanje korisnika pri registraciji
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

  // Brisanje kategorije
  Future<void> deleteCategory(String id) async {
    final uid = await getCurrentUid();
    await _userCol(uid, 'categories').doc(id).delete();
  }

  // Dohvatanje svih kategorija
  Future<List<Category>> getCategoriesOnce() async {
    final uid = await getCurrentUid();
    final snap = await _userCol(uid, 'categories').get();
    return snap.docs.map((doc) => Category.fromFirestore(doc)).toList();
  }

  // Stream za kategorije
  Stream<List<Category>> watchCategories() async* {
    final uid = await getCurrentUid();
    yield* _userCol(uid, 'categories').snapshots().map(
        (snap) => snap.docs.map((doc) => Category.fromFirestore(doc)).toList());
  }

  // Čitanje svih incomes za carry-over
  Future<List<Expense>> getIncomes() async {
    final uid = await getCurrentUid();
    final snapshot = await _userCol(uid, 'incomes').get();
    return snapshot.docs.map((doc) => Expense.fromFirestore(doc)).toList();
  }

  // Čitanje svih expenses za carry-over
  Future<List<Expense>> getExpenses() async {
    final uid = await getCurrentUid();
    final snapshot = await _userCol(uid, 'expenses').get();
    return snapshot.docs.map((doc) => Expense.fromFirestore(doc)).toList();
  }

  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.exists ? doc.data() : null;
  }

  Future<void> deleteUserProfile(String uid) async {
    await _db.collection('users').doc(uid).delete();
  }
}
