import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:paaieds/config/app_colors.dart';
import 'package:paaieds/core/models/user.dart';
import 'package:paaieds/core/services/auth_service.dart';
import 'package:paaieds/core/services/user_service.dart';
import 'package:paaieds/ui/screens/auth/login_screen.dart';
import 'package:paaieds/ui/widgets/custom_app_bar.dart';
import 'package:paaieds/ui/widgets/custom_bottom_bar.dart';
import 'package:paaieds/ui/widgets/custom_text_field.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SettingsScreen extends StatefulWidget {
  final UserModel user;
  final Function(int) onNavBarTap;
  final int currentIndex;

  const SettingsScreen({
    super.key,
    required this.user,
    required this.onNavBarTap,
    required this.currentIndex,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  final ImagePicker _picker = ImagePicker();

  File? _profileImage;
  bool _isEditing = false;
  bool _isSaving = false;
  UserModel? _currentUser;

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
    _firstNameController = TextEditingController(text: widget.user.firstName);
    _lastNameController = TextEditingController(text: widget.user.lastName);
    _emailController = TextEditingController(text: widget.user.email);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (image != null) {
        setState(() {
          _profileImage = File(image.path);
        });
      }
    } catch (e) {
      _showSnackBar('Error al seleccionar imagen', isError: true);
    }
  }

  Future<void> _saveProfile() async {
    if (_isSaving) return;

    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();

    if (firstName.isEmpty || lastName.isEmpty) {
      _showSnackBar('Por favor completa todos los campos', isError: true);
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Actualizar perfil en Firestore
      final updatedUser = await _userService.updateUserProfile(
        uid: _currentUser!.uid,
        firstName: firstName,
        lastName: lastName,
        profileImage: _profileImage,
      );

      if (updatedUser != null) {
        setState(() {
          _currentUser = updatedUser;
          _isEditing = false;
          _profileImage = null;
        });
        _showSnackBar('Perfil actualizado exitosamente');
      } else {
        _showSnackBar('Error al actualizar perfil', isError: true);
      }
    } catch (e) {
      _showSnackBar('Error al guardar: ${e.toString()}', isError: true);
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _showChangePasswordDialog() async {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cambiar contraseña'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Contraseña actual',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Nueva contraseña',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirmar nueva contraseña',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final current = currentPasswordController.text;
              final newPass = newPasswordController.text;
              final confirm = confirmPasswordController.text;

              if (current.isEmpty || newPass.isEmpty || confirm.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Completa todos los campos'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              if (newPass.length < 6) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'La contraseña debe tener al menos 6 caracteres',
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              if (newPass != confirm) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Las contraseñas no coinciden'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              Navigator.pop(context, true);
            },
            child: const Text('Cambiar'),
          ),
        ],
      ),
    );

    if (result == true) {
      final success = await _userService.changePassword(
        currentPassword: currentPasswordController.text,
        newPassword: newPasswordController.text,
      );

      if (!mounted) return;

      if (success) {
        _showSnackBar('Contraseña actualizada exitosamente');
      } else {
        _showSnackBar(
          'Error al cambiar contraseña. Verifica tu contraseña actual',
          isError: true,
        );
      }
    }

    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _authService.signOut();
      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Ajustes", onProfileTap: () {}),
      backgroundColor: Colors.white10,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              _buildProfileSection(),
              const SizedBox(height: 30),
              if (_isEditing) ...[
                _buildEditForm(),
                const SizedBox(height: 20),
                _buildActionButtons(),
              ] else ...[
                _buildInfoSection(),
                const SizedBox(height: 30),
                _buildSettingsOptions(),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: widget.currentIndex,
        onTap: widget.onNavBarTap,
      ),
    );
  }

  Widget _buildProfileSection() {
    return Column(
      children: [
        Stack(
          children: [
            _buildProfileImage(),
            if (_isEditing)
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          _currentUser?.displayName ?? '',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.deepBlue,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _currentUser?.email ?? '',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildProfileImage() {
    // Si hay una imagen seleccionada localmente
    if (_profileImage != null) {
      return CircleAvatar(
        radius: 60,
        backgroundImage: FileImage(_profileImage!),
      );
    }

    // Si el usuario tiene una foto en Firestore
    if (_currentUser?.photoURL != null && _currentUser!.photoURL!.isNotEmpty) {
      return CircleAvatar(
        radius: 60,
        backgroundColor: AppColors.lightBlue.withValues(alpha: 0.3),
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: _currentUser!.photoURL!,
            width: 120,
            height: 120,
            fit: BoxFit.cover,
            placeholder: (context, url) => const CircularProgressIndicator(),
            errorWidget: (context, url, error) =>
                Icon(Icons.person, size: 60, color: AppColors.deepBlue),
          ),
        ),
      );
    }

    // Avatar por defecto
    return CircleAvatar(
      radius: 60,
      backgroundColor: AppColors.lightBlue.withValues(alpha: 0.3),
      child: Icon(Icons.person, size: 60, color: AppColors.deepBlue),
    );
  }

  Widget _buildEditForm() {
    return Column(
      children: [
        CustomTextField(
          controller: _firstNameController,
          hintText: 'Nombre',
          icon: Icons.person_outline,
          enabled: !_isSaving,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _lastNameController,
          hintText: 'Apellido',
          icon: Icons.person_outline,
          enabled: !_isSaving,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _emailController,
          hintText: 'Correo electrónico',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          enabled: false,
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isSaving
                ? null
                : () {
                    setState(() {
                      _isEditing = false;
                      _profileImage = null;
                      _firstNameController.text = _currentUser!.firstName;
                      _lastNameController.text = _currentUser!.lastName;
                    });
                  },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey[700],
              side: BorderSide(color: Colors.grey[400]!),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Cancelar'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _isSaving ? null : _saveProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isSaving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Guardar',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightBlue.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            icon: Icons.person,
            label: 'Nombre completo',
            value: _currentUser?.displayName ?? '',
          ),
          const Divider(height: 24),
          _buildInfoRow(
            icon: Icons.email,
            label: 'Correo electrónico',
            value: _currentUser?.email ?? '',
          ),
          const Divider(height: 24),
          _buildInfoRow(
            icon: Icons.verified_user,
            label: 'Proveedor',
            value: _currentUser?.authProvider == 'email'
                ? 'Correo electrónico'
                : _currentUser?.authProvider ?? '',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppColors.deepBlue, size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsOptions() {
    return Column(
      children: [
        _buildOptionCard(
          icon: Icons.edit,
          title: 'Editar perfil',
          subtitle: 'Actualiza tu información personal',
          onTap: () => setState(() => _isEditing = true),
          color: AppColors.oceanBlue,
        ),
        const SizedBox(height: 12),
        _buildOptionCard(
          icon: Icons.lock_outline,
          title: 'Cambiar contraseña',
          subtitle: 'Actualiza tu contraseña',
          onTap: _showChangePasswordDialog,
          color: AppColors.skyBlue,
        ),
        const SizedBox(height: 24),
        _buildOptionCard(
          icon: Icons.logout,
          title: 'Cerrar sesión',
          subtitle: 'Salir de tu cuenta',
          onTap: _handleLogout,
          color: Colors.red,
          isDestructive: true,
        ),
      ],
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color color,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDestructive
                ? Colors.red.withValues(alpha: 0.3)
                : AppColors.lightBlue.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDestructive ? Colors.red : Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
