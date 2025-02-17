class Camion {
  String name;
  String camionType;
  String? responsible;
  List<DateTime>? checks;
  String? lastIntervention;
  String? status;
  String? location;
  String company;
  double? latitude;
  double? longitude;
  

  Camion({
    required this.name,
    required this.camionType,
    this.responsible,
    this.checks,
    this.lastIntervention,
    this.status,
    this.location,
    required this.company,
    this.latitude,
    this.longitude,
  });

  // Constructor with Json
  Camion.fromJson(Map<String, Object?> json): this (
    name: json['name']! as String,
    camionType: json['camionType']! as String,
    responsible: json['responsible']! as String,
    checks: (json['checks']! as List<dynamic>?)?.map((date) => DateTime.parse(date as String)).toList(),
    lastIntervention: json['lastIntervention']! as String,
    status: json['status']! as String,
    location: json['location']! as String,
    company: json['company']! as String,
    latitude: (json['latitude'] as num?)?.toDouble(),
    longitude: (json['longitude'] as num?)?.toDouble(),
  );

  Camion copyWith({
    String? name,
    String? camionType,
    String? responsible,
    List<DateTime>? checks,
    String? lastIntervention,
    String? status,
    String? location,
    String? company,
    double? latitude,
    double? longitude,
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
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  Map<String, Object?> toJson(){
    return{
      'name': name,
      'camionType': camionType,
      'responsible': responsible,
      'checks': checks?.map((date) => date.toIso8601String()).toList(),
      'lastIntervention': lastIntervention,
      'status': status,
      'location': location,
      'company': company,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}