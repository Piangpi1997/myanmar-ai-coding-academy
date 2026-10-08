import 'package:flutter/material.dart';
import 'cloud_service.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});
  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool loading = false;
  bool isSignUp = false;
  String? message;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (email.text.trim().isEmpty || password.text.length < 6) {
      setState(() => message = 'Enter a valid email and a password of at least 6 characters.');
      return;
    }
    setState(() { loading = true; message = null; });
    try {
      if (isSignUp) {
        await CloudService.signUp(email.text.trim(), password.text);
      } else {
        await CloudService.signIn(email.text.trim(), password.text);
      }
      if (!mounted) return;
      if (CloudService.user != null) {
        Navigator.of(context).pop(true);
      } else {
        setState(() => message = 'Check your email for the confirmation link, then sign in.');
      }
    } catch (error) {
      if (mounted) setState(() => message = 'Authentication failed: $error');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(isSignUp ? 'Create account' : 'Sign in')),
    body: ListView(padding: const EdgeInsets.all(24), children: [
      const Icon(Icons.school, size: 70, color: Color(0xFF00D9E8)),
      const SizedBox(height: 12),
      const Text('Myanmar AI Coding Academy', textAlign: TextAlign.center,
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      const SizedBox(height: 24),
      TextField(controller: email, keyboardType: TextInputType.emailAddress,
        autocorrect: false, decoration: const InputDecoration(labelText: 'Email')),
      const SizedBox(height: 16),
      TextField(controller: password, obscureText: true,
        decoration: const InputDecoration(labelText: 'Password')),
      if (message != null) Padding(padding: const EdgeInsets.symmetric(vertical: 14),
        child: Text(message!, style: const TextStyle(color: Colors.amber))),
      const SizedBox(height: 16),
      FilledButton(onPressed: loading ? null : submit,
        child: Text(loading ? 'Please wait...' : (isSignUp ? 'Create account' : 'Sign in'))),
      TextButton(onPressed: loading ? null : () => setState(() {
        isSignUp = !isSignUp; message = null;
      }), child: Text(isSignUp ? 'Already have an account? Sign in' : 'Need an account? Sign up')),
    ]),
  );
}
