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
      return companies;

    } catch (e) {
      print("Error getting companies: $e");
      rethrow; // Gérez l’erreur le cas échéant.
    }
  }

  Future<Company> getOneCompanyByName(String name) async {
    try {
      final querySnapshot = await _firestore
          .collection(COMPANY_COLLECTION_REF)
          .where("name", isEqualTo: name)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        return Company.fromJson(querySnapshot.docs.first.data());
      }else{
        return Company(name: '', description: '', sirene: '', siret: '', address: '', responsible: '', admin: '', tel: '', email: '', logo: '');
      }

    } catch (error) {
      // Gérez l’erreur
      print("Error retrieving company: $error");
      return Company(name: '', description: '', sirene: '', siret: '', address: '', responsible: '', admin: '', tel: '', email: '', logo: '');
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

  void addCompany(Company company) {
    _companyRef.add(company);
  }

  void updateTask(String companyID, Company company) {
    _companyRef.doc(companyID).update(company.toJson());
  }

  void deleteCompant(String companyID){
    _companyRef.doc(companyID).delete();
  }

}