import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:inward_outward_management/providers/company_provider.dart';
import 'package:inward_outward_management/utils/app_colors.dart';
import 'package:inward_outward_management/utils/responsive.dart';
import 'package:inward_outward_management/widgets/app_form_field.dart';
import 'package:inward_outward_management/widgets/app_scaffold.dart';
import 'package:inward_outward_management/widgets/primary_button.dart';
import 'package:provider/provider.dart';

class CreateUserScreen extends StatefulWidget {
  const CreateUserScreen({super.key});

  @override
  State<CreateUserScreen> createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends State<CreateUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String _role = 'supplier';
  bool _submitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    return AppScaffold(
      title: 'Create User',
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(r.wp(4)),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create Supplier / Customer Login',
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontSize: r.sp(14),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: r.hp(2)),
                AppFormField(
                  controller: _emailController,
                  label: 'Email',
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Email is required';
                    }
                    if (!v.contains('@')) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: r.hp(1.2)),
                AppFormField(
                  controller: _passwordController,
                  label: 'Password',
                  validator: (v) {
                    if (v == null || v.length < 6) {
                      return 'Min 6 characters';
                    }
                    return null;
                  },
                ),
                SizedBox(height: r.hp(1.2)),
                AppFormField(
                  controller: _confirmPasswordController,
                  label: 'Confirm Password',
                  validator: (v) {
                    if (v != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                SizedBox(height: r.hp(1.2)),
                Text(
                  'Role',
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontSize: r.sp(12),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: r.hp(0.6)),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: r.wp(3)),
                  decoration: BoxDecoration(
                    color: AppColors.greyBackground,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.greyBackground),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _role,
                      items: const [
                        DropdownMenuItem(
                          value: 'supplier',
                          child: Text('Supplier'),
                        ),
                        DropdownMenuItem(
                          value: 'customer',
                          child: Text('Customer'),
                        ),
                      ],
                      onChanged: (val) {
                        if (val == null) return;
                        setState(() => _role = val);
                      },
                      dropdownColor: AppColors.greyBackground,
                      style: TextStyle(
                        color: AppColors.textLight,
                        fontSize: r.sp(12),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: r.hp(3)),
                PrimaryButton(
                  label: 'Create User',
                  loading: _submitting,
                  onTap: () async {
                    if (!_formKey.currentState!.validate()) return;
                    setState(() => _submitting = true);
                    try {
                      final email = _emailController.text.trim();
                      final password = _passwordController.text.trim();

                      // // capture current company id
                      // final companyProv =
                      //     Provider.of<CompanyProvider>(context, listen: false);
                      // final companyId = companyProv.companyId;

                      // create auth user (this will sign in as the new user)
                      final cred = await FirebaseAuth.instance
                          .createUserWithEmailAndPassword(
                            email: email,
                            password: password,
                          );

                      final uid = cred.user?.uid;
                      if (uid == null) {
                        throw Exception('User ID not returned');
                      }

                      // write users document with role and companyId
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(uid)
                          .set({
                            'email': email,
                            'role': _role,
                            // 'companyId': companyId,
                            'createdAt': DateTime.now().millisecondsSinceEpoch,
                          });

                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'User created. Please log in again as company.',
                          ),
                        ),
                      );

                      // after creating, sign out and go to login
                      await FirebaseAuth.instance.signOut();
                      if (!mounted) return;
                      Navigator.of(
                        context,
                      ).pushNamedAndRemoveUntil('/login', (route) => false);
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to create user: $e')),
                        );
                      }
                    } finally {
                      if (mounted) {
                        setState(() => _submitting = false);
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
