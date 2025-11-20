import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inward_outward_management/core/models/material_model.dart';
import 'package:inward_outward_management/core/models/unit_model.dart';
import 'package:inward_outward_management/core/models/supplier_model.dart';
import 'package:inward_outward_management/core/models/customer_model.dart';

class CompanyRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ---------------------------------------------------------------------------
  // MATERIAL CRUD SECTION
  // ---------------------------------------------------------------------------

  /// Add a new Material to Firestore
  Future<void> addMaterial(MaterialModel material) async {
    await _firestore.collection('materials').add(material.toMap());
  }

  /// Fetch all Materials from Firestore
  Future<List<MaterialModel>> fetchMaterials() async {
    final snapshot = await _firestore.collection('materials').get();
    return snapshot.docs
        .map((doc) => MaterialModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  /// Update Material data
  Future<void> updateMaterial(String id, MaterialModel material) async {
    await _firestore.collection('materials').doc(id).update(material.toMap());
  }

  /// Delete Material
  Future<void> deleteMaterial(String id) async {
    await _firestore.collection('materials').doc(id).delete();
  }

  // ---------------------------------------------------------------------------
  // UNIT CRUD SECTION
  // ---------------------------------------------------------------------------

  Future<void> addUnit(UnitModel unit) async {
    await _firestore.collection('units').add(unit.toMap());
  }

  Future<List<UnitModel>> fetchUnits() async {
    final snapshot = await _firestore.collection('units').get();
    return snapshot.docs
        .map((doc) => UnitModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<void> updateUnit(String id, UnitModel unit) async {
    await _firestore.collection('units').doc(id).update(unit.toMap());
  }

  Future<void> deleteUnit(String id) async {
    await _firestore.collection('units').doc(id).delete();
  }

  // ---------------------------------------------------------------------------
  // SUPPLIER CRUD SECTION
  // ---------------------------------------------------------------------------

  Future<void> addSupplier(SupplierModel supplier) async {
    await _firestore.collection('suppliers').add(supplier.toMap());
  }

  Future<List<SupplierModel>> fetchSuppliers() async {
    final snapshot = await _firestore.collection('suppliers').get();
    return snapshot.docs
        .map((doc) => SupplierModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<void> updateSupplier(String id, SupplierModel supplier) async {
    await _firestore.collection('suppliers').doc(id).update(supplier.toMap());
  }

  Future<void> deleteSupplier(String id) async {
    await _firestore.collection('suppliers').doc(id).delete();
  }

  // ---------------------------------------------------------------------------
  // CUSTOMER CRUD SECTION
  // ---------------------------------------------------------------------------

  Future<void> addCustomer(CustomerModel customer) async {
    await _firestore.collection('customers').add(customer.toMap());
  }

  Future<List<CustomerModel>> fetchCustomers() async {
    final snapshot = await _firestore.collection('customers').get();
    return snapshot.docs
        .map((doc) => CustomerModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<void> updateCustomer(String id, CustomerModel customer) async {
    await _firestore
        .collection('customers')
        .doc(id)
        .update(customer.toMap());
  }

  Future<void> deleteCustomer(String id) async {
    await _firestore.collection('customers').doc(id).delete();
  }
}
