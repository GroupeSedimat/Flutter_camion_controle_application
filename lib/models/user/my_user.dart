class MyUser {
  String dob;
  String role;
  String username;
  String email;

  MyUser({
    required this.dob,
    required this.role,
    required this.username,
    required this.email,
  });

  MyUser.fromJson(Map<String, Object?> json)
      : this(
          dob: json['dob']! as String,
          role: json['role']! as String,
          username: json['username']! as String,
          email: json['email']! as String,
        );

  MyUser copyWith({
    String? dob,
    String? role,
    String? username,
    String? email,
  }) {
    return MyUser(
      dob: dob ?? this.dob,
      role: role ?? this.role,
      username: username ?? this.username,
      email: email ?? this.email,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'dob': dob,
      'role': role,
      'username': username,
      'email': email,
    };
  }
}
