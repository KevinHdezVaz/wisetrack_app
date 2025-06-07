// archivo: vehicle_model.dart (o puedes ponerlo en el mismo archivo de la pantalla)
import 'package:flutter/material.dart';

enum VehicleType { bus, truck }

class Vehicle {
  final String name;
  final VehicleType type;
  final bool isLocationActive;
  final bool isGpsActive;
  final bool isKeyActive;
  final bool isShieldActive;

  Vehicle({
    required this.name,
    required this.type,
    this.isLocationActive = false,
    this.isGpsActive = false,
    this.isKeyActive = false,
    this.isShieldActive =
        true, // El escudo casi siempre está activo en la imagen
  });
}
