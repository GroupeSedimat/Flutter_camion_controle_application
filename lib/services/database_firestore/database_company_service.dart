import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/models/company/company.dart';

const String COMPANY_COLLECTION_REF = "company";

class DatabaseCompanyService{
  final _firestore = FirebaseFirestore.instance;
  late final CollectionReference _companyRef;

  DatabaseCompanyService(){
    _companyRef = _firestore
        .collection(COMPANY_COLLECTION_REF)
        .withConverter<Company>(
        fromFirestore: (snapshots, _)=> Company.fromJson(
          snapshots.data()!,
        ),
        toFirestore: (company, _) => company.toJson()                         
    );
  }

Future<Map<String, Company>> getAllCompanies() async {
    try {
      final querySnapshot = await _companyRef.get();
      List companySnapshotList = querySnapshot.docs;

      Map<String, Company> companies = HashMap();
      for (var companySnapshot in companySnapshotList){
        companies.addAll({companySnapshot.id: companySnapshot.data()});
      }
      var sortedKeys = companies.keys.toList(growable: false)
        ..sort((k1, k2) => companies[k1]!.name.compareTo(companies[k2]!.name));

      LinkedHashMap<String, Company> sortedCompanies = LinkedHashMap.fromIterable(
        sortedKeys,
        key: (k) => k,
        value: (k) => companies[k]!,
      );

      return sortedCompanies;

    } catch (e) {
      print("Error getting companies: $e");
      rethrow;
    }
  }

  Future<Map<String, String>> getAllCompaniesNames() async {
    try {
      final querySnapshot = await _companyRef.get();
      List companySnapshotList = querySnapshot.docs;

      Map<String, String> companies = HashMap();
      for (var companySnapshot in companySnapshotList){
        companies[companySnapshot.id] = companySnapshot.data().name;
      }
      var sortedKeys = companies.keys.toList(growable: false)
        ..sort((k1, k2) => companies[k1]!.toLowerCase().compareTo(companies[k2]!.toLowerCase()));

      LinkedHashMap<String, String> sortedCompanies = LinkedHashMap.fromIterable(
        sortedKeys,
        key: (k) => k,
        value: (k) => companies[k]!,
      );
      return sortedCompanies;
    } catch (e) {
        print("Error getting companies: $e");
        rethrow;
      }
  }

  Future<Company?> getOneCompanyByName(String name) async {
    try {
      final querySnapshot = await _firestore
          .collection(COMPANY_COLLECTION_REF)
          .where("name", isEqualTo: name)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        return Company.fromJson(querySnapshot.docs.first.data());
      }else{
        return null;
      }

    } catch (error) {
      print("Error retrieving company: $error");
      rethrow;
    }
  }

  Future<Map<String, Company>> getAllCompaniesSinceLastSync(String lastSync) async {
    Query query = _companyRef;
    query = query.where('updatedAt', isGreaterThan: lastSync);

    try {
      QuerySnapshot querySnapshot = await query.get();
      Map<String, Company> companies = HashMap();
      for (var doc in querySnapshot.docs) {
        companies[doc.id] = doc.data() as Company;
      }
      return companies;
    } catch (e) {
      print("Error fetching Companies since last update data: $e");
      rethrow;
    }
  }

  Future<String> getCompanyIDByName(String name) async {
    try {
      final querySnapshot = await _firestore
          .collection(COMPANY_COLLECTION_REF)
          .where("name", isEqualTo: name)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.id;
      }else{
        return '';
      }

    } catch (error) {
      // Gérez l’erreur
      print("Error retrieving company ID: $error");
      return '';
    }
  }

  Future<Company?> getCompanyByID(String id) async {
    try {
      final querySnapshot = await _companyRef.doc(id).get();
      return querySnapshot.data() as Company;

    } catch (error) {
      // Gérez l’erreur
      print("Error retrieving company ID: $error");
      return null;
    }
  }

  Future<Map<String, Company>> getCompanyByIdSinceLastSync(String lastSync, String id) async {
    Query query = _companyRef;
    query = query.where('updatedAt', isGreaterThan: lastSync);
    try {
      QuerySnapshot querySnapshot = await query.get();
      Map<String, Company> companies = HashMap();
      for (var doc in querySnapshot.docs) {
        if(doc.id == id){
          companies[doc.id] = doc.data() as Company;
        }
      }
      return companies;

    } catch (error) {
      print("Error fetching Company with id $id since last update data: $error");
      rethrow;
    }
  }

  Future<String> addCompany(Company company) async {
    var returnAdd = await _companyRef.add(company);
    print("------------- ---------- ---------- database add company${returnAdd.id}");
    return returnAdd.id;
  }

  Future<void> updateCompany(String companyID, Company company) async {
    final data = company.toJson();
    if(company.deletedAt == null){
      data['deletedAt'] = FieldValue.delete();
    }
    await _companyRef.doc(companyID).update(data);
  }

  Future<void> deleteCompany(String companyID) async {
    _companyRef.doc(companyID).delete();
  }

  Future<void> softDeleteCompany(String companyID) async {
    try{
      await _companyRef.doc(companyID).update({
        'deletedAt': DateTime.now().toIso8601String(),
      });
      print("Company with ID $companyID not found for soft delete.");
    }catch(e){
      print("Error while trying soft deleting company with ID $companyID: $e");
    }
  }

}