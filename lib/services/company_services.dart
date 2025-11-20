// CompanyService: handles all Firestore reads/writes and pure calculations
// Keep this file focused on data operations only.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inward_outward_management/core/models/material_model.dart';

class CompanyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Root paths
  CollectionReference<Map<String, dynamic>> companies() =>
      _firestore.collection('companies');

  CollectionReference<Map<String, dynamic>> materials(String companyId) =>
      companies().doc(companyId).collection('materials');

  CollectionReference<Map<String, dynamic>> challans(String companyId) =>
      companies().doc(companyId).collection('challans');

  CollectionReference<Map<String, dynamic>> bills(String companyId) =>
      companies().doc(companyId).collection('bills');

  CollectionReference<Map<String, dynamic>> receipts(String companyId) =>
      companies().doc(companyId).collection('advance_receipts');

  // Standalone intimations (submitted without a prior material request)
  CollectionReference<Map<String, dynamic>> standaloneIntimations(
    String companyId,
  ) =>
      companies().doc(companyId).collection('standalone_intimations');

  // Global collections for workflow
  CollectionReference<Map<String, dynamic>> supplierRequests() =>
      _firestore.collection('supplier_requests');

  CollectionReference<Map<String, dynamic>> inwardRequests() =>
      _firestore.collection('inward_requests');

  CollectionReference<Map<String, dynamic>> outwardRequests() =>
      _firestore.collection('outward_requests');

  // ---------------- Material CRUD ----------------
  Future<String> createMaterial(String companyId, MaterialModel m) async {
    final ref = await materials(companyId).add(m.toMap());
    return ref.id;
  }

  Future<void> updateMaterial(String companyId, MaterialModel m) async {
    await materials(companyId).doc(m.id).update(m.toMap());
  }

  Future<void> deleteMaterial(String companyId, String materialId) async {
    await materials(companyId).doc(materialId).delete();
  }

  // Future<List<MaterialModel>> getMaterials(String companyId) async {
  //   final snap = await materials(companyId).get();
  //   return snap.docs.map((d) => MaterialModel.fromMap(d.id, d.data())).toList();
  // }

  // ---------------- Material Requests ----------------
  /// Company raises a new material request (stored under global `supplier_requests`)
  Future<String> createMaterialRequest(
    String companyId,
    Map<String, dynamic> requestMap,
  ) async {
    // Best-effort: fetch company name from users collection
    String companyName = '';
    try {
      final userDoc =
          await _firestore.collection('users').doc(companyId).get();
      if (userDoc.exists) {
        final data = userDoc.data();
        if (data != null) {
          companyName = data['name']?.toString() ?? '';
        }
      }
    } catch (_) {
      // ignore, fallback to empty name
    }

    final doc = {
      ...requestMap,
      'companyId': companyId,
      'companyName': companyName,
      'status': 'requested',
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    };
    final ref = await supplierRequests().add(doc);
    return ref.id;
  }

  Future<List<Map<String, dynamic>>> getMaterialRequests(
    String companyId,
  ) async {
    Query<Map<String, dynamic>> query = supplierRequests();
    // If companyId is known, filter by it. If it's empty (older data / setup),
    // fall back to loading all requests so that the UI still shows something.
    if (companyId.isNotEmpty) {
      query = query.where('companyId', isEqualTo: companyId);
    }

    // Removed orderBy('createdAt') to avoid requiring a composite index.
    // Firestore will still return documents (unordered) which is fine for UI.
    final q = await query.get();
    return q.docs.map((d) {
      final map = Map<String, dynamic>.from(d.data());
      map['id'] = d.id;
      return map;
    }).toList();
  }

  Future<void> deleteMaterialRequest(String requestId) async {
    await supplierRequests().doc(requestId).delete();
  }

  Future<void> addSupplierIntimation(
    String requestId,
    Map<String, dynamic> intimation,
  ) async {
    final sub = supplierRequests()
        .doc(requestId)
        .collection('supplier_intimations');

    // Best-effort: ensure supplierName is present on the intimation by
    // looking it up from the users collection using supplierId (uid).
    String supplierName = (intimation['supplierName'] ?? '').toString();
    final supplierId = (intimation['supplierId'] ?? '').toString();
    if (supplierName.isEmpty && supplierId.isNotEmpty) {
      try {
        final userDoc =
            await _firestore.collection('users').doc(supplierId).get();
        if (userDoc.exists) {
          final data = userDoc.data();
          if (data != null) {
            supplierName = data['name']?.toString() ?? '';
          }
        }
      } catch (_) {
        // ignore, keep empty name if lookup fails
      }
    }

    await sub.add({
      ...intimation,
      if (supplierName.isNotEmpty) 'supplierName': supplierName,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
      'status': 'intimated',
    });

    // Also mark the main supplier request as intimated so that dashboard and
    // other company-side UIs can easily filter for requests with dispatch
    // intimations.
    try {
      await supplierRequests().doc(requestId).update({
        'status': 'intimated',
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      // best-effort; if this fails, the intimation document still exists
    }
  }

  Future<List<Map<String, dynamic>>> getSupplierIntimations(
    String requestId,
  ) async {
    final snap = await supplierRequests()
        .doc(requestId)
        .collection('supplier_intimations')
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map((d) {
      final m = Map<String, dynamic>.from(d.data());
      m['id'] = d.id;
      return m;
    }).toList();
  }

  Future<void> deleteSupplierIntimation(
    String requestId,
    String intimationId,
  ) async {
    await supplierRequests()
        .doc(requestId)
        .collection('supplier_intimations')
        .doc(intimationId)
        .delete();
  }

  // ---------------- Standalone supplier intimations ----------------
  Future<void> addStandaloneIntimation(
    String companyId,
    Map<String, dynamic> intimation,
  ) async {
    // Best-effort: ensure supplierName is present on the intimation by
    // looking it up from the users collection using supplierId (uid).
    String supplierName = (intimation['supplierName'] ?? '').toString();
    final supplierId = (intimation['supplierId'] ?? '').toString();
    if (supplierName.isEmpty && supplierId.isNotEmpty) {
      try {
        final userDoc =
            await _firestore.collection('users').doc(supplierId).get();
        if (userDoc.exists) {
          final data = userDoc.data();
          if (data != null) {
            supplierName = data['name']?.toString() ?? '';
          }
        }
      } catch (_) {
        // ignore
      }
    }

    await standaloneIntimations(companyId).add({
      ...intimation,
      if (supplierName.isNotEmpty) 'supplierName': supplierName,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
      'status': 'intimated',
    });
  }

  Future<List<Map<String, dynamic>>> getStandaloneIntimations(
    String companyId,
  ) async {
    final snap = await standaloneIntimations(companyId)
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map((d) {
      final m = Map<String, dynamic>.from(d.data());
      m['id'] = d.id;
      return m;
    }).toList();
  }

  Future<void> deleteStandaloneIntimation(
    String companyId,
    String intimationId,
  ) async {
    await standaloneIntimations(companyId).doc(intimationId).delete();
  }

  Future<void> updateStandaloneIntimationStatus(
    String companyId,
    String intimationId,
    String status,
  ) async {
    await standaloneIntimations(companyId).doc(intimationId).update({
      'status': status,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> deleteChallan(String companyId, String challanId) async {
    await challans(companyId).doc(challanId).delete();
  }

  Future<List<Map<String, dynamic>>> getInwardHistory(String companyId) async {
    // Removed orderBy to avoid composite index requirement.
    final snap = await inwardRequests()
        .where('companyId', isEqualTo: companyId)
        .get();
    return snap.docs.map((d) {
      final m = Map<String, dynamic>.from(d.data());
      m['id'] = d.id;
      return m;
    }).toList();
  }

  Future<void> updateInwardStatus(String inwardId, String status) async {
    await inwardRequests().doc(inwardId).update({
      'status': status,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  // ---------------- Advance receipts (company -> supplier) ----------------
  Future<String> createAdvanceReceipt(
    String companyId,
    Map<String, dynamic> data,
  ) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final doc = {
      ...data,
      'createdAt': now,
      // Allow caller to pass a custom date; fallback to now
      'date': data['date'] ?? now,
    };

    final ref = await receipts(companyId).add(doc);
    return ref.id;
  }

  Future<List<Map<String, dynamic>>> getAdvanceReceipts(
    String companyId,
  ) async {
    final snap = await receipts(
      companyId,
    ).orderBy('date', descending: true).get();
    return snap.docs.map((d) {
      final m = Map<String, dynamic>.from(d.data());
      m['id'] = d.id;
      return m;
    }).toList();
  }

  // ---------------- Inward / Outward request lists ----------------
  Future<List<Map<String, dynamic>>> getPendingInwardRequests(
    String companyId,
  ) async {
    // Removed orderBy('createdAt') to avoid composite index requirement.
    final snap = await inwardRequests()
        .where('companyId', isEqualTo: companyId)
        .where('status', isEqualTo: 'pending')
        .get();
    return snap.docs.map((d) {
      final m = Map<String, dynamic>.from(d.data());
      m['id'] = d.id;
      return m;
    }).toList();
  }

  Future<List<Map<String, dynamic>>> getPendingOutwardRequests(
    String companyId,
  ) async {
    // Removed orderBy('createdAt') to avoid composite index requirement.
    final snap = await outwardRequests()
        .where('companyId', isEqualTo: companyId)
        .where('status', isEqualTo: 'pending')
        .get();
    return snap.docs.map((d) {
      final m = Map<String, dynamic>.from(d.data());
      m['id'] = d.id;
      return m;
    }).toList();
  }

  // ---------------- Challan creation (company confirms intimation) ----------------
  /// Accepts an intimation map that contains items: materialId -> { qty, rate, materialKg, plasticKg }
  /// Computes totals and creates a challan under companies/{companyId}/challans
  Future<String> createChallanFromIntimation(
    String companyId,
    String supplierId,
    Map<String, dynamic> intimation,
  ) async {
    // Best-effort: fetch supplier name from users collection so that
    // challan lists can show a readable supplier name instead of only ID.
    String supplierName = '';
    if (supplierId.isNotEmpty) {
      try {
        final userDoc =
            await _firestore.collection('users').doc(supplierId).get();
        if (userDoc.exists) {
          final data = userDoc.data();
          if (data != null) {
            supplierName = data['name']?.toString() ?? '';
          }
        }
      } catch (_) {
        // ignore, fallback to empty name
      }
    }

    final items = Map<String, dynamic>.from(intimation['items'] ?? {});
    double totalAmount = 0.0;
    double totalMaterialKg = 0.0;
    double totalPlasticKg = 0.0;

    items.forEach((materialId, entryRaw) {
      final entry = Map<String, dynamic>.from(entryRaw ?? {});
      final qty = (entry['qty'] is num)
          ? (entry['qty'] as num).toDouble()
          : double.tryParse('${entry['qty']}') ?? 0.0;
      final rate = (entry['rate'] is num)
          ? (entry['rate'] as num).toDouble()
          : double.tryParse('${entry['rate']}') ?? 0.0;
      final materialKg = (entry['materialKg'] is num)
          ? (entry['materialKg'] as num).toDouble()
          : double.tryParse('${entry['materialKg']}') ?? 0.0;
      final plasticKg = (entry['plasticKg'] is num)
          ? (entry['plasticKg'] as num).toDouble()
          : double.tryParse('${entry['plasticKg']}') ?? 0.0;

      final totalCost = qty * rate;
      entry['qty'] = qty;
      entry['rate'] = rate;
      entry['materialKg'] = materialKg;
      entry['plasticKg'] = plasticKg;
      entry['totalCost'] = totalCost;

      items[materialId] = entry;

      totalAmount += totalCost;
      totalMaterialKg += materialKg * qty;
      totalPlasticKg += plasticKg * qty;
    });

    final challanNo = _generateUniqueNumber(prefix: 'CH');
    final now = DateTime.now().millisecondsSinceEpoch;

    final doc = {
      'supplierId': supplierId,
      if (supplierName.isNotEmpty) 'supplierName': supplierName,
      'companyId': companyId,
      'items': items,
      'totalAmount': totalAmount,
      'totalMaterialKg': totalMaterialKg,
      'totalPlasticKg': totalPlasticKg,
      'status': 'open',
      'challanNo': challanNo,
      'createdAt': now,
    };

    final ref = await challans(companyId).add(doc);

    // Also create a pending inward request entry for this challan
    try {
      double totalQty = 0.0;
      items.forEach((_, entryRaw) {
        final entry = Map<String, dynamic>.from(entryRaw ?? {});
        final qty = (entry['qty'] is num)
            ? (entry['qty'] as num).toDouble()
            : double.tryParse('${entry['qty']}') ?? 0.0;
        totalQty += qty;
      });

      await inwardRequests().add({
        'companyId': companyId,
        'supplierId': supplierId,
        'challanId': ref.id,
        'items': items,
        'quantity': totalQty,
        'weight': totalMaterialKg + totalPlasticKg,
        'status': 'pending',
        'createdAt': now,
      });
    } catch (_) {
      // best-effort; dashboard will still work even if inward entry fails
    }

    return ref.id;
  }

  Future<void> updateChallanStatus(
    String companyId,
    String challanId,
    String status,
  ) async {
    await challans(companyId).doc(challanId).update({
      'status': status,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<List<Map<String, dynamic>>> getChallans(String companyId) async {
    final snap = await challans(
      companyId,
    ).orderBy('createdAt', descending: true).get();
    return snap.docs.map((d) {
      final m = Map<String, dynamic>.from(d.data());
      m['id'] = d.id;
      return m;
    }).toList();
  }

  // ---------------- Supplier bills ----------------
  Future<String> createSupplierBillFromChallan(
    String companyId,
    String challanId,
  ) async {
    final chDoc = await challans(companyId).doc(challanId).get();
    if (!chDoc.exists) throw Exception('Challan not found');
    final data = chDoc.data()!;
    final amountRaw = data['totalAmount'] ?? 0;
    final amount = (amountRaw is num)
        ? (amountRaw as num).toDouble()
        : double.tryParse('$amountRaw') ?? 0.0;
    final billNo = _generateUniqueNumber(prefix: 'B');

    final billDoc = {
      'challanId': challanId,
      'supplierId': data['supplierId'] ?? '',
      'companyId': companyId,
      'amount': amount,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
      'status': 'unpaid',
      'billNo': billNo,
    };

    final ref = await bills(companyId).add(billDoc);
    return ref.id;
  }

  Future<List<Map<String, dynamic>>> getSupplierBills(String companyId) async {
    final snap = await bills(
      companyId,
    ).orderBy('createdAt', descending: true).get();
    return snap.docs.map((d) {
      final m = Map<String, dynamic>.from(d.data());
      m['id'] = d.id;
      return m;
    }).toList();
  }

  Future<void> deleteSupplierBill(String companyId, String billId) async {
    await bills(companyId).doc(billId).delete();
  }

  // ---------------- Dashboard summary ----------------
  Future<Map<String, dynamic>> getDashboardSummary(String companyId) async {
    // run queries in parallel
    final futures = await Future.wait([
      inwardRequests()
          .where('companyId', isEqualTo: companyId)
          .where('status', isEqualTo: 'pending')
          .get(),
      outwardRequests()
          .where('companyId', isEqualTo: companyId)
          .where('status', isEqualTo: 'pending')
          .get(),
      supplierRequests().where('companyId', isEqualTo: companyId).get(),
      challans(companyId).where('status', isEqualTo: 'open').get(),
      bills(companyId).where('status', isEqualTo: 'unpaid').get(),
      receipts(companyId).get(),
    ]);

    final pendingInward = futures[0] as QuerySnapshot<Map<String, dynamic>>;
    final pendingOutward = futures[1] as QuerySnapshot<Map<String, dynamic>>;
    final supplierReq = futures[2] as QuerySnapshot<Map<String, dynamic>>;
    final openChallans = futures[3] as QuerySnapshot<Map<String, dynamic>>;
    final pendingBills = futures[4] as QuerySnapshot<Map<String, dynamic>>;
    final receiptsSnap = futures[5] as QuerySnapshot<Map<String, dynamic>>;

    double totalAdvance = 0.0;
    for (var doc in receiptsSnap.docs) {
      final data = doc.data();
      final amtRaw = data['amount'] ?? 0;
      final amt = (amtRaw is num)
          ? (amtRaw as num).toDouble()
          : double.tryParse('$amtRaw') ?? 0.0;
      totalAdvance += amt;
    }

    return {
      'pendingInward': pendingInward.docs.length,
      'pendingOutward': pendingOutward.docs.length,
      'supplierRequests': supplierReq.docs.length,
      'openChallans': openChallans.docs.length,
      'pendingBills': pendingBills.docs.length,
      'advanceReceipts': totalAdvance,
    };
  }

  // ---------------- Helpers ----------------
  String _generateUniqueNumber({required String prefix}) {
    final ts = DateTime.now().millisecondsSinceEpoch;
    return '$prefix$ts';
  }
}
