class CamionType {
  String name;
  List<String> lOl;
  List<String> equipment;
  List<String> routerData;
  /// ToDo add more info?

  CamionType({
    required this.name,
    required this.lOl,
    required this.equipment,
    required this.routerData,
  });

  CamionType.fromJson(Map<String, Object?> json): this (
    name: json['name']! as String,
    lOl: (json['lOl']! as List).map((item) => item as String).toList(),
    equipment: (json['equipment']! as List).map((item) => item as String).toList(),
    routerData: (json['routerData']! as List).map((item) => item as String).toList(),
  );

  CamionType copyWith({
    String? name,
    List<String>? lOl,
    List<String>? equipment,
    List<String>? routerData,
  }) {
    return CamionType(
      name: name ?? this.name,
      lOl: lOl ?? this.lOl,
      equipment: equipment ?? this.equipment,
      routerData: routerData ?? this.routerData,
    );
  }

  Map<String, Object?> toJson(){
    return{
      'name': name,
      'lOl': lOl,
      'equipment': equipment,
      'routerData': routerData,
    };
  }
}