import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:inward_outward_management/providers/customer_provider.dart';
import 'package:inward_outward_management/utils/app_colors.dart';
import 'package:inward_outward_management/utils/responsive.dart';
import 'package:inward_outward_management/widgets/primary_button.dart';
import 'package:provider/provider.dart';

class CustomerLoginScreen extends StatefulWidget {
  const CustomerLoginScreen({super.key});

  @override
  State<CustomerLoginScreen> createState() => _CustomerLoginScreenState();
}

class _CustomerLoginScreenState extends State<CustomerLoginScreen> {
  final _mobileCtr = TextEditingController();
  final _passwordCtr = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _mobileCtr.dispose();
    _passwordCtr.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final mobile = _mobileCtr.text.trim();
    final password = _passwordCtr.text;

    if (mobile.isEmpty) {
      _showSnack('Enter mobile number');
      return;
    }
    if (password.isEmpty) {
      _showSnack('Enter password');
      return;
    }

    setState(() => _loading = true);

    try {
      final snap = await FirebaseFirestore.instance
          .collection('customers')
          .where('mobile', isEqualTo: mobile)
          .limit(1)
          .get();

      if (snap.docs.isEmpty) {
        _showSnack('Customer not found');
        return;
      }

      final data = snap.docs.first.data();
      final storedPassword = data['password']?.toString() ?? '';

      if (storedPassword != password) {
        _showSnack('Invalid mobile or password');
        return;
      }

      // Store current customer mobile in provider
      final customerProv =
          Provider.of<CustomerProvider>(context, listen: false);
      customerProv.setCurrentCustomerMobile(mobile);

      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/customerDashboard');
    } catch (e) {
      _showSnack('Login failed: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    return Scaffold(
      backgroundColor: const Color(0xFF28343A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF28343A),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Customer Login',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: r.wp(6), vertical: r.hp(4)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Login as Customer',
                style: TextStyle(
                  fontSize: r.sp(18),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: r.hp(1)),
              Text(
                'Enter your registered mobile number and password.',
                style: TextStyle(
                  fontSize: r.sp(11),
                  color: Colors.white70,
                ),
              ),
              SizedBox(height: r.hp(3)),
              TextField(
                controller: _mobileCtr,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Mobile Number',
                  labelStyle: const TextStyle(color: Colors.white70),
                  prefixIcon: const Icon(Icons.phone, color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.white70),
                  ),
                ),
              ),
              SizedBox(height: r.hp(2)),
              TextField(
                controller: _passwordCtr,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: const TextStyle(color: Colors.white70),
                  prefixIcon: const Icon(Icons.lock, color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.white70),
                  ),
                ),
              ),
              SizedBox(height: r.hp(3)),
              PrimaryButton(
                label: 'Login',
                loading: _loading,
                onTap: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
