import 'package:flutter/material.dart';
import 'package:wisetrack_app/data/services/UserService.dart';
import 'package:wisetrack_app/ui/color/app_colors.dart';
import 'package:wisetrack_app/data/models/User/UserDetail.dart'; // Importa UserDetail

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // Controladores para los campos de texto
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _companyController;

  bool _isLoading = true; // Estado para mostrar el indicador de carga
  String? _errorMessage; // Para manejar errores
  UserDetail? _userDetail; // Para almacenar los datos del usuario

  @override
  void initState() {
    super.initState();
    // Inicializamos los controladores con valores vacíos
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _companyController = TextEditingController();

    // Cargar datos del usuario
    _loadUserData();
  }

  // Método para cargar los datos del usuario
  Future<void> _loadUserData() async {
    try {
      final userDetail = await UserService.getUserDetail();
      if (mounted) {
        setState(() {
          _userDetail = userDetail;
          _nameController.text = userDetail.fullName ?? '';
          _emailController.text = userDetail.username;
          _companyController.text = userDetail.company?.toString() ?? '';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
        // Manejar sesión expirada
        if (e.toString().contains('Session expired')) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed('/login');
          });
        }
      }
    }
  }

  @override
  void dispose() {
    // Desechar los controladores para liberar memoria
    _nameController.dispose();
    _emailController.dispose();
    _companyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        leading: _buildBackButton(context),
        title: const Text(
          'Perfil',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary))
              : _errorMessage != null
                  ? Center(child: Text(_errorMessage!))
                  : ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      children: [
                        const SizedBox(height: 20),
                        _buildProfilePicture(),
                        const SizedBox(height: 16),
                        const Center(
                          child: Text(
                            '38 móviles asociados',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                        const SizedBox(height: 30),
                        _buildTextField(
                            label: 'Nombre', controller: _nameController),
                        const SizedBox(height: 20),
                        _buildTextField(
                            label: 'Correo electrónico',
                            controller: _emailController),
                        const SizedBox(height: 20),
                        _buildTextField(
                            label: 'Empresa', controller: _companyController),
                        const SizedBox(height: 120), // Espacio para el botón
                      ],
                    ),
          _buildSaveChangesButton(),
        ],
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return IconButton(
      icon: Image.asset(
        'assets/images/backbtn.png',
        width: 40,
        height: 40,
      ),
      onPressed: () => Navigator.of(context).pop(),
    );
  }

  Widget _buildProfilePicture() {
    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=1'),
            backgroundColor: Color(0xFFE6E0F8),
          ),
          Positioned(
            bottom: -5,
            right: -5,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade700,
                shape: BoxShape.circle,
              ),
              child: const Padding(
                padding: EdgeInsets.all(6.0),
                child: Icon(Icons.edit, color: Colors.white, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
      {required String label, required TextEditingController controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveChangesButton() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        color: Colors.white,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _isLoading
              ? null
              : () async {
                  // Mostrar CircularProgressIndicator en un diálogo
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (dialogContext) {
                      return const Center(
                        child:
                            CircularProgressIndicator(color: AppColors.primary),
                      );
                    },
                  );

                  try {
                    // TODO: Implementar lógica para actualizar el perfil
                    // Por ejemplo, llamar a un método UserService.updateUserDetail
                    print('Guardando cambios:');
                    print('Nombre: ${_nameController.text}');
                    print('Email: ${_emailController.text}');
                    print('Empresa: ${_companyController.text}');

                    // Simular una petición (reemplazar con el endpoint real)
                    await Future.delayed(const Duration(seconds: 1));

                    // Cerrar el diálogo
                    Navigator.of(context).pop();

                    // Mostrar mensaje de éxito (opcional)
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Perfil actualizado correctamente')),
                    );

                    // Regresar a la pantalla anterior
                    Navigator.of(context).pop();
                  } catch (e) {
                    // Cerrar el diálogo
                    Navigator.of(context).pop();

                    // Mostrar error
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error al guardar cambios: $e')),
                    );
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            disabledBackgroundColor: AppColors.disabled,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          child: const Text(
            'Guardar cambios',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
