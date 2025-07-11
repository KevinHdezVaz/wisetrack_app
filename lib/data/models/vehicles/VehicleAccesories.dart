class VehicleAccessories {
  final Map<String, String> accessories;

  VehicleAccessories({required this.accessories});

  factory VehicleAccessories.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final accessories = data.map((key, value) => MapEntry(key, value.toString()));
    
    return VehicleAccessories(accessories: accessories);
  }

  @override
  String toString() => 'VehicleAccessories(accessories: $accessories)';
}