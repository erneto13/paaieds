import 'package:flutter/material.dart';
import 'package:paaieds/config/app_colors.dart';
import 'package:paaieds/core/models/forum_post.dart';
import 'package:paaieds/ui/widgets/forum/forum_attachment_selector.dart';

class CreatePostModal extends StatefulWidget {
  final Function(String title, String description, PostAttachment? attachment)
  onSubmit;

  const CreatePostModal({super.key, required this.onSubmit});

  @override
  State<CreatePostModal> createState() => _CreatePostModalState();
}

class _CreatePostModalState extends State<CreatePostModal> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  PostAttachment? _selectedAttachment;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa todos los campos'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    widget.onSubmit(title, description, _selectedAttachment);
  }

  void _handleAttachmentSelected(PostAttachment? attachment) {
    setState(() => _selectedAttachment = attachment);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHandle(),
              const SizedBox(height: 20),
              _buildHeader(),
              const SizedBox(height: 24),
              _buildTitleField(),
              const SizedBox(height: 16),
              _buildDescriptionField(),
              const SizedBox(height: 16),
              AttachmentSelector(
                selectedAttachment: _selectedAttachment,
                onAttachmentSelected: _handleAttachmentSelected,
              ),
              const SizedBox(height: 24),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.backgroundButtom.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.create,
            color: AppColors.backgroundButtom,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'Nueva Publicación',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Widget _buildTitleField() {
    return TextField(
      controller: _titleController,
      enabled: !_isSubmitting,
      style: TextStyle(color: Colors.grey[800]),
      decoration: InputDecoration(
        labelText: 'Título',
        hintText: 'Escribe un título llamativo',
        hintStyle: TextStyle(color: Colors.grey[400]),
        prefixIcon: Icon(Icons.title, color: AppColors.deepBlue),
        filled: true,
        fillColor: Colors.grey.withValues(alpha: 0.05),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: AppColors.highlight, width: 2),
        ),
      ),
    );
  }

  Widget _buildDescriptionField() {
    return TextField(
      controller: _descriptionController,
      enabled: !_isSubmitting,
      maxLines: 5,
      style: TextStyle(color: Colors.grey[800]),
      decoration: InputDecoration(
        labelText: 'Descripción',
        hintText: 'Describe tu pregunta o compartir conocimiento...',
        hintStyle: TextStyle(color: Colors.grey[400]),
        alignLabelWithHint: true,
        filled: true,
        fillColor: Colors.grey.withValues(alpha: 0.05),
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: AppColors.highlight, width: 2),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.backgroundButtom,
          disabledBackgroundColor: Colors.grey[300],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isSubmitting
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text(
                'Publicar',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
