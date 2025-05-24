// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'signup_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _loading = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await AuthService.instance
        .signIn(_emailCtrl.text.trim(), _passCtrl.text);
      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Login failed'))
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            TextFormField(
              controller: _emailCtrl,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: (v) => v != null && v.contains('@') ? null : 'Enter a valid email',
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _passCtrl,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
              validator: (v) => v != null && v.length >= 6 ? null : 'Min 6 characters',
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loading ? null : _login,
              child: _loading
                ? const CircularProgressIndicator()
                : const Text('Sign In'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/signup'),
              child: const Text("Don't have an account? Sign Up"),
            ),
          ]),
        ),
      ),
    );
  }
}
