import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomerProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _loading = false;
  bool get loading => _loading;

  int _invoicesDue = 0;
  int get invoicesDue => _invoicesDue;

  double _pendingPayments = 0.0;
  double get pendingPayments => _pendingPayments;

  int _billingHistoryCount = 0;
  int get billingHistoryCount => _billingHistoryCount;

  // Call this to refresh dashboard numbers
  Future<void> fetchDashboardStats() async {
    final user = _auth.currentUser;
    if (user == null) return;

    _loading = true;
    notifyListeners();

    try {
      // Query invoices for this customer
      final q = await _firestore
          .collection('customerInvoices')
          .where('customerId', isEqualTo: user.uid)
          .get();

      final docs = q.docs;

      int dueCount = 0;
      double pendingSum = 0.0;
      int historyCount = docs.length;

      for (final d in docs) {
        final data = d.data();
        final status = data['status']?.toString().toLowerCase() ?? '';
        final amount = (data['amount'] is num)
            ? (data['amount'] as num).toDouble()
            : double.tryParse('${data['amount']}') ?? 0.0;

        if (status == 'due' || status == 'unpaid' || status == 'pending') {
          dueCount += 1;
          pendingSum += amount;
        }
      }

      _invoicesDue = dueCount;
      _pendingPayments = pendingSum;
      _billingHistoryCount = historyCount;
    } catch (e) {
      // optionally log
      debugPrint('Error fetching customer stats: $e');
      _invoicesDue = 0;
      _pendingPayments = 0.0;
      _billingHistoryCount = 0;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
