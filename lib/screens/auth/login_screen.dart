// lib/screens/auth/login_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:inward_outward_management/providers/auth_provider.dart';
import 'package:inward_outward_management/utils/responsive.dart';
import 'package:inward_outward_management/widgets/app_logo.dart';
import 'package:inward_outward_management/widgets/rounded_textfield.dart';
import 'package:inward_outward_management/widgets/primary_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtr = TextEditingController();
  final _passwordCtr = TextEditingController();

  @override
  void dispose() {
    _emailCtr.dispose();
    _passwordCtr.dispose();
    super.dispose();
  }

  // lib/screens/auth/login_screen.dart
  // keep other code the same; replace the _submit method with this:
  Future<void> _submit() async {
    final email = _emailCtr.text.trim();
    final password = _passwordCtr.text;

    if (!email.contains('@')) return _showSnack('Enter valid email');
    if (password.length < 6)
      return _showSnack('Password must be at least 6 chars');

    final auth = Provider.of<AuthProvider>(context, listen: false);

    // Call provider signIn which returns normalized role or null
    final role = await auth.signInWithEmail(email: email, password: password);

    if (role != null) {
      // Navigation centralized to RoleRouter to decide the exact dashboard
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/roleRouter');
    } else {
      // Show provider error (already set inside provider)
      _showSnack(auth.error ?? 'Login failed');
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF28343A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: r.wp(6), vertical: r.hp(4)),
          child: Column(
            children: [
              AppLogo(assetPath: 'assets/images/logo.png', diameterPercent: 18),
              SizedBox(height: r.hp(3)),
              Text(
                'Welcome Back',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: r.sp(20),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: r.hp(1)),
              Text(
                'Sign in to continue to Inward-Outward Management',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: r.sp(11), color: Colors.white70),
              ),
              SizedBox(height: r.hp(4)),
              RoundedTextField(
                controller: _emailCtr,
                hint: 'Email',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.email),
              ),
              SizedBox(height: r.hp(2)),
              RoundedTextField(
                controller: _passwordCtr,
                hint: 'Password',
                obscure: true,
                prefixIcon: const Icon(Icons.lock),
              ),
              SizedBox(height: r.hp(2)),
              if (auth.error != null) ...[
                Text(auth.error!, style: const TextStyle(color: Colors.red)),
                SizedBox(height: r.hp(1)),
              ],
              PrimaryButton(
                label: 'Login',
                onTap: _submit,
                loading: auth.loading,
              ),
              SizedBox(height: r.hp(2)),
              TextButton(
                onPressed: () =>
                    _showSnack('Forgot password flow - implement later'),
                child: Text(
                  'Forgot password?',
                  style: TextStyle(color: Colors.white70, fontSize: r.sp(11)),
                ),
              ),
              SizedBox(height: r.hp(3)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: TextStyle(color: Colors.white70, fontSize: r.sp(11)),
                  ),
                  GestureDetector(
                    onTap: () =>
                        Navigator.of(context).pushReplacementNamed('/register'),
                    child: Text(
                      'Register',
                      style: TextStyle(
                        color: Colors.greenAccent,
                        fontSize: r.sp(11),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
