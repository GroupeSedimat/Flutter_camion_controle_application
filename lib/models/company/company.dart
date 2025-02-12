class Company {

  String name;
  String? description;
  String? sirene;
  String? siret;
  String? address;
  String? responsible;
  String? admin;
  String? tel;
  String? email;
  String? logo;
  DateTime createdAt;
  DateTime updatedAt;
  DateTime? deletedAt;

  Company({
    required this.name,
    this.description,
    this.sirene,
    this.siret,
    this.address,
    this.responsible,
    this.admin,
    this.tel,
    this.email,
    this.logo,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  Company.fromJson(Map<String, Object?> json): this (
    name: json['name']! as String,
    description: json['description'] != null ? json['description'] as String : null,
    sirene: json['sirene'] != null ? json['sirene'] as String : null,
    siret: json['siret'] != null ? json['siret'] as String : null,
    address: json['address'] != null ? json['address'] as String : null,
    responsible: json['responsible'] != null ? json['responsible'] as String : null,
    admin: json['admin'] != null ? json['admin'] as String : null,
    tel: json['tel'] != null ? json['tel'] as String : null,
    email: json['email'] != null ? json['email'] as String : null,
    logo: json['logo'] != null ? json['logo'] as String : null,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
    deletedAt: json['deletedAt'] != null
        ? DateTime.parse(json['deletedAt'] as String)
        : null,
  );

  Company copyWith({
    String? name,
    String? description,
    String? sirene,
    String? siret,
    String? address,
    String? responsible,
    String? admin,
    String? tel,
    String? email,
    String? logo,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }){
    return Company(
      name: name ?? this.name,
      description: description ?? this.description,
      sirene: sirene ?? this.sirene,
      siret: siret ?? this.siret,
      address: address ?? this.address,
      responsible: responsible ?? this.responsible,
      admin: admin ?? this.admin,
      tel: tel ?? this.tel,
      email: email ?? this.email,
      logo: logo ?? this.logo,
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
    if (description != null) json['description'] = description;
    if (sirene != null) json['sirene'] = sirene;
    if (siret != null) json['siret'] = siret;
    if (address != null) json['address'] = address;
    if (responsible != null) json['responsible'] = responsible;
    if (admin != null) json['admin'] = admin;
    if (tel != null) json['tel'] = tel;
    if (email != null) json['email'] = email;
    if (logo != null) json['logo'] = logo;
    if (deletedAt != null) json['deletedAt'] = deletedAt!.toIso8601String();
    return json;
  }
}