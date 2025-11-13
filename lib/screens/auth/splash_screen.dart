// lib/screens/splash/splash_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:inward_outward_management/providers/splash_provider.dart';
import 'package:inward_outward_management/utils/responsive.dart';
import 'package:inward_outward_management/widgets/app_logo.dart';
import 'package:inward_outward_management/widgets/rounded_progressbar.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _navTimer;

  @override
  void initState() {
    super.initState();
    // ensure provider is available after build
    Future.microtask(() {
      final splashProvider = Provider.of<SplashProvider>(
        context,
        listen: false,
      );
      splashProvider.start();
      _navTimer = Timer.periodic(const Duration(milliseconds: 1000), (t) {
        if (splashProvider.completed) {
          t.cancel();
          _navigateAway();
        }
      });
    });
  }

  void _navigateAway() async {
    final user = FirebaseAuth.instance.currentUser;
    if (!mounted) return;
    if (user == null) {
      Navigator.of(context).pushReplacementNamed('/login');
      return;
    }

    // If user exists, let RoleRouter determine the dashboard.
    Navigator.of(context).pushReplacementNamed('/roleRouter');
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);
    return Scaffold(
      backgroundColor: const Color(0xFF28343A),

      body: SafeArea(
        child: Consumer<SplashProvider>(
          builder: (context, provider, _) {
            return Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppLogo(
                        assetPath: 'assets/images/logo.png',
                        diameterPercent: 26,
                      ),
                      SizedBox(height: r.hp(4)),
                      Text(
                        'Inward-Outward\nManagement',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: r.sp(18),
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: r.hp(1.2)),
                      Text(
                        'Streamlining Your Business Flow',
                        style: TextStyle(
                          fontSize: r.sp(11),
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: r.hp(4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RoundedProgressBar(
                        progress: provider.progress,
                        margin: EdgeInsets.symmetric(horizontal: r.wp(6)),
                        height: r.hp(1.1),
                      ),
                      SizedBox(height: r.hp(1.2)),
                      Opacity(
                        opacity: 0.8,
                        child: Text(
                          'v1.0',
                          style: TextStyle(fontSize: r.sp(10)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
