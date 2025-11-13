// lib/screens/home/company_dashboard.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:inward_outward_management/services/company_services.dart';
import 'package:inward_outward_management/utils/responsive.dart';

class CompanyDashboardScreen extends StatefulWidget {
  const CompanyDashboardScreen({super.key});

  @override
  State<CompanyDashboardScreen> createState() => _CompanyDashboardScreenState();
}

class _CompanyDashboardScreenState extends State<CompanyDashboardScreen> {
  final _service = CompanyService();
  bool _loading = true;
  Map<String, dynamic>? _summary;

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  Future<void> _loadSummary() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final companyId = user.uid;

    final summary = await _service.getDashboardSummary(companyId);
    if (!mounted) return;
    setState(() {
      _summary = summary;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.green)),
      );
    }

    final s = _summary!;
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Company Dashboard',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(r.wp(4)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              crossAxisSpacing: r.wp(3),
              mainAxisSpacing: r.hp(2),
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _DashboardCard(
                  label: 'Pending Inward',
                  value: '${s['pendingInward']}',
                  icon: Icons.inventory_2_outlined,
                  color: Colors.green,
                ),
                _DashboardCard(
                  label: 'Pending Outward',
                  value: '${s['pendingOutward']}',
                  icon: Icons.outbox_outlined,
                  color: Colors.blue,
                ),
                _DashboardCard(
                  label: 'Supplier Requests',
                  value: '${s['supplierRequests']}',
                  icon: Icons.people_outline,
                  color: Colors.purple,
                ),
                _DashboardCard(
                  label: 'Open Challans',
                  value: '${s['openChallans']}',
                  icon: Icons.list_alt_outlined,
                  color: Colors.orange,
                ),
                _DashboardCard(
                  label: 'Pending Bills',
                  value: '${s['pendingBills']}',
                  icon: Icons.receipt_long_outlined,
                  color: Colors.redAccent,
                ),
                _DashboardCard(
                  label: 'Advance Receipts',
                  value: '₹${s['advanceReceipts'].toStringAsFixed(0)}',
                  icon: Icons.account_balance_wallet_outlined,
                  color: Colors.amber,
                ),
              ],
            ),

            SizedBox(height: r.hp(3)),
            const Text(
              'Quick Access',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: r.hp(1.5)),

            _QuickActionTile(
              icon: Icons.storage_outlined,
              label: 'Master Data',
              onTap: () {},
            ),
            _QuickActionTile(
              icon: Icons.history_outlined,
              label: 'View History',
              onTap: () {},
            ),
            _QuickActionTile(
              icon: Icons.insert_chart_outlined,
              label: 'Reports',
              onTap: () {},
            ),

            SizedBox(height: r.hp(10)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () {
          // Navigate to new material/challan creation
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping_outlined),
            label: 'Suppliers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            label: 'Customers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Small widgets
// ---------------------------------------------------------------------------

class _DashboardCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _DashboardCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
