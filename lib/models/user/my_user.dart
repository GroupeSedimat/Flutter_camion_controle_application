class MyUser {

  String dob;
  String role;
  String username;

  MyUser({
    required this.dob,
    required this.role,
    required this.username,
  });

  MyUser.fromJson(Map<String, Object?> json): this (
      dob: json['dob']! as String,
      role: json['role']! as String,
      username: json['username']! as String,
  );

  MyUser copyWith({
    String? dob,
    String? role,
    String? username,
  }){
    return MyUser(
      dob: dob ?? this.dob,
      role: role ?? this.role,
      username: username ?? this.username,
    );
  }

  Map<String, Object?> toJson(){
    return{
      'dob': dob,
      'role': role,
      'username': username,
    };
  }
}