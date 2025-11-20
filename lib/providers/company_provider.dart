// CompanyProvider: exposes state for company screens and calls CompanyService.
// Use this provider in screens to load lists and trigger actions.

import 'package:flutter/material.dart';
import 'package:inward_outward_management/core/models/material_model.dart';
import 'package:inward_outward_management/core/models/unit_model.dart';
import 'package:inward_outward_management/core/models/supplier_model.dart';
import 'package:inward_outward_management/core/models/customer_model.dart';
import 'package:inward_outward_management/repository/company_repository.dart';
import 'package:inward_outward_management/services/company_services.dart';

class CompanyProvider with ChangeNotifier {
  final CompanyService _service = CompanyService();

  final CompanyRepository _repository = CompanyRepository();

  List<MaterialModel> materials = [];
  List<UnitModel> units = [];
  List<SupplierModel> suppliers = [];
  List<CustomerModel> customers = [];
  bool isLoading = false;

  String companyId;
  CompanyProvider({required this.companyId}) {
    if (companyId.isNotEmpty) _initLoad();
  }

  void _initLoad() {
    loadMaterials();
    loadUnits();
    loadSuppliers();
    loadCustomers();
    loadDashboardSummary();
    loadMaterialRequests();
    loadChallans();
    loadSupplierBills();
    loadPendingInward();
    loadPendingOutward();
    loadStandaloneIntimations();
  }

  // -------------- Materials --------------
  List<MaterialModel> _materials = [];

  // List<MaterialModel> get materials => _materials;
  // bool loadingMaterials = false;

  // ---------------------------------------------------------------------------
  // LOAD MATERIALS
  // ---------------------------------------------------------------------------
  Future<void> loadMaterials() async {
    isLoading = true;
    notifyListeners();

    materials = await _repository.fetchMaterials();

    isLoading = false;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // ADD MATERIAL
  // ---------------------------------------------------------------------------
  Future<void> addMaterial(MaterialModel material) async {
    await _repository.addMaterial(material);
    await loadMaterials(); // refresh list
  }

  // ---------------------------------------------------------------------------
  // UPDATE MATERIAL
  // ---------------------------------------------------------------------------
  Future<void> updateMaterial(String id, MaterialModel material) async {
    await _repository.updateMaterial(id, material);
    await loadMaterials();
  }

  // ---------------------------------------------------------------------------
  // DELETE MATERIAL
  // ---------------------------------------------------------------------------
  Future<void> deleteMaterial(String id) async {
    await _repository.deleteMaterial(id);
    await loadMaterials();
  }

  // -------------- Units --------------

  Future<void> loadUnits() async {
    isLoading = true;
    notifyListeners();

    units = await _repository.fetchUnits();

    isLoading = false;
    notifyListeners();
  }

  Future<void> addUnit(UnitModel unit) async {
    await _repository.addUnit(unit);
    await loadUnits();
  }

  Future<void> updateUnit(String id, UnitModel unit) async {
    await _repository.updateUnit(id, unit);
    await loadUnits();
  }

  Future<void> deleteUnit(String id) async {
    await _repository.deleteUnit(id);
    await loadUnits();
  }

  // -------------- Suppliers --------------

  Future<void> loadSuppliers() async {
    isLoading = true;
    notifyListeners();

    suppliers = await _repository.fetchSuppliers();

    isLoading = false;
    notifyListeners();
  }

  Future<void> addSupplier(SupplierModel supplier) async {
    await _repository.addSupplier(supplier);
    await loadSuppliers();
  }

  Future<void> updateSupplier(String id, SupplierModel supplier) async {
    await _repository.updateSupplier(id, supplier);
    await loadSuppliers();
  }

  Future<void> deleteSupplier(String id) async {
    await _repository.deleteSupplier(id);
    await loadSuppliers();
  }

  // -------------- Customers --------------

  Future<void> loadCustomers() async {
    isLoading = true;
    notifyListeners();

    customers = await _repository.fetchCustomers();

    isLoading = false;
    notifyListeners();
  }

  Future<void> addCustomer(CustomerModel customer) async {
    await _repository.addCustomer(customer);
    await loadCustomers();
  }

  Future<void> updateCustomer(String id, CustomerModel customer) async {
    await _repository.updateCustomer(id, customer);
    await loadCustomers();
  }

  Future<void> deleteCustomer(String id) async {
    await _repository.deleteCustomer(id);
    await loadCustomers();
  }

  // Future<void> loadMaterials() async {
  //   if (companyId.isEmpty) return;
  //   loadingMaterials = true;
  //   notifyListeners();
  //   try {
  //     _materials = await _service.getMaterials(companyId);
  //   } catch (e) {
  //     debugPrint('loadMaterials error: $e');
  //     _materials = [];
  //   } finally {
  //     loadingMaterials = false;
  //     notifyListeners();
  //   }
  // }

  // Future<void> addMaterial(MaterialModel m) async {
  //   if (companyId.isEmpty) throw Exception('Company ID not set');
  //   final id = await _service.createMaterial(companyId, m);
  //   m.id = id;
  //   _materials.add(m);
  //   notifyListeners();
  // }

  // Future<void> updateMaterial(MaterialModel m) async {
  //   if (companyId.isEmpty) throw Exception('Company ID not set');
  //   await _service.updateMaterial(companyId, m);
  //   final idx = _materials.indexWhere((e) => e.id == m.id);
  //   if (idx >= 0) {
  //     _materials[idx] = m;
  //     notifyListeners();
  //   }
  // }

  // Future<void> deleteMaterial(String materialId) async {
  //   if (companyId.isEmpty) throw Exception('Company ID not set');
  //   await _service.deleteMaterial(companyId, materialId);
  //   _materials.removeWhere((m) => m.id == materialId);
  //   notifyListeners();
  // }

  // -------------- Material Requests --------------
  bool loadingRequests = false;
  List<Map<String, dynamic>> _requests = [];
  List<Map<String, dynamic>> get requests => _requests;

  Future<void> loadMaterialRequests() async {
    loadingRequests = true;
    notifyListeners();
    try {
      _requests = await _service.getMaterialRequests(companyId);
    } catch (e) {
      debugPrint('loadMaterialRequests error: $e');
      _requests = [];
    } finally {
      loadingRequests = false;
      notifyListeners();
    }
  }

  Future<String> createMaterialRequest(Map<String, dynamic> requestMap) async {
    if (companyId.isEmpty) throw Exception('Company ID not set');
    final id = await _service.createMaterialRequest(companyId, requestMap);
    await loadMaterialRequests();
    return id;
  }

  Future<void> deleteMaterialRequest(String requestId) async {
    await _service.deleteMaterialRequest(requestId);
    await loadMaterialRequests();
    await loadDashboardSummary();
  }

  Future<List<Map<String, dynamic>>> loadSupplierIntimations(
    String requestId,
  ) async {
    return await _service.getSupplierIntimations(requestId);
  }

  Future<void> addSupplierIntimation(
    String requestId,
    Map<String, dynamic> intimation,
  ) async {
    await _service.addSupplierIntimation(requestId, intimation);
  }

  Future<void> deleteSupplierIntimation(
    String requestId,
    String intimationId,
  ) async {
    await _service.deleteSupplierIntimation(requestId, intimationId);
  }

  Future<String> confirmIntimationAndCreateChallan(
    String requestId,
    Map<String, dynamic> intimation,
  ) async {
    if (companyId.isEmpty) throw Exception('Company ID not set');
    final supplierId = intimation['supplierId']?.toString() ?? '';
    final challanId = await _service.createChallanFromIntimation(
      companyId,
      supplierId,
      intimation,
    );

    // Update request status to confirmed (best-effort)
    try {
      await _service.supplierRequests().doc(requestId).update({
        'status': 'confirmed',
        'confirmedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      debugPrint('Could not update request status: $e');
    }

    // reload lists
    await loadChallans();
    await loadMaterialRequests();
    return challanId;
  }

  // -------------- Standalone supplier intimations --------------
  bool loadingStandaloneIntimations = false;
  List<Map<String, dynamic>> _standaloneIntimations = [];
  List<Map<String, dynamic>> get standaloneIntimations => _standaloneIntimations;

  Future<void> loadStandaloneIntimations() async {
    if (companyId.isEmpty) return;
    loadingStandaloneIntimations = true;
    notifyListeners();
    try {
      _standaloneIntimations =
          await _service.getStandaloneIntimations(companyId);
    } catch (e) {
      debugPrint('loadStandaloneIntimations error: $e');
      _standaloneIntimations = [];
    } finally {
      loadingStandaloneIntimations = false;
      notifyListeners();
    }
  }

  Future<void> addStandaloneIntimation(Map<String, dynamic> intimation) async {
    if (companyId.isEmpty) throw Exception('Company ID not set');
    await _service.addStandaloneIntimation(companyId, intimation);
    await loadStandaloneIntimations();
  }

  Future<void> deleteStandaloneIntimation(String intimationId) async {
    if (companyId.isEmpty) throw Exception('Company ID not set');
    await _service.deleteStandaloneIntimation(companyId, intimationId);
    await loadStandaloneIntimations();
  }

  Future<String> confirmStandaloneIntimationAndCreateChallan(
    Map<String, dynamic> intimation,
  ) async {
    if (companyId.isEmpty) throw Exception('Company ID not set');
    final supplierId = intimation['supplierId']?.toString() ?? '';
    final challanId = await _service.createChallanFromIntimation(
      companyId,
      supplierId,
      intimation,
    );

    // Best-effort: mark standalone intimation as confirmed
    try {
      final id = intimation['id']?.toString() ?? '';
      if (id.isNotEmpty) {
        await _service.updateStandaloneIntimationStatus(
          companyId,
          id,
          'confirmed',
        );
      }
    } catch (e) {
      debugPrint('Could not update standalone intimation status: $e');
    }

    await loadChallans();
    await loadStandaloneIntimations();
    return challanId;
  }

  /// Update only the status of a standalone intimation document.
  Future<void> updateStandaloneIntimationStatusOnly({
    required String intimationId,
    required String status,
  }) async {
    if (companyId.isEmpty) throw Exception('Company ID not set');
    await _service.updateStandaloneIntimationStatus(
      companyId,
      intimationId,
      status,
    );
    await loadStandaloneIntimations();
  }

  // -------------- Challans --------------
  bool loadingChallans = false;
  List<Map<String, dynamic>> _challans = [];
  List<Map<String, dynamic>> get challans => _challans;

  Future<void> loadChallans() async {
    if (companyId.isEmpty) return;
    loadingChallans = true;
    notifyListeners();
    try {
      _challans = await _service.getChallans(companyId);
    } catch (e) {
      debugPrint('loadChallans error: $e');
      _challans = [];
    } finally {
      loadingChallans = false;
      notifyListeners();
    }
  }

  Future<void> updateChallanStatus(String challanId, String status) async {
    if (companyId.isEmpty) throw Exception('Company ID not set');
    await _service.updateChallanStatus(companyId, challanId, status);
    await loadChallans();
    notifyListeners();
  }

  Future<void> deleteChallan(String challanId) async {
    if (companyId.isEmpty) throw Exception('Company ID not set');
    await _service.deleteChallan(companyId, challanId);
    await loadChallans();
    await loadDashboardSummary();
  }

  // -------------- Supplier bills --------------
  bool loadingBills = false;
  List<Map<String, dynamic>> _bills = [];
  List<Map<String, dynamic>> get bills => _bills;

  Future<void> loadSupplierBills() async {
    if (companyId.isEmpty) return;
    loadingBills = true;
    notifyListeners();
    try {
      _bills = await _service.getSupplierBills(companyId);
    } catch (e) {
      debugPrint('loadSupplierBills error: $e');
      _bills = [];
    } finally {
      loadingBills = false;
      notifyListeners();
    }
  }

  Future<String> generateBillFromChallan(String challanId) async {
    if (companyId.isEmpty) throw Exception('Company ID not set');
    final id = await _service.createSupplierBillFromChallan(
      companyId,
      challanId,
    );
    await loadSupplierBills();
    await loadChallans();
    return id;
  }

  Future<void> deleteBill(String billId) async {
    if (companyId.isEmpty) throw Exception('Company ID not set');
    await _service.deleteSupplierBill(companyId, billId);
    await loadSupplierBills();
    await loadDashboardSummary();
  }

  // -------------- Advance receipts --------------
  bool loadingAdvanceReceipts = false;
  List<Map<String, dynamic>> _advanceReceipts = [];
  List<Map<String, dynamic>> get advanceReceipts => _advanceReceipts;

  Future<void> loadAdvanceReceipts() async {
    if (companyId.isEmpty) return;
    loadingAdvanceReceipts = true;
    notifyListeners();
    try {
      _advanceReceipts = await _service.getAdvanceReceipts(companyId);
    } catch (e) {
      debugPrint('loadAdvanceReceipts error: $e');
      _advanceReceipts = [];
    } finally {
      loadingAdvanceReceipts = false;
      notifyListeners();
    }
  }

  Future<String> createAdvanceReceipt(Map<String, dynamic> data) async {
    if (companyId.isEmpty) throw Exception('Company ID not set');
    final id = await _service.createAdvanceReceipt(companyId, data);
    await loadAdvanceReceipts();
    await loadDashboardSummary();
    return id;
  }

  // -------------- Pending inward / outward --------------
  bool loadingPendingInward = false;
  bool loadingPendingOutward = false;

  List<Map<String, dynamic>> _pendingInward = [];
  List<Map<String, dynamic>> get pendingInwardList => _pendingInward;

  List<Map<String, dynamic>> _pendingOutward = [];
  List<Map<String, dynamic>> get pendingOutwardList => _pendingOutward;

  Future<void> loadPendingInward() async {
    if (companyId.isEmpty) return;
    loadingPendingInward = true;
    notifyListeners();
    try {
      _pendingInward = await _service.getPendingInwardRequests(companyId);
    } catch (e) {
      debugPrint('loadPendingInward error: $e');
      _pendingInward = [];
    } finally {
      loadingPendingInward = false;
      notifyListeners();
    }
  }

  // Inward history (all statuses)
  bool loadingInwardHistory = false;
  List<Map<String, dynamic>> _inwardHistory = [];
  List<Map<String, dynamic>> get inwardHistory => _inwardHistory;

  Future<void> loadInwardHistory() async {
    if (companyId.isEmpty) return;
    loadingInwardHistory = true;
    notifyListeners();
    try {
      _inwardHistory = await _service.getInwardHistory(companyId);
    } catch (e) {
      debugPrint('loadInwardHistory error: $e');
      _inwardHistory = [];
    } finally {
      loadingInwardHistory = false;
      notifyListeners();
    }
  }

  Future<void> updateInwardStatus(String inwardId, String status) async {
    await _service.updateInwardStatus(inwardId, status);
    await loadPendingInward();
  }

  Future<void> loadPendingOutward() async {
    if (companyId.isEmpty) return;
    loadingPendingOutward = true;
    notifyListeners();
    try {
      _pendingOutward = await _service.getPendingOutwardRequests(companyId);
    } catch (e) {
      debugPrint('loadPendingOutward error: $e');
      _pendingOutward = [];
    } finally {
      loadingPendingOutward = false;
      notifyListeners();
    }
  }

  // -------------- Dashboard summary --------------
  bool dashboardLoading = false;
  int pendingInward = 0;
  int pendingOutward = 0;
  int supplierRequests = 0;
  int openChallans = 0;
  int pendingBills = 0;
  double advanceReceiptsTotal = 0.0;

  Future<void> loadDashboardSummary() async {
    if (companyId.isEmpty) return;
    dashboardLoading = true;
    notifyListeners();
    try {
      final summary = await _service.getDashboardSummary(companyId);
      pendingInward = (summary['pendingInward'] ?? 0) is int
          ? summary['pendingInward']
          : (summary['pendingInward'] ?? 0).toInt();
      pendingOutward = (summary['pendingOutward'] ?? 0) is int
          ? summary['pendingOutward']
          : (summary['pendingOutward'] ?? 0).toInt();
      supplierRequests = (summary['supplierRequests'] ?? 0) is int
          ? summary['supplierRequests']
          : (summary['supplierRequests'] ?? 0).toInt();
      openChallans = (summary['openChallans'] ?? 0) is int
          ? summary['openChallans']
          : (summary['openChallans'] ?? 0).toInt();
      pendingBills = (summary['pendingBills'] ?? 0) is int
          ? summary['pendingBills']
          : (summary['pendingBills'] ?? 0).toInt();
      final adv = summary['advanceReceipts'] ?? 0.0;
      advanceReceiptsTotal = (adv is num)
          ? adv.toDouble()
          : double.tryParse('$adv') ?? 0.0;
    } catch (e) {
      debugPrint('loadDashboardSummary error: $e');
    } finally {
      dashboardLoading = false;
      notifyListeners();
    }
  }

  // -------------- Utilities --------------
  void updateCompanyId(String id) {
    final newId = id.trim();
    if (newId.isEmpty) return;
    if (companyId == newId) return;
    companyId = newId;
    _initLoad();
    notifyListeners();
  }
}
