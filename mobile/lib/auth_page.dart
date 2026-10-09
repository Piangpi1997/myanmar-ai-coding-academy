import 'package:flutter/material.dart';
import 'cloud_service.dart';
import 'l10n/generated/app_localizations.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key, this.recovery = false});
  final bool recovery;
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

  Future<void> submit({bool reset = false}) async {
    final l = AppLocalizations.of(context)!;
    final validEmail = RegExp(
      r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
    ).hasMatch(email.text.trim());
    if ((!widget.recovery && !validEmail) ||
        (!reset && password.text.length < 8)) {
      setState(() => message = l.authInvalid);
      return;
    }
    setState(() {
      loading = true;
      message = null;
    });
    try {
      if (widget.recovery) {
        await CloudService.updatePassword(password.text);
      } else if (reset) {
        await CloudService.resetPassword(email.text.trim());
      } else if (isSignUp) {
        await CloudService.signUp(email.text.trim(), password.text);
      } else {
        await CloudService.signIn(email.text.trim(), password.text);
      }
      password.clear();
      if (!mounted) return;
      if (!reset && CloudService.user != null) {
        Navigator.of(context).pop(true);
      } else {
        setState(() => message = l.checkEmail);
      }
    } catch (_) {
      if (mounted) setState(() => message = l.authFailed);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final title = widget.recovery
        ? l.updatePassword
        : isSignUp
        ? l.signUp
        : l.signIn;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Icon(Icons.school, size: 70, color: Color(0xFF00D9E8)),
          const SizedBox(height: 24),
          if (!widget.recovery)
            TextField(
              controller: email,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              enabled: !loading,
              decoration: InputDecoration(labelText: l.email),
            ),
          const SizedBox(height: 16),
          TextField(
            controller: password,
            obscureText: true,
            autocorrect: false,
            enableSuggestions: false,
            enableIMEPersonalizedLearning: false,
            enabled: !loading,
            decoration: InputDecoration(labelText: l.password),
          ),
          if (message != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Text(message!),
            ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: loading ? null : submit,
            child: Text(loading ? l.wait : title),
          ),
          if (!widget.recovery) ...[
            TextButton(
              onPressed: loading
                  ? null
                  : () => setState(() {
                      isSignUp = !isSignUp;
                      message = null;
                    }),
              child: Text(l.switchAuth),
            ),
            TextButton(
              onPressed: loading ? null : () => submit(reset: true),
              child: Text(l.forgotPassword),
            ),
          ],
        ],
      ),
    );
  }
}
