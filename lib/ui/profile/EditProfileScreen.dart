import 'dart:io';
import 'package:flutter/material.dart';
import 'package:wisetrack_app/data/models/User/UserDetail.dart';
import 'package:wisetrack_app/data/services/UserService.dart';
import 'package:wisetrack_app/ui/color/app_colors.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _companyController;
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
          _errorMessage = e.toString();
          _isLoading = false;
        });
        if (e.toString().contains('Session expired')) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed('/login');
          });
        }
      }
    }
  }

  Future<void> _updateProfile() async {
    if (_userDetail == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );

    try {
      final nameParts = _nameController.text.split(' ');
      final firstName = nameParts.first;
      final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : null;

      final updatedUser = await UserService.updateUserProfile(
        username: _emailController.text,
        name: firstName,
        company: _companyController.text,
        image: _selectedImage ?? File(_userDetail!.data.userImage),
        lastname: lastName,
        phone: _userDetail?.data.phone,
      );

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado correctamente')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _pickImage() async {
    // Implementar lógica para seleccionar imagen
    // Ejemplo con image_picker:
    // final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    // if (pickedFile != null) {
    //   setState(() {
    //     _selectedImage = File(pickedFile.path);
    //   });
    // }
  }

  @override
  void dispose() {
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
          _isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
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
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                        const SizedBox(height: 30),
                        _buildTextField(label: 'Nombre', controller: _nameController),
                        const SizedBox(height: 20),
                        _buildTextField(
                            label: 'Correo electrónico', controller: _emailController),
                        const SizedBox(height: 20),
                        _buildTextField(
                            label: 'Empresa', controller: _companyController),
                        const SizedBox(height: 120),  
                      ],
                    ),
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
        _buildProfileImage(),
        Positioned(
          bottom: -5,
          right: -5,
          child: GestureDetector(
            onTap: _pickImage,
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
  if (_selectedImage != null) {
    return CircleAvatar(
      radius: 50,
      backgroundImage: FileImage(_selectedImage!),
      backgroundColor: const Color(0xFFE6E0F8),
    );
  }

  return CircleAvatar(
    radius: 50,
    backgroundColor: const Color(0xFFE6E0F8),
    child: ClipOval(
      child: Image.network(
        _userDetail?.data.userImage ?? 'https://i.pravatar.cc/150?img=1',
        fit: BoxFit.cover,
        width: 100,
        height: 100,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.person, size: 50, color: Colors.white);
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const CircularProgressIndicator(color: AppColors.primary);
        },
      ),
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
          onPressed: _isLoading ? null : _updateProfile,
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