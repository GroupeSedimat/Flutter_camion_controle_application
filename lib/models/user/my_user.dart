class MyUser {
  String role;
  String username;
  String email;
  String? name;
  String? firstname;
  String company;
  bool? apresFormation;
  String? apresFormationDoc;
  List<String>? camion; /// todo change to List<String> for more camions (here and everywhere) plus display and selection in profile editing
  DateTime createdAt;
  DateTime updatedAt;
  DateTime? deletedAt;

  MyUser({
    required this.role,
    required this.username,
    required this.email,
    this.name,
    this.firstname,
    required this.company,
    this.apresFormation,
    this.apresFormationDoc,
    this.camion,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  MyUser.fromJson(Map<String, Object?> json): this (
    role: json['role']! as String,
    username: json['username']! as String,
    email: json['email']! as String,
    name: json['name'] != null ? json['name'] as String : null,
    firstname: json['firstname'] != null ? json['firstname'] as String : null,
    company: json['company']! as String,
    apresFormation: json['apresFormation'] != null ? json['apresFormation'] as bool : null,
    apresFormationDoc: json['apresFormationDoc'] != null ? json['apresFormationDoc'] as String : null,
    camion: json['camion'] != null
        ? (json['camion'] as List<dynamic>)
        .map((item) => item as String)
        .toList()
        : null,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
    deletedAt: json['deletedAt'] != null
        ? DateTime.parse(json['deletedAt'] as String)
        : null,
  );

  MyUser copyWith({
    String? role,
    String? username,
    String? email,
    String? name,
    String? firstname,
    String? company,
    bool? apresFormation,
    String? apresFormationDoc,
    List<String>? camion,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return MyUser(
      role: role ?? this.role,
      username: username ?? this.username,
      email: email ?? this.email,
      name: name ?? this.name,
      firstname: firstname ?? this.firstname,
      company: company ?? this.company,
      apresFormation: apresFormation ?? this.apresFormation,
      apresFormationDoc: apresFormationDoc ?? this.apresFormationDoc,
      camion: camion ?? this.camion,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  Map<String, Object?> toJson(){
    final Map<String, Object?> json = {
      'role': role,
      'username': username,
      'email': email,
      'company': company,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
    if (name != null) json['name'] = name;
    if (firstname != null) json['firstname'] = firstname;
    if (apresFormation != null) json['apresFormation'] = apresFormation;
    if (apresFormationDoc != null) json['apresFormationDoc'] = apresFormationDoc;
    if (camion != null) json['camion'] = camion!.map((item) => item).toList();
    if (deletedAt != null) json['deletedAt'] = deletedAt!.toIso8601String();
    return json;
  }
}