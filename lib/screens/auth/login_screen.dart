// lib/screens/auth/login_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:inward_outward_management/providers/auth_provider.dart';
import 'package:inward_outward_management/providers/company_provider.dart';
import 'package:inward_outward_management/providers/customer_provider.dart';
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
    final input = _emailCtr.text.trim();
    final password = _passwordCtr.text;

    if (input.isEmpty) return _showSnack('Enter email or mobile');
    if (password.length < 6)
      return _showSnack('Password must be at least 6 chars');

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final customerProv =
        Provider.of<CustomerProvider>(context, listen: false);

    // If input looks like a mobile (no '@'), first try customer login
    if (!input.contains('@')) {
      try {
        final snap = await FirebaseFirestore.instance
            .collection('customers')
            .where('mobile', isEqualTo: input)
            .limit(1)
            .get();

        if (snap.docs.isNotEmpty) {
          final data = snap.docs.first.data();
          final storedPassword = data['password']?.toString() ?? '';

          if (storedPassword == password) {
            // Successful customer login
            customerProv.setCurrentCustomerMobile(input);
            if (!mounted) return;
            Navigator.of(context)
                .pushReplacementNamed('/customerDashboard');
            return;
          }
        }
      } catch (e) {
        // If customer lookup fails, fall through to normal auth
        debugPrint('Customer lookup failed: $e');
      }
    }

    // Support both email and supplier mobile login via Firebase Auth.
    // If user types a mobile number (no '@') *and* customer login failed above,
    // map it to a synthetic email so that suppliers can log in.
    final String email;
    if (input.contains('@')) {
      email = input;
    } else {
      email = '$input@supplier.local';
    }

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

  /// Quick login: navigate directly to company dashboard.
  /// This does **not** perform authentication; it's only for fast access.
  Future<void> _quickLoginCompany() async {
    if (!mounted) return;
    final companyProv = Provider.of<CompanyProvider>(context, listen: false);
    // If no company is selected yet, set a demo company id so dashboard can load.
    if (companyProv.companyId.isEmpty) {
      companyProv.updateCompanyId('demo-company');
    }
    Navigator.of(context).pushReplacementNamed('/companyDashboard');
  }

  /// Show a bottom sheet listing available users for the given role
  /// and navigate to the respective dashboard after selection.
  Future<void> _showRolePicker(String role) async {
    if (!mounted) return;
 
    final isCustomer = role.toLowerCase() == 'customer';
    final isSupplier = role.toLowerCase() == 'supplier';

    try {
      List<Map<String, String>> items = [];

      if (isCustomer) {
        // Load customers from Firestore collection 'customers'
        final snap = await FirebaseFirestore.instance
            .collection('customers')
            .get();

        items = snap.docs.map((d) {
          final data = d.data();
          final name = data['name']?.toString() ?? 'Unknown';
          final mobile = data['mobile']?.toString() ?? d.id;
          return {
            'id': d.id,
            'name': name,
            'mobile': mobile,
          };
        }).toList();
      } else if (isSupplier) {
        // Supplier quick login: read from suppliers master collection
        final snap = await FirebaseFirestore.instance
            .collection('suppliers')
            .get();

        items = snap.docs.map((d) {
          final data = d.data();
          final name = data['name']?.toString() ?? 'Unknown';
          final mobile = data['mobile']?.toString() ?? '';
          final password = data['password']?.toString() ?? '';
          return {
            'id': d.id,
            'name': name,
            'mobile': mobile,
            'password': password,
          };
        }).toList();
      } else {
        // Fallback: read from generic users collection by role
        final snap = await FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: role)
            .get();

        items = snap.docs.map((d) {
          final data = d.data();
          final name = data['name']?.toString() ?? 'Unknown';
          return {
            'id': d.id,
            'name': name,
          };
        }).toList();
      }

      if (!mounted) return;
      if (items.isEmpty) {
        _showSnack('No $role users available for quick login');
        return;
      }

      final selected = await showModalBottomSheet<Map<String, String>>(
        context: context,
        backgroundColor: const Color(0xFF28343A),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (ctx) {
          final r = Responsive(ctx);
          return Padding(
            padding: EdgeInsets.all(r.wp(4)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select ${role[0].toUpperCase()}${role.substring(1)}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: r.sp(13),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: r.hp(1)),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const Divider(color: Colors.white24),
                    itemBuilder: (ctx, index) {
                      final itm = items[index];
                      return ListTile(
                        title: Text(
                          itm['name'] ?? '-',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: r.sp(12),
                          ),
                        ),
                        subtitle: isCustomer && (itm['mobile'] ?? '').isNotEmpty
                            ? Text(
                                itm['mobile']!,
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: r.sp(10),
                                ),
                              )
                            : null,
                        onTap: () => Navigator.of(ctx).pop(itm),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );

      if (!mounted || selected == null) return;

      if (isCustomer) {
        final mobile = selected['mobile'] ?? '';
        if (mobile.isNotEmpty) {
          final cp = Provider.of<CustomerProvider>(context, listen: false);
          cp.setCurrentCustomerMobile(mobile);
        }
        Navigator.of(context).pushReplacementNamed('/customerDashboard');
      } else if (isSupplier) {
        // Perform real Firebase Auth login for the selected supplier
        final mobile = selected['mobile'] ?? '';
        final password = selected['password'] ?? '';
        if (mobile.isEmpty || password.isEmpty) {
          _showSnack('Selected supplier has no credentials configured');
          return;
        }

        final auth = Provider.of<AuthProvider>(context, listen: false);
        final email = '$mobile@supplier.local';
        final roleFromAuth =
            await auth.signInWithEmail(email: email, password: password);
        if (!mounted) return;
        if (roleFromAuth != null) {
          Navigator.of(context).pushReplacementNamed('/roleRouter');
        } else {
          _showSnack(auth.error ?? 'Quick login failed');
        }
      } else {
        Navigator.of(context).pushReplacementNamed('/supplierDashboard');
      }
    } catch (e) {
      _showSnack('Failed to load $role list: $e');
    }
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
                hint: 'Email or Mobile',
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

              // Quick login section
              Text(
                'Quick Login',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: r.sp(11),
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: r.hp(1)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _quickLoginChip(
                    context: context,
                    r: r,
                    label: 'Company',
                    onTap: _quickLoginCompany,
                  ),
                  _quickLoginChip(
                    context: context,
                    r: r,
                    label: 'Supplier',
                    onTap: () => _showRolePicker('supplier'),
                  ),
                  _quickLoginChip(
                    context: context,
                    r: r,
                    label: 'Customer',
                    onTap: () => _showRolePicker('customer'),
                  ),
                ],
              ),

              //hiding register buttons and forgot password
              // TextButton(
              //   onPressed: () =>
              //       _showSnack('Forgot password flow - implement later'),
              //   child: Text(
              //     'Forgot password?',
              //     style: TextStyle(color: Colors.white70, fontSize: r.sp(11)),
              //   ),
              // ),
              // SizedBox(height: r.hp(3)),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     Text(
              //       "Don't have an account? ",
              //       style: TextStyle(color: Colors.white70, fontSize: r.sp(11)),
              //     ),
              //     GestureDetector(
              //       onTap: () =>
              //           Navigator.of(context).pushReplacementNamed('/register'),
              //       child: Text(
              //         'Register',
              //         style: TextStyle(
              //           color: Colors.greenAccent,
              //           fontSize: r.sp(11),
              //           fontWeight: FontWeight.bold,
              //         ),
              //       ),
              //     ),
              //   ],
              // ),
           
           
            ],
          ),
        ),
      ),
    );
  }
}

Widget _quickLoginChip({
  required BuildContext context,
  required Responsive r,
  required String label,
  required VoidCallback onTap,
}) {
  return InkWell(
    borderRadius: BorderRadius.circular(20),
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.symmetric(
        horizontal: r.wp(3),
        vertical: r.hp(0.8),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
        color: Colors.white.withOpacity(0.05),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontSize: r.sp(10),
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  );
}
