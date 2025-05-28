import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Category {
  final String id;
  final String name;
  final IconData iconData;
  final bool isIncome;

  Category({
    required this.id,
    required this.name,
    required this.iconData,
    required this.isIncome,
  });

  factory Category.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Category(
      id      : doc.id,
      name    : data['name'] as String,
      isIncome: data['isIncome'] as bool,
      iconData: IconData(
        data['iconCode'] as int,
        fontFamily: data['iconFont'] as String?,
      ),
    );
  }
}
