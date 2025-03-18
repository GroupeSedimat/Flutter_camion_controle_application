class CamionType {
  String name;
  List<String>? lol;
  List<String>? equipment;
  List<String>? routerData;
  DateTime createdAt;
  DateTime updatedAt;
  DateTime? deletedAt;

  CamionType({
    required this.name,
    this.lol,
    this.equipment,
    this.routerData,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  CamionType.fromJson(Map<String, Object?> json): this (
    name: json['name']! as String,
    lol: json['lol'] != null
        ? (json['lol'] as List<dynamic>)
        .map((item) => item as String)
        .toList()
        : null,
    equipment: json['equipment'] != null
        ? (json['equipment'] as List<dynamic>)
        .map((item) => item as String)
        .toList()
        : null,
    routerData: json['routerData'] != null
        ? (json['routerData'] as List<dynamic>)
        .map((item) => item as String)
        .toList()
        : null,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
    deletedAt: json['deletedAt'] != null
        ? DateTime.parse(json['deletedAt'] as String)
        : null,
  );

  CamionType copyWith({
    String? name,
    List<String>? lol,
    List<String>? equipment,
    List<String>? routerData,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return CamionType(
      name: name ?? this.name,
      lol: lol ?? this.lol,
      equipment: equipment ?? this.equipment,
      routerData: routerData ?? this.routerData,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  Map<String, Object?> toJson(){
    final Map<String, Object?> json = {
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
    if (lol != null) json['lol'] = lol!.map((item) => item).toList();
    if (equipment != null) json['equipment'] = equipment!.map((item) => item).toList();
    if (routerData != null) json['routerData'] = routerData!.map((item) => item).toList();
    if (deletedAt != null) json['deletedAt'] = deletedAt!.toIso8601String();
    return json;
  }
}