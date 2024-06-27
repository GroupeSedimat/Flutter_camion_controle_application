class MyUser {
  //String dob;
  String role;
  String username;
  String email;
  String name;
  String firstname;

  MyUser({
    //required this.dob,
    required this.role,
    required this.username,
    required this.email,
    required this.name,
    required this.firstname,
  });

  MyUser.fromJson(Map<String, Object?> json)
      : //dob = json['dob'] as String? ?? '',
        role = json['role'] as String? ?? '',
        username = json['username'] as String? ?? '',
        name = json['name'] as String? ?? '',
        firstname = json['firstname'] as String? ?? '',
        email = json['email'] as String? ?? '';

  MyUser copyWith({
    //String? dob,
    String? role,
    String? username,
    String? email,
    String? name,
    String? firstname,
  }) {
    return MyUser(
      //dob: dob ?? this.dob,
      role: role ?? this.role,
      username: username ?? this.username,
      name: name ?? this.name,
      firstname: firstname ?? this.firstname,
      email: email ?? this.email,
    );
  }

  Map<String, Object?> toJson() {
    return {
      //'dob': dob,
      'role': role,
      'username': username,
      'name': name,
      'firstname': firstname,
      'email': email,
    };
  }
}
