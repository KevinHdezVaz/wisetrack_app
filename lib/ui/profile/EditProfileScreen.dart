import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wisetrack_app/data/models/User/UserDetail.dart';
import 'package:wisetrack_app/data/services/UserService.dart';
import 'package:wisetrack_app/ui/color/app_colors.dart';
 import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;


class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // Controladores para mostrar los datos
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _companyController;

  // Estado de la pantalla
  File? _selectedImage;
  bool _isLoading = true;
  String? _errorMessage;
  UserDetailResponse? _userDetail;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _companyController = TextEditingController();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _companyController.dispose();
    super.dispose();
  }

  /// Carga los datos iniciales del usuario desde el servidor.
  Future<void> _loadUserData() async {
    try {
      final userDetail = await UserService.getUserDetail();
      if (mounted) {
        setState(() {
          _userDetail = userDetail;
          _nameController.text = userDetail.data.name;
          _emailController.text = userDetail.data.username;
          _companyController.text = userDetail.data.company.name;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Error al cargar datos: ${e.toString()}";
          _isLoading = false;
        });
      }
    }
  }
 
 Future<void> _showImagePickerOptions() async {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent, // Importante para que funcionen los bordes
    builder: (BuildContext context) {
      return Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.black),
                title: const Text('Elegir de la galería', 
                    style: TextStyle(color: Colors.black)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.photo_camera, color: Colors.black),
                title: const Text('Tomar una foto', 
                    style: TextStyle(color: Colors.black)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              SizedBox(
                height: MediaQuery.of(context).viewInsets.bottom,
              ),
            ],
          ),
        ),
      );
    },
  );
}

Future<void> _pickImage(ImageSource source) async {
  final ImagePicker picker = ImagePicker();
  final XFile? pickedFile = await picker.pickImage(source: source);

  if (pickedFile == null) return; // Si el usuario no elige nada, salimos.

  // --- INICIO DE LA COMPRESIÓN ---
  final originalFile = File(pickedFile.path);

  // Define una ruta temporal para guardar el archivo comprimido
  final tempDir = await getTemporaryDirectory();
  final targetPath = p.join(tempDir.path, "temp_profile.jpg");

  // Comprime el archivo y lo guarda en la nueva ruta
  final XFile? compressedFile = await FlutterImageCompress.compressAndGetFile(
    originalFile.absolute.path,
    targetPath,
    quality: 60, // Calidad de 0 a 100. Un valor entre 50-70 es ideal.
  );

  if (compressedFile != null && mounted) {
    setState(() {
      // Usamos la imagen COMPRIMIDA para la vista previa y para la subida
      _selectedImage = File(compressedFile.path);
    });
    // Logs para verificar la compresión
    print('Tamaño original: ${(originalFile.lengthSync() / 1024 / 1024).toStringAsFixed(2)} MB');
    print('Tamaño comprimido: ${(_selectedImage!.lengthSync() / 1024).toStringAsFixed(2)} KB');
  }
  // --- FIN DE LA COMPRESIÓN ---
}

Future<bool> _checkPermissions(ImageSource source) async {
  if (Platform.isIOS) {
    final status = await Permission.photos.status;
    if (source == ImageSource.camera) {
      return await Permission.camera.request().isGranted;
    } else {
      return await Permission.photos.request().isGranted;
    }
  }
  return true; // En Android no es necesario en la mayoría de casos
}

  /// Guarda los cambios enviando los datos al servidor.
  Future<void> _saveChanges() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No has seleccionado una nueva imagen')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );

    try {
      await UserService.updateUserProfile(
        username: _userDetail!.data.username,
        name: _userDetail!.data.name,
        company: _userDetail!.data.company.name,
        image: _selectedImage!,
        lastname: _userDetail!.data.lastname,
        phone: _userDetail!.data.phone,
      );

      Navigator.of(context).pop(); // Cierra el diálogo de carga
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado correctamente')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Image.asset('assets/images/backbtn.png', width: 40, height: 40),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Perfil',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          if (_isLoading)
            const Center(child: CircularProgressIndicator(color: AppColors.primary))
          else if (_errorMessage != null)
            Center(child: Text(_errorMessage!))
          else
            ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              children: [
                const SizedBox(height: 20),
                _buildProfilePicture(),
                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    '38 móviles asociados', // Este texto es estático por ahora
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 30),
                _buildTextField(label: 'Nombre', controller: _nameController),
                const SizedBox(height: 20),
                _buildTextField(label: 'Correo electrónico', controller: _emailController),
                const SizedBox(height: 20),
                _buildTextField(label: 'Empresa', controller: _companyController),
                const SizedBox(height: 120),
              ],
            ),
          // El botón solo aparece si no está cargando y no hay errores
          if (!_isLoading && _errorMessage == null)
            _buildSaveChangesButton(),
        ],
      ),
    );
  }

  Widget _buildProfilePicture() {
    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          GestureDetector(
            onTap: _showImagePickerOptions,
            child: _buildProfileImage(),
          ),
          Positioned(
            bottom: -5,
            right: -5,
            child: GestureDetector(
              onTap: _showImagePickerOptions,
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
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    // Si hay una imagen seleccionada, muéstrala desde el archivo local.
    if (_selectedImage != null) {
      return CircleAvatar(
        radius: 50,
        backgroundImage: FileImage(_selectedImage!),
      );
    }
    // Si no, muestra la imagen de la red o un ícono por defecto.
    return CircleAvatar(
      radius: 50,
      backgroundColor: const Color(0xFFE6E0F8),
      backgroundImage: _userDetail?.data.userImage != null
          ? NetworkImage(_userDetail!.data.userImage)
          : null,
      child: _userDetail?.data.userImage == null
          ? const Icon(Icons.person, size: 50, color: Colors.white)
          : null,
    );
  }

  Widget _buildTextField({required String label, required TextEditingController controller}) {
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
          readOnly: true, // Hace que el campo no se pueda editar
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade100, // Color para indicar que es de solo lectura
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide.none,
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
      padding: const EdgeInsets.fromLTRB(40, 0, 40, 50),
      color: Colors.white,
      width: double.infinity,
      child: ElevatedButton(
        // --- CAMBIO AQUÍ ---
        // El botón solo estará habilitado si `_selectedImage` NO es nulo y
        // la pantalla NO está cargando.
        onPressed: (_selectedImage != null && !_isLoading) ? _saveChanges : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          // El color para cuando está deshabilitado se aplicará automáticamente
          disabledBackgroundColor: Colors.grey.shade300,
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