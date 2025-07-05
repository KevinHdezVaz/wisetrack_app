class UserDetailResponse {
  final UserData data;

  UserDetailResponse({required this.data});

  factory UserDetailResponse.fromJson(Map<String, dynamic> json) {
    return UserDetailResponse(
      data: UserData.fromJson(json['data']),
    );
  }
}

class UserData {
  final String username;
  final String name;
  final String? lastname;
  final Company company;
  final String? phone;
  final PermissionDetail permission;
  final String userImage;

  UserData({
    required this.username,
    required this.name,
    this.lastname,
    required this.company,
    this.phone,
    required this.permission,
    required this.userImage,
  });

  // El factory que ya tenías (está perfecto)
  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      username: json['username'] as String,
      name: json['name'] as String,
      lastname: json['lastname'] as String?,
      company: Company.fromJson(json['company']),
      phone: json['phone'] as String?,
      permission: PermissionDetail.fromJson(json['permission']),
      userImage: json['user_image'] as String,
    );
  }

  // --- MÉTODO AÑADIDO ---
  // Convierte el objeto UserData a un mapa JSON.
  Map<String, dynamic> toJson() => {
    'username': username,
    'name': name,
    'lastname': lastname,
    'company': company.toJson(), // Llama al toJson() de la clase Company
    'phone': phone,
    'permission': permission.toJson(), // Llama al toJson() de la clase Permission
    'user_image': userImage,
  };

  // Tu getter (está perfecto)
  String get fullName => lastname != null ? '$name $lastname' : name;
}

class Company {
  final String name;

  Company({required this.name});

  // El factory que ya tenías (está bien)
  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      name: json['name'] as String,
    );
  }

  // --- MÉTODO FALTANTE AÑADIDO ---
  // Convierte la instancia de la clase a un mapa JSON.
  Map<String, dynamic> toJson() => {
    'name': name,
  };
}

class PermissionDetail {
  final bool allowNotification;
  final AlertPermissions alertPermissions;

  PermissionDetail({
    required this.allowNotification,
    required this.alertPermissions,
  });

factory PermissionDetail.fromJson(Map<String, dynamic> json) {
  return PermissionDetail(
    // Si 'allow_notification' es null, usa 'false' por defecto.
    allowNotification: json['allow_notification'] ?? false, 
    alertPermissions: AlertPermissions.fromJson(json['alert_permissions']),
  );
}

  Map<String, dynamic> toJson() => {
    'allow_notification': allowNotification,
    'alert_permissions': alertPermissions.toJson(), // Asumiendo que AlertPermissions también tiene un toJson()
  };

}

class AlertPermissions {
  final bool velocidadMaxima;
  final bool descansoCorto;
  final bool noPresentacionDestino;
  final bool conduccion10Horas;
  final bool conduccionContinua;

  AlertPermissions({
    required this.velocidadMaxima,
    required this.descansoCorto,
    required this.noPresentacionDestino,
    required this.conduccion10Horas,
    required this.conduccionContinua,
  });

  // Este factory está perfecto, no necesita cambios.
 factory AlertPermissions.fromJson(Map<String, dynamic> json) {
  return AlertPermissions(
    velocidadMaxima: json['Velocidad Maxima'] ?? false,
    descansoCorto: json['descanso corto'] ?? false,
    noPresentacionDestino: json['No presentación en destino'] ?? false,
    conduccion10Horas: json['conduccion 10 Horas'] ?? false,
    conduccionContinua: json['conduccion continua'] ?? false,
  );
}

  // --- MÉTODO CORREGIDO ---
  // Convierte las propiedades de esta clase a un mapa JSON.
  Map<String, dynamic> toJson() => {
    // La llave del mapa debe ser exactamente la misma que usas en fromJson.
    'Velocidad Maxima': velocidadMaxima,
    'descanso corto': descansoCorto,
    'No presentación en destino': noPresentacionDestino,
    'conduccion 10 Horas': conduccion10Horas,
    'conduccion continua': conduccionContinua,
  };


}