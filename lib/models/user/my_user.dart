class MyUser {
  String dob;
  String role;
  String username;
  String? email; 

  MyUser({
    required this.dob,
    required this.role,
    required this.username,
    this.email, // Email optionnel
  });

  factory MyUser.fromJson(Map<String, dynamic> json) {
    return MyUser(
      dob: json['dob'] as String,
      role: json['role'] as String,
      username: json['username'] as String,
      email: json['email'] as String?, 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dob': dob,
      'role': role,
      'username': username,
      'email': email, 
    };
  }

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
}
