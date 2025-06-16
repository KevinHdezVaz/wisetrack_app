class UserDetail {
  final String id;
  final String username;
  final String email;
  final String? fullName;
  final String? company;
  final String? role;

  UserDetail({
    required this.id,
    required this.username,
    required this.email,
    this.fullName,
    this.company,
    this.role,
  });

  factory UserDetail.fromJson(Map<String, dynamic> json) {
    return UserDetail(
      id: json['id']?.toString() ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'],
      company: json['company'],
      role: json['role'],
    );
  }
}
