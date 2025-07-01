class UserDetail {
  final String username;
  final String? name;
  final String? lastname;
  final Company? company; // Cambiado a un objeto Company
  final String? phone;
  final List<dynamic> permission; // Lista dinámica ya que el JSON muestra un array vacío

  UserDetail({
    required this.username,
    this.name,
    this.lastname,
    this.company,
    this.phone,
    required this.permission,
  });

  factory UserDetail.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    
    return UserDetail(
      username: data['username'] as String? ?? '',
      name: data['name'] as String?,
      lastname: data['lastname'] as String?,
      company: data['company'] != null 
          ? Company.fromJson(data['company'] as Map<String, dynamic>)
          : null,
      phone: data['phone'] as String?,
      permission: data['permission'] as List<dynamic>? ?? [],
    );
  }

  String? get fullName {
    if (name == null && lastname == null) return null;
    if (name == null) return lastname;
    if (lastname == null) return name;
    return '$name $lastname';
  }
}

class Company {
  final String name;

  Company({required this.name});

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      name: json['name'] as String? ?? '',
    );
  }
}