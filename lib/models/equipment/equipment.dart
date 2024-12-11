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
    return{
      'idShop': idShop,
      'name': name,
      'description': description,
      'photo': photo,
      'quantity': quantity,
      'available': available,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'deletedAt': deletedAt,
    };
  }
}