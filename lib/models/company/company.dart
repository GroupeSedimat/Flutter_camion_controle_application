class Company {

  String name;
  String description;
  String sirene;
  String siret;
  String address;
  String responsible;
  String admin;
  String tel;
  String email;
  String logo;

  Company({
    required this.name,
    required this.description,
    required this.sirene,
    required this.siret,
    required this.address,
    required this.responsible,
    required this.admin,
    required this.tel,
    required this.email,
    required this.logo,
  });

  Company.fromJson(Map<String, Object?> json): this (
    name: json['name']! as String,
    description: json['description']! as String,
    sirene: json['sirene']! as String,
    siret: json['siret']! as String,
    address: json['address']! as String,
    responsible: json['responsible']! as String,
    admin: json['admin']! as String,
    tel: json['tel']! as String,
    email: json['email']! as String,
    logo: json['logo']! as String,
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
    };
  }
}