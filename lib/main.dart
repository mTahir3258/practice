// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:inward_outward_management/providers/customer_provider.dart';
import 'package:inward_outward_management/screens/auth/splash_screen.dart';
import 'package:inward_outward_management/screens/company/company_dashboard.dart';
import 'package:inward_outward_management/screens/company/material_list_screen.dart';
import 'package:inward_outward_management/screens/customer/customer_dashboard.dart';
import 'package:inward_outward_management/screens/home/role_router_screen.dart';
import 'package:inward_outward_management/screens/supplier/supplier_dashboard.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart'; // if you use flutterfire configure
import 'providers/splash_provider.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SplashProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CustomerProvider()),
      ],
      child: Builder(
        builder: (context) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Inward-Outward Management',
            theme: ThemeData(primarySwatch: Colors.green),
            initialRoute: '/',
            routes: {
              '/': (_) => const SplashScreen(),
              '/login': (_) => const LoginScreen(),
              '/register': (_) => const RegisterScreen(),
              // '/home': (_) => const HomeScreen(),
              '/roleRouter': (_) => const RoleRouterScreen(),
              '/companyDashboard': (_) => const CompanyDashboardScreen(),
              '/supplierDashboard': (_) => const SupplierDashboardScreen(),
              '/customerDashboard': (_) => const CustomerDashboardScreen(),
              '/materials': (ctx) => MaterialsListScreen(),
            },
          );
        },
      ),
    );
  }
}
