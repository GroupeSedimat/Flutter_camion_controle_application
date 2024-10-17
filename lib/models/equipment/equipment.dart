class Equipment {
  String name;
  String description;

  Equipment({
    required this.name,
    required this.description,
  });

  Equipment.fromJson(Map<String, Object?> json): this (
    name: json['name']! as String,
    description: json['description']! as String,
  );

  Equipment copyWith({
    String? name,
    String? description,
  }) {
    return Equipment(
      name: name ?? this.name,
      description: description ?? this.description,
    );
  }

  Map<String, Object?> toJson(){
    return{
      'name': name,
      'description': description,
    };
  }
}