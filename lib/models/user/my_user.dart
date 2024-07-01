class MyUser {
  String role;
  String username;
  String email;
  String name;
  String firstname;
  String company;

  MyUser({
    required this.role,
    required this.username,
    required this.email,
    required this.name,
    required this.firstname,
    required this.company,
  });

  MyUser.fromJson(Map<String, Object?> json): this (
    role: json['role']! as String,
    username: json['username']! as String,
    email: json['email']! as String,
    name: json['name']! as String,
    firstname: json['firstname']! as String,
    company: json['company']! as String,
  );

  MyUser copyWith({
    String? role,
    String? username,
    String? email,
    String? name,
    String? firstname,
    String? company,
  }) {
    return MyUser(
      role: role ?? this.role,
      username: username ?? this.username,
      email: email ?? this.email,
      name: name ?? this.name,
      firstname: firstname ?? this.firstname,
      company: company ?? this.company,
    );
  }

  Map<String, Object?> toJson(){
    return{
      'role': role,
      'username': username,
      'email': email,
      'name': name,
      'firstname': firstname,
      'company': company,
    };
  }
}