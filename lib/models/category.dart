// lib/models/category.dart
import 'package:flutter/material.dart';
// Model representing a transaction category
class Category {
  final String name;
  final IconData iconData;
  final bool isIncome;

  Category({
    required this.name,
    required this.iconData,
    required this.isIncome,
  });
}