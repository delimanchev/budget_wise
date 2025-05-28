import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  @override State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey    = GlobalKey<FormState>();
  final _emailCtrl  = TextEditingController();
  final _passCtrl   = TextEditingController();
  final _confirmCtrl= TextEditingController();
  bool _loading = false;

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await AuthService.instance
        .signUp(_emailCtrl.text.trim(), _passCtrl.text);
      Navigator.pushReplacementNamed(context, '/login');
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Sign up failed'))
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
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
            const SizedBox(height: 12),
            TextFormField(
              controller: _confirmCtrl,
              decoration: const InputDecoration(labelText: 'Confirm Password'),
              obscureText: true,
              validator: (v) =>
                v == _passCtrl.text ? null : 'Passwords do not match',
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loading ? null : _signup,
              child: _loading
                ? const CircularProgressIndicator()
                : const Text('Create Account'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
              child: const Text('Already have an account? Sign In'),
            ),
          ]),
        ),
      ),
    );
  }
}
