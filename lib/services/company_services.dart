// lib/services/company_services.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inward_outward_management/core/models/material_model.dart';

class CompanyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Helper paths
  CollectionReference<Map<String, dynamic>> companyCollection() =>
      _firestore.collection('companies');

  CollectionReference<Map<String, dynamic>> materials(String companyId) =>
      companyCollection().doc(companyId).collection('materials');

  CollectionReference<Map<String, dynamic>> challans(String companyId) =>
      companyCollection().doc(companyId).collection('challans');

  CollectionReference<Map<String, dynamic>> bills(String companyId) =>
      companyCollection().doc(companyId).collection('bills');

  CollectionReference<Map<String, dynamic>> receipts(String companyId) =>
      companyCollection().doc(companyId).collection('advance_receipts');

  // ---------------------------------------------------------------------------
  // MATERIAL CRUD
  // ---------------------------------------------------------------------------

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

  Future<List<MaterialModel>> getMaterials(String companyId) async {
    final snap = await materials(companyId).get();
    return snap.docs.map((d) => MaterialModel.fromMap(d.id, d.data())).toList();
  }

  // ---------------------------------------------------------------------------
  // DASHBOARD STATS
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>> getDashboardSummary(String companyId) async {
    // Fetch counts in parallel
    final pendingInward = await _firestore
        .collection('inward_requests')
        .where('companyId', isEqualTo: companyId)
        .where('status', isEqualTo: 'pending')
        .get();

    final pendingOutward = await _firestore
        .collection('outward_requests')
        .where('companyId', isEqualTo: companyId)
        .where('status', isEqualTo: 'pending')
        .get();

    final supplierRequests = await _firestore
        .collection('supplier_requests')
        .where('companyId', isEqualTo: companyId)
        .get();

    final openChallans = await challans(
      companyId,
    ).where('status', isEqualTo: 'open').get();

    final pendingBills = await bills(
      companyId,
    ).where('status', isEqualTo: 'unpaid').get();

    final receiptsSnap = await receipts(companyId).get();
    double totalAdvance = 0.0;
    for (var doc in receiptsSnap.docs) {
      final amt = (doc.data()['amount'] ?? 0).toDouble();
      totalAdvance += amt;
    }

    return {
      'pendingInward': pendingInward.docs.length,
      'pendingOutward': pendingOutward.docs.length,
      'supplierRequests': supplierRequests.docs.length,
      'openChallans': openChallans.docs.length,
      'pendingBills': pendingBills.docs.length,
      'advanceReceipts': totalAdvance,
    };
  }
}
