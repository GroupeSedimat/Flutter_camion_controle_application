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
    description: json['description'] != null ? json['responsible'] as String : null,
    sirene: json['sirene'] != null ? json['responsible'] as String : null,
    siret: json['siret'] != null ? json['responsible'] as String : null,
    address: json['address'] != null ? json['responsible'] as String : null,
    responsible: json['responsible'] != null ? json['responsible'] as String : null,
    admin: json['admin'] != null ? json['responsible'] as String : null,
    tel: json['tel'] != null ? json['responsible'] as String : null,
    email: json['email'] != null ? json['responsible'] as String : null,
    logo: json['logo'] != null ? json['responsible'] as String : null,
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
    return{
      'name': name,
      'description': description,
      'sirene': sirene,
      'siret': siret,
      'address': address,
      'responsible': responsible,
      'admin': admin,
      'tel': tel,
      'email': email,
      'logo': logo,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'deletedAt': deletedAt,
    };
  }
}