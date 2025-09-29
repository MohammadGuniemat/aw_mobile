class User {
  final int userId;
  final String userName;
  final bool accountStatus;
  final String role;

  User({
    required this.userId,
    required this.userName,
    required this.accountStatus,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'] as int,
      userName: json['userName'] as String,
      accountStatus: json['account_status'] as bool,
      role: (json['role'] as String).trim(), // 👈 removes extra spaces
    );
  }
}
