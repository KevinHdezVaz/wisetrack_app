class UserDetail {
  final String username;
  final String? name;
  final String? lastname;
  final int? company; // Cambiado a int? para coincidir con el JSON
  final String? phone;
  final List<String>
      permission; // Cambiado a List<String> para el arreglo permission

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
      username: data['username'] ?? '',
      name: data['name'],
      lastname: data['lastname'],
      company: data['company'], // Se mantiene como int? (puede ser null)
      phone: data['phone'],
      permission: List<String>.from(data['permission'] ?? []),
    );
  }

  String? get fullName {
    if (name == null && lastname == null) return null;
    if (name == null) return lastname;
    if (lastname == null) return name;
    return '$name $lastname';
  }
}
