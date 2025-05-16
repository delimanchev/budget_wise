import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const BudgetWiseApp());
}

class BudgetWiseApp extends StatelessWidget {
  const BudgetWiseApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BudgetWise',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFFADD8E6)),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
