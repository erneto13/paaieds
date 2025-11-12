import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:paaieds/core/providers/auth_provider.dart';
import 'package:paaieds/ui/widgets/util/confirm_dialog.dart';
import 'package:provider/provider.dart';
import 'package:paaieds/config/app_colors.dart';
import 'package:paaieds/ui/widgets/util/custom_app_bar.dart';
import 'package:paaieds/ui/widgets/util/custom_text_field.dart';
import 'package:paaieds/ui/widgets/util/snackbar.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SettingsScreen extends StatefulWidget {
  final Function(int) onNavBarTap;
  final int currentIndex;

  const SettingsScreen({
    super.key,
    required this.onNavBarTap,
    required this.currentIndex,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _profileImage;
  bool _isEditing = false;

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    _firstNameController = TextEditingController(text: user?.firstName ?? '');
    _lastNameController = TextEditingController(text: user?.lastName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
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
      if (!mounted) return;

      CustomSnackbar.showError(
        context: context,
        message: 'Error al seleccionar imagen',
        description: 'No se pudo cargar la imagen seleccionada',
      );
    }
  }

  Future<void> _saveProfile() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();

    if (firstName.isEmpty || lastName.isEmpty) {
      CustomSnackbar.showError(
        context: context,
        message: 'Campos incompletos',
        description: 'Por favor completa todos los campos',
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.updateProfile(
      firstName: firstName,
      lastName: lastName,
      profileImage: _profileImage,
    );

    if (!mounted) return;

    if (success) {
      setState(() {
        _isEditing = false;
        _profileImage = null;
      });
      CustomSnackbar.showSuccess(
        context: context,
        message: 'Perfil actualizado',
        description: 'Tu información se ha actualizado correctamente',
      );
    } else {
      CustomSnackbar.showError(
        context: context,
        message: 'Error al actualizar',
        description: authProvider.errorMessage ?? 'Intenta más tarde',
      );
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => MinimalConfirmDialog(
        title: 'Cerrar sesión',
        content: '¿Estás seguro de que deseas cerrar sesión?',
        onConfirm: () {
          Navigator.pop(context, true);
        },
      ),
    );

    if (!mounted) return;

    if (confirm == true) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      CustomSnackbar.showInfo(
        context: context,
        message: 'Cerrando sesión...',
        description: 'Hasta pronto',
      );

      await Future.delayed(const Duration(milliseconds: 500));
      await authProvider.signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final currentUser = authProvider.currentUser;

        return Scaffold(
          appBar: CustomAppBar(
            title: "Ajustes",
            isIcon: false,
            customIcon: Icons.arrow_back,
            onCustomIconTap: () => Navigator.pop(context),
          ),
          backgroundColor: Colors.white,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileSection(currentUser),
                  const SizedBox(height: 30),
                  if (_isEditing) ...[
                    _buildEditForm(authProvider.isLoading),
                    const SizedBox(height: 20),
                    _buildActionButtons(authProvider.isLoading, currentUser),
                  ] else ...[
                    _buildInfoSection(currentUser),
                    const SizedBox(height: 30),
                    _buildSettingsOptions(),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// 🧑‍💼 Nueva versión tipo "perfil de red social"
  Widget _buildProfileSection(dynamic currentUser) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Stack(
          children: [
            _buildProfileImage(currentUser),
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
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                currentUser?.displayName ?? 'Usuario',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.deepBlue,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                currentUser?.email ?? '',
                style: TextStyle(fontSize: 15, color: Colors.grey[700]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileImage(dynamic currentUser) {
    if (_profileImage != null) {
      return CircleAvatar(
        radius: 55,
        backgroundImage: FileImage(_profileImage!),
      );
    }

    if (currentUser?.photoURL != null && currentUser!.photoURL!.isNotEmpty) {
      return CircleAvatar(
        radius: 55,
        backgroundColor: AppColors.lightBlue.withValues(alpha: 0.3),
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: currentUser.photoURL!,
            width: 110,
            height: 110,
            fit: BoxFit.cover,
            placeholder: (context, url) => const CircularProgressIndicator(),
            errorWidget: (context, url, error) =>
                Icon(Icons.person, size: 55, color: AppColors.deepBlue),
          ),
        ),
      );
    }

    return CircleAvatar(
      radius: 55,
      backgroundColor: AppColors.lightBlue.withValues(alpha: 0.3),
      child: Icon(Icons.person, size: 55, color: AppColors.deepBlue),
    );
  }

  Widget _buildEditForm(bool isSaving) {
    return Column(
      children: [
        CustomTextField(
          controller: _firstNameController,
          hintText: 'Nombre',
          icon: Icons.person_outline,
          enabled: !isSaving,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _lastNameController,
          hintText: 'Apellido',
          icon: Icons.person_outline,
          enabled: !isSaving,
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

  Widget _buildActionButtons(bool isSaving, dynamic currentUser) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: isSaving
                ? null
                : () {
                    setState(() {
                      _isEditing = false;
                      _profileImage = null;
                      _firstNameController.text = currentUser?.firstName ?? '';
                      _lastNameController.text = currentUser?.lastName ?? '';
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
            onPressed: isSaving ? null : _saveProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: isSaving
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

  Widget _buildInfoSection(dynamic currentUser) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB), // Fondo gris claro y suave
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(
            icon: Icons.person,
            label: 'Nombre completo',
            value: currentUser?.displayName ?? 'N/A',
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: Icons.email,
            label: 'Correo electrónico',
            value: currentUser?.email ?? 'N/A',
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: Icons.verified_user,
            label: 'Proveedor',
            value: currentUser?.authProvider == 'email'
                ? 'Correo electrónico'
                : currentUser?.authProvider ?? 'N/A',
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
        _buildOptionItem(
          icon: Icons.edit,
          title: 'Editar perfil',
          subtitle: 'Actualiza tu información personal',
          onTap: () => setState(() => _isEditing = true),
          color: AppColors.oceanBlue,
        ),
        const SizedBox(height: 20),
        _buildCreditsSection(),
        const SizedBox(height: 30),
        _buildOptionItem(
          icon: Icons.logout,
          title: 'Cerrar sesión',
          subtitle: 'Salir de tu cuenta',
          onTap: _handleLogout,
          color: Colors.redAccent,
          isDestructive: true,
        ),
      ],
    );
  }

  Widget _buildOptionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color color,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
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
                      color: isDestructive
                          ? Colors.redAccent
                          : AppColors.deepBlue,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                      height: 1.2,
                    ),
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

  Widget _buildCreditsSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.lightBlue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          SizedBox(height: 8),
          Text(
            'Hecho con ❤️ por el equipo de PAAIEDS',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF4B5563),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4),
          Text(
            'Versión 1.0.0',
            style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
          ),
        ],
      ),
    );
  }
}
