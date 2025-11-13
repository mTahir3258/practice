// lib/providers/company_provider.dart
import 'package:flutter/material.dart';
import 'package:inward_outward_management/core/models/material_model.dart';
import 'package:inward_outward_management/services/company_services.dart';

class CompanyProvider with ChangeNotifier {
  final CompanyService _service = CompanyService();
  final String companyId; // pass from logged-in user's company context

  CompanyProvider({required this.companyId}) {
    // Load materials and dashboard metrics on init
    loadMaterials();
  }

  // Materials
  List<MaterialModel> _materials = [];
  List<MaterialModel> get materials => _materials;
  bool loading = false;

  Future<void> loadMaterials() async {
    loading = true;
    notifyListeners();
    try {
      _materials = await _service.getMaterials(companyId);
    } catch (e) {
      debugPrint('loadMaterials error: $e');
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> addMaterial(MaterialModel m) async {
    final id = await _service.createMaterial(companyId, m);
    m.id = id;
    _materials.add(m);
    notifyListeners();
  }

  Future<void> updateMaterial(MaterialModel m) async {
    await _service.updateMaterial(companyId, m);
    final idx = _materials.indexWhere((e) => e.id == m.id);
    if (idx >= 0) {
      _materials[idx] = m;
      notifyListeners();
    }
  }

  Future<void> deleteMaterial(String materialId) async {
    await _service.deleteMaterial(companyId, materialId);
    _materials.removeWhere((e) => e.id == materialId);
    notifyListeners();
  }

  // // Create a challan and optionally generate bill
  // Future<String> createChallan(
  //   String supplierId,
  //   Map<String, dynamic> items, {
  //   bool generateBill = false,
  // }) async {
  //   final challanId = await _service.createChallanFromItems(
  //     companyId,
  //     supplierId,
  //     items,
  //   );
  //   if (generateBill) {
  //     await _service.generateBillFromChallan(companyId, challanId);
  //   }
  //   // Refresh dashboard after creating challan
  //   await loadDashboard();
  //   return challanId;
  // }

  // -----------------------
  // Dashboard state & loaders
  // -----------------------
  int pendingInward = 0;
  int pendingOutward = 0;
  int supplierRequests = 0;
  int openChallans = 0;
  int pendingBills = 0;
  double advanceReceiptsTotal = 0.0;
  bool dashboardLoading = false;

  /// Loads counts/totals used on the dashboard. This composes multiple service reads.
  // Future<void> loadDashboard() async {
  //   dashboardLoading = true;
  //   notifyListeners();
  //   try {
  //     // Get challans, requests, bills and advance receipts
  //     final challans = await _service.getChallans(companyId);
  //     final requests = await _service.getMaterialRequests(companyId);
  //     final bills = await _service.getSupplierBills(companyId);
  //     final advanceTotal = await _service.getAdvanceReceiptsTotal(companyId);
  //     // Simple heuristics for counts - adjust according to your real data schema
  //     // pendingInward: number of challans with status 'pending' or 'delivered' (example)
  //     pendingInward = challans
  //         .where((c) => (c['status'] ?? '') == 'pending')
  //         .length;
  //     // pendingOutward: you may have a separate flag; we approximate to challans with 'outward' field
  //     pendingOutward = challans
  //         .where((c) => (c['direction'] ?? '') == 'outward')
  //         .length;
  //     // supplier requests: number of requests with status 'requested'
  //     supplierRequests = requests
  //         .where((r) => (r['status'] ?? '') == 'requested')
  //         .length;
  //     // open challans: challans where status != 'billed' (still open)
  //     openChallans = challans
  //         .where((c) => (c['status'] ?? '') != 'billed')
  //         .length;
  //     // pending bills: bills where status is 'unpaid' or 'partially_paid'
  //     pendingBills = bills.where((b) => (b['status'] ?? '') != 'paid').length;
  //     advanceReceiptsTotal = advanceTotal;
  //     // notify listeners at the end
  //   } catch (e) {
  //     debugPrint('loadDashboard error: $e');
  //   } finally {
  //     dashboardLoading = false;
  //     notifyListeners();
  //   }
  // }
}
