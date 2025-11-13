import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:inward_outward_management/providers/auth_provider.dart';
import 'package:inward_outward_management/providers/customer_provider.dart';
import 'package:provider/provider.dart';

class CustomerDashboardScreen extends StatefulWidget {
  const CustomerDashboardScreen({super.key});

  @override
  State<CustomerDashboardScreen> createState() =>
      _CustomerDashboardScreenState();
}

class _CustomerDashboardScreenState extends State<CustomerDashboardScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Fetch data when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CustomerProvider>(
        context,
        listen: false,
      ).fetchDashboardStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    // Use a property that exists on the User type (e.g. displayName or email).
    final userName =
        authProvider.currentUser?.displayName ??
        authProvider.currentUser?.email ??
        'Customer';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          "Dashboard",
          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black87),
        ),
        centerTitle: false,
        leading: IconButton(
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            if (context.mounted) {
              Navigator.of(context).pushReplacementNamed('/login');
            }
          },
          icon: Icon(Icons.logout, size: 18, color: Colors.black),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_outlined,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Consumer<CustomerProvider>(
          builder: (context, cp, _) {
            return RefreshIndicator(
              onRefresh: () => cp.fetchDashboardStats(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 600;
                    // card width for two-column look on larger screens
                    final cardWidth = isNarrow
                        ? double.infinity
                        : (constraints.maxWidth - 48) / 2;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top white container with user icon and metrics
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade300,
                                blurRadius: 6,
                                spreadRadius: 2,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 22,
                                    backgroundColor: Colors.orange.shade100,
                                    child: const Icon(
                                      Icons.person_outline,
                                      color: Colors.orange,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Hello, $userName',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 18,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const Spacer(),
                                  // small bell already in appBar, optional duplicate
                                  IconButton(
                                    onPressed: () {},
                                    icon: const Icon(
                                      Icons.notifications_none_rounded,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // metrics grid
                              Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: [
                                  SizedBox(
                                    width: cardWidth,
                                    child: _metricCard(
                                      titleTop: '${cp.invoicesDue}',
                                      subtitle: 'Invoices Due',
                                      icon: Icons.receipt_long_outlined,
                                      iconBg: Colors.blue.shade100,
                                      isLoading: cp.loading,
                                    ),
                                  ),
                                  SizedBox(
                                    width: cardWidth,
                                    child: _metricCard(
                                      titleTop:
                                          '₹${_formatAmount(cp.pendingPayments)}',
                                      subtitle: 'Pending Payments',
                                      icon:
                                          Icons.account_balance_wallet_outlined,
                                      iconBg: Colors.yellow.shade100,
                                      isLoading: cp.loading,
                                    ),
                                  ),
                                  SizedBox(
                                    width: cardWidth,
                                    child: _metricCard(
                                      titleTop:
                                          '${cp.billingHistoryCount > 0 ? "View" : 0}',
                                      subtitle: 'Billing History',
                                      icon: Icons.history_rounded,
                                      iconBg: Colors.pink.shade100,
                                      isLoading: cp.loading,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        const Text(
                          "Quick Access",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),

                        _quickAccessItem(
                          context,
                          icon: Icons.add_circle_outline,
                          title: 'Generate New Invoice',
                          onTap: () {
                            // navigate to invoice creation
                            // Navigator.push(context, MaterialPageRoute(builder: (_) => CreateInvoiceScreen()));
                          },
                        ),
                        _quickAccessItem(
                          context,
                          icon: Icons.history_toggle_off,
                          title: 'View Billing History',
                          onTap: () {
                            // navigate to billing history
                          },
                        ),
                        _quickAccessItem(
                          context,
                          icon: Icons.receipt_long_outlined,
                          title: 'View Invoices',
                          onTap: () {
                            // navigate to invoices list
                          },
                        ),

                        const SizedBox(height: 40),
                      ],
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() => _currentIndex = index);
          // implement navigation to other tabs (Products, History, Settings)
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_rounded),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_rounded),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _metricCard({
    required String titleTop,
    required String subtitle,
    required IconData icon,
    required Color iconBg,
    required bool isLoading,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: iconBg,
            radius: 20,
            child: Icon(icon, color: Colors.black87),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: isLoading
                ? const SizedBox(
                    height: 40,
                    child: Center(
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titleTop,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _quickAccessItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(icon),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  String _formatAmount(double value) {
    // simple formatting; adapt to locale/intl if needed
    if (value == 0) return '0';
    // show with comma separators and two decimals
    return value
        .toStringAsFixed(2)
        .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',');
  }
}
