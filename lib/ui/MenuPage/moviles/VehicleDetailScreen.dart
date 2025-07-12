import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:geocoding/geocoding.dart';
import 'package:wisetrack_app/data/models/vehicles/VehicleAccesories.dart';
import 'package:wisetrack_app/data/models/vehicles/VehicleDetail.dart';
import 'package:wisetrack_app/data/services/vehicles_service.dart';
import 'package:wisetrack_app/ui/MenuPage/auditoria/AuditDetailsScreen.dart';
import 'package:wisetrack_app/ui/MenuPage/auditoria/AuditoriaScreen.dart';
import 'package:wisetrack_app/ui/MenuPage/moviles/EditMobileScreen.dart';
import 'package:wisetrack_app/ui/MenuPage/moviles/MobilesScreen.dart';
import 'package:wisetrack_app/ui/MenuPage/moviles/SecurityActionsScreen.dart';
import 'package:wisetrack_app/ui/color/app_colors.dart';
import 'package:wisetrack_app/utils/AnimatedTruckProgress.dart';

class VehicleDetailScreen extends StatefulWidget {
  final String plate;
  final String originScreen; // 'mobiles' o 'audit'
  final Function()? onDataChanged;

  const VehicleDetailScreen({
    Key? key,
    required this.plate,
    this.originScreen = 'mobiles', // Valor por defecto
    this.onDataChanged,
  }) : super(key: key);

  @override
  State<VehicleDetailScreen> createState() => _VehicleDetailScreenState();
}

class _VehicleDetailScreenState extends State<VehicleDetailScreen>
    with SingleTickerProviderStateMixin {
  late Future<VehicleDetail> _vehicleDetailFuture;
  late Future<VehicleAccessories?>
      _accessoriesFuture; // Nuevo Future para accesorios

  late AnimationController _animationController;

  String? _address;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _vehicleDetailFuture = VehicleService.getVehicleDetail(widget.plate);
    _accessoriesFuture = _loadAccessories(); // Cargar accesorios

    _vehicleDetailFuture.then((vehicleDetail) {
      if (mounted) {
        _getAddressFromCoordinates(vehicleDetail.location);
      }
    }).catchError((error) {
      debugPrint(
          "Error al cargar detalles del vehículo, no se puede geocodificar: $error");
    });
  }

  Future<VehicleAccessories?> _loadAccessories() async {
    try {
      return await VehicleService.getVehicleAccessories(widget.plate);
    } catch (e) {
      debugPrint("Error al cargar accesorios: $e");
      return null;
    }
  }

  void _handleBackAction() {
    if (widget.onDataChanged != null) {
      widget.onDataChanged!();
    }
    _animationController.stop();
    if (widget.originScreen == 'audit') {
      Navigator.pop(context); // Vuelve atrás normalmente
    } else {
      Navigator.pop(context); // Vuelve atrás normalmente
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _getAddressFromCoordinates(String location) async {
    if (location.isEmpty) {
      if (mounted) setState(() => _address = 'Ubicación no disponible');
      return;
    }

    try {
      final parts = location.split(',');
      if (parts.length != 2)
        throw const FormatException('Formato de ubicación inválido');
      final latString = parts[0].replaceAll(RegExp(r'lat:'), '').trim();
      final lonString = parts[1].replaceAll(RegExp(r'lon:'), '').trim();
      final lat = double.tryParse(latString);
      final lon = double.tryParse(lonString);

      if (lat == null || lon == null)
        throw const FormatException('Coordenadas inválidas después de limpiar');
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);

      if (mounted && placemarks.isNotEmpty) {
        final p = placemarks.first;
        final readableAddress = "${p.street}, ${p.locality}, ${p.country}";
        setState(() {
          _address = readableAddress;
        });
      } else if (mounted) {
        setState(() {
          _address = 'Dirección no encontrada';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _address = 'No se pudo obtener la dirección';
        });
        debugPrint("Error de geocodificación: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;

        final shouldRefresh = await _showExitConfirmation();
        _animationController.stop(); // Añade esto
        if (shouldRefresh && widget.onDataChanged != null) {
          widget.onDataChanged!(); // <-- Aquí estaba el error
        }

        if (mounted) {
          if (widget.originScreen == 'audit') {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const AuditoriaScreen()),
              (route) => false,
            );
          } else {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const MobilesScreen()),
              (route) => false,
            );
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: FutureBuilder<VehicleDetail>(
            future: _vehicleDetailFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                _animationController.repeat();
                return Center(
                  child: AnimatedTruckProgress(
                    animation: _animationController,
                  ),
                );
              }

              _animationController.stop();

              if (snapshot.hasError) {
                return Center(
                    child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                            'Error al cargar los detalles: ${snapshot.error}',
                            textAlign: TextAlign.center)));
              }

              if (snapshot.hasData) {
                final vehicleDetail = snapshot.data!;
                return _buildContent(context, vehicleDetail);
              }

              return const Center(child: Text('No hay datos disponibles.'));
            },
          ),
        ),
      ),
    );
  }

  Future<bool> _showExitConfirmation() async {
    return true; // Cambia esto según tu lógica
  }

  Widget _buildContent(BuildContext context, VehicleDetail vehicle) {
    return Column(
      children: [
        _buildCustomAppBar(context, vehicle),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildTopStatusCard(vehicle),
              const SizedBox(height: 24),
              _buildSectionTitle('Reportabilidad'),
              _buildDataRow('Último reporte', _formatDate(vehicle.lastReport)),
              const SizedBox(height: 12),
              _buildDataRow('Ubicación', _address ?? 'Obteniendo dirección...'),
              const SizedBox(height: 24),
              _buildSectionTitle('Seguridad'),
              _buildDataRow(
                  'Alimentación',
                  vehicle.batteryVolt != null
                      ? '${vehicle.batteryVolt} V'
                      : 'Sin datos'),
              const SizedBox(height: 12),
              _buildDataRow(
                  'Corte de combustible',
                  vehicle.fuelCutoff.isNotEmpty
                      ? vehicle.fuelCutoff
                      : 'Sin datos'),
              const SizedBox(height: 24),
              _buildSectionTitle('Accesorios'),
              _buildAccessoriesSection(),
              const SizedBox(height: 40),
              _buildActionButtons(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAccessoriesSection() {
    return FutureBuilder<VehicleAccessories?>(
      future: _accessoriesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return _buildDataRow('Estado', 'Error cargando accesorios');
        }

        if (!snapshot.hasData || snapshot.data!.accessories.isEmpty) {
          return _buildDataRow('Estado', 'Sin accesorios disponibles');
        }

        return _buildAccessoriesCard(snapshot.data!.accessories);
      },
    );
  }

  Widget _buildAccessoriesCard(Map<String, String> accessories) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
        side: BorderSide(color: Colors.grey.shade300, width: 1.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: accessories.entries.map((entry) {
            final isOpen = entry.value.toLowerCase().contains('abierta');
            final icon = isOpen ? Icons.lock_open : Icons.lock;
            final color = isOpen ? Colors.red : Colors.green;
            final isTemp = entry.value.toLowerCase().contains('temperatura');

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Icon(icon, color: isTemp ? Colors.blue : color, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: TextStyle(
                        color: isTemp
                            ? Colors.blue
                            : (isOpen ? Colors.red : Colors.black),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCustomAppBar(BuildContext context, VehicleDetail vehicle) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              _animationController.stop(); // Detener animación
              if (widget.onDataChanged != null) {
                widget.onDataChanged!();
              }
              Navigator.pop(context); // Navegación simple
            },
            child:
                Image.asset('assets/images/backbtn.png', width: 40, height: 40),
          ),
          Expanded(
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    vehicle.plate,
                    style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Image.asset('assets/images/icons_editar.png',
                        width: 25, height: 25, color: Colors.grey),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => EditMobileScreen(
                                  plate: vehicle.plate,
                                )),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildTopStatusCard(VehicleDetail vehicle) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
        side: BorderSide(color: Colors.grey.shade300, width: 1.0),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatusItem(Icons.location_on, 'Posición', vehicle.position),
            const SizedBox(height: 40, child: VerticalDivider()),
            _buildStatusItem(Icons.gps_fixed, 'Conexión', vehicle.connection),
            const SizedBox(height: 40, child: VerticalDivider()),
            _buildStatusItem(Icons.vpn_key, 'Estado', vehicle.status),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(IconData icon, String title, String status) {
    final bool isPositive = status.toLowerCase() == 'online' ||
        status.toLowerCase() == 'encendido' ||
        status.toLowerCase() == 'valida';
    final Color statusColor =
        isPositive ? Colors.green.shade700 : Colors.red.shade700;

    return Column(
      children: [
        Icon(icon, color: statusColor, size: 28),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title,
                style: const TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
            const SizedBox(width: 4),
            Icon(Icons.info_outline, color: Colors.grey.shade400, size: 14),
          ],
        ),
        const SizedBox(height: 4),
        Text(status,
            style: TextStyle(color: statusColor, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Expanded(
              child: Divider(color: AppColors.primaryIconos, thickness: 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          const Expanded(
              child: Divider(color: AppColors.primaryIconos, thickness: 1)),
        ],
      ),
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Colors.black, fontWeight: FontWeight.bold)),
          Flexible(
            child: Text(value,
                textAlign: TextAlign.end, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AuditDetailsScreen(
                          plate: widget.plate,
                        )),
              );
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: AppColors.primary, width: 1.5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0)),
            ),
            child: const Text('Auditoría',
                style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SecurityActionsScreen(
                          plate: widget.plate,
                        )),
              );
            },
            icon: const Icon(Icons.shield_outlined, color: Colors.white),
            label: const Text('Acciones de Seguridad',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0)),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return 'Sin reporte';
    }
    return DateFormat('yyyy-MM-dd HH:mm:ss', 'es_ES').format(date);
  }
}
