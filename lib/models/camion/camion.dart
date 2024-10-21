import 'package:cloud_firestore/cloud_firestore.dart';

class Camion {
  String name;
  String camionType;
  String? responsible;
  String? checks;
  String? lastIntervention;
  String? status;
  String? location;
  String company;

  Camion({
    required this.name,
    required this.camionType,
    this.responsible,
    this.checks,
    this.lastIntervention,
    this.status,
    this.location,
    required this.company,
  });

  // Constructor with Json
  Camion.fromJson(Map<String, Object?> json): this (
    name: json['name']! as String,
    camionType: json['camionType']! as String,
    responsible: json['responsible']! as String,
    checks: json['checks']! as String,
    lastIntervention: json['lastIntervention']! as String,
    status: json['status']! as String,
    location: json['location']! as String,
    company: json['company']! as String,
  );

  // Constructor with DocumentSnapshot (Firestore)
  factory Camion.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Camion(
      name: data['name'] as String,
      camionType: data['camionType'] as String,
      responsible: data['responsible'] as String,
      checks: data['checks'] as String,
      lastIntervention: data['lastIntervention'] as String,
      status: data['status'] as String,
      location: data['location'] as String,
      company: data['company'] as String,
    );
  }

  Camion copyWith({
    String? name,
    String? camionType,
    String? responsible,
    String? checks,
    String? lastIntervention,
    String? status,
    String? location,
    String? company,
  }) {
    return Camion(
      name: name ?? this.name,
      camionType: camionType ?? this.camionType,
      responsible: responsible ?? this.responsible,
      checks: checks ?? this.checks,
      lastIntervention: lastIntervention ?? this.lastIntervention,
      status: status ?? this.status,
      location: location ?? this.location,
      company: company ?? this.company,
    );
  }

  Map<String, Object?> toJson(){
    return{
      'name': name,
      'camionType': camionType,
      'responsible': responsible,
      'checks': checks,
      'lastIntervention': lastIntervention,
      'status': status,
      'location': location,
      'company': company,
    };
  }
}