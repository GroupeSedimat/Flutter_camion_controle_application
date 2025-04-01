class Equipment {
  String? idShop;
  String name;
  String? description;
  List<String>? photo;
  int? quantity;
  bool? available;
  DateTime createdAt;
  DateTime updatedAt;
  DateTime? deletedAt;
// tagNFC
// comsommable

  Equipment({
    this.idShop,
    required this.name,
    this.description,
    this.photo,
    this.quantity,
    this.available,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  Equipment.fromJson(Map<String, Object?> json): this (
    idShop: json["idShop"]!= null
        ?  json['idShop'] as String
        : null,
    name: json["name"]! as String,
    description: json["description"]!= null
        ?  json['description'] as String
        : null,
    photo: json["photo"] != null
        ? (json['photo'] as List<dynamic>)
        .map((photo) => (photo as String))
        .toList()
        : null,
    quantity: json["quantity"]!= null
        ?  json['quantity'] as int
        : null,
    available: json["available"]!= null
        ?  json['available'] as bool
        : null,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
    deletedAt: json['deletedAt'] != null
        ? DateTime.parse(json['deletedAt'] as String)
        : null,
  );

  Equipment copyWith({
    String? idShop,
    String? name,
    String? description,
    List<String>? photo,
    int? quantity,
    bool? available,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return Equipment(
      idShop: idShop ?? this.idShop,
      name: name ?? this.name,
      description: description ?? this.description,
      photo: photo ?? this.photo,
      quantity: quantity ?? this.quantity,
      available: available ?? this.available,
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
    if (idShop != null) json['idShop'] = idShop;
    if (description != null) json['description'] = description;
    if (photo != null) json['photo'] = photo!.map((item) => item).toList();
    if (quantity != null) json['quantity'] = quantity;
    if (available != null) json['available'] = available;
    if (deletedAt != null) json['deletedAt'] = deletedAt!.toIso8601String();
    return json;
  }
}