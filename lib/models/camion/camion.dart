class Camion {
  String name;
  String camionType;
  String? responsible;
  List<DateTime>? checks;
  String? lastIntervention;
  String? status;
  String? location;
  String company;
  DateTime createdAt;
  DateTime updatedAt;
  DateTime? deletedAt;

  Camion({
    required this.name,
    required this.camionType,
    this.responsible,
    this.checks,
    this.lastIntervention,
    this.status,
    this.location,
    required this.company,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  // Constructor with Json
  Camion.fromJson(Map<String, Object?> json)
      : this(
          name: json['name']! as String,
          camionType: json['camionType']! as String,
          responsible: json['responsible'] != null
              ? json['responsible'] as String
              : null,
          checks: json['checks'] != null
              ? (json['checks'] as List<dynamic>)
                  .map((date) => DateTime.parse(date as String))
                  .toList()
              : null,
          lastIntervention: json['lastIntervention'] != null
              ? json['lastIntervention'] as String
              : null,
          status: json['status'] != null ? json['status'] as String : null,
          location:
              json['location'] != null ? json['location'] as String : null,
          company: json['company']! as String,
          createdAt: DateTime.parse(json['createdAt'] as String),
          updatedAt: DateTime.parse(json['updatedAt'] as String),
          deletedAt: json['deletedAt'] != null
              ? DateTime.parse(json['deletedAt'] as String)
              : null,
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
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
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
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  Map<String, Object?> toJson() {
    final Map<String, Object?> json = {
      'name': name,
      'camionType': camionType,
      'company': company,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
    if (responsible != null) json['responsible'] = responsible;
    if (checks != null)
      json['checks'] = checks!.map((date) => date.toIso8601String()).toList();
    if (lastIntervention != null) json['lastIntervention'] = lastIntervention;
    if (status != null) json['status'] = status;
    if (location != null) json['location'] = location;
    if (deletedAt != null) json['deletedAt'] = deletedAt!;
    return json;
  }
}
