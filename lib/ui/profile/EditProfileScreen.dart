import 'package:flutter/material.dart';
import 'package:wisetrack_app/ui/color/app_colors.dart';

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

  @override
  void initState() {
    super.initState();
    // Inicializamos los controladores con los datos del perfil
    _nameController = TextEditingController(text: 'Francisca Sepúlveda');
    _emailController = TextEditingController(text: 'fsepulveda@addyra.com');
    _companyController = TextEditingController(text: 'Addyra Consultoría');
  }

  @override
  void dispose() {
    // Es importante desechar los controladores para liberar memoria
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
          ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            children: [
              const SizedBox(height: 20),
              _buildProfilePicture(),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  '38 móviles asociados',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              const SizedBox(height: 30),
              _buildTextField(label: 'Nombre', controller: _nameController),
              const SizedBox(height: 20),
              _buildTextField(
                  label: 'Correo electrónico', controller: _emailController),
              const SizedBox(height: 20),
              _buildTextField(label: 'Empresa', controller: _companyController),
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
        'assets/images/backbtn.png', // Reutilizando el botón de regreso
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
            backgroundImage:
                NetworkImage('https://i.pravatar.cc/150?img=1'), // Placeholder
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
        color: Colors.white, // Fondo para que el contenido no se vea por debajo
        width: double.infinity,
        child: ElevatedButton(
          // Por defecto está desactivado como en la imagen
          onPressed: null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            disabledBackgroundColor: AppColors.disabled,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
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
