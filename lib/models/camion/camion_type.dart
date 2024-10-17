class CamionType {
  String name;
  List<String> lol;
  List<String> equipment;
  List<String> routerData;

  CamionType({
    required this.name,
    required this.lol,
    required this.equipment,
    required this.routerData,
  });

  CamionType.fromJson(Map<String, Object?> json): this (
    name: json['name']! as String,
    lol: (json['lol']! as List).map((item) => item as String).toList(),
    equipment: (json['equipment']! as List).map((item) => item as String).toList(),
    routerData: (json['routerData']! as List).map((item) => item as String).toList(),
  );

  CamionType copyWith({
    String? name,
    List<String>? lol,
    List<String>? equipment,
    List<String>? routerData,
  }) {
    return CamionType(
      name: name ?? this.name,
      lol: lol ?? this.lol,
      equipment: equipment ?? this.equipment,
      routerData: routerData ?? this.routerData,
    );
  }

  Map<String, Object?> toJson(){
    return{
      'name': name,
      'lol': lol,
      'equipment': equipment,
      'routerData': routerData,
    };
  }
}