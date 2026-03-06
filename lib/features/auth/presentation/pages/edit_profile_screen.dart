// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sneak_fit/core/api/api_endpoints.dart';
import 'package:sneak_fit/core/utils/my_snack_bar.dart';
import 'package:sneak_fit/features/auth/presentation/state/auth_state.dart';
import 'package:sneak_fit/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:sneak_fit/features/auth/presentation/widgets/my_textfield.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  File? _image;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final user = ref.read(authViewModelProvider).authEntity;
    if (user != null) {
      _nameController.text = user.name ?? '';
      _emailController.text = user.email;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Profile Photo",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _pickerItem(Icons.camera_alt, "Camera", Colors.blue, () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                }),
                _pickerItem(Icons.photo_library, "Gallery", Colors.purple, () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                }),
                if (ref.read(authViewModelProvider).authEntity?.profileImage != null)
                  _pickerItem(Icons.delete, "Remove", Colors.red, () {
                    Navigator.pop(context);
                    // Handle image removal logic if needed
                  }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _pickerItem(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 30, color: color),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final user = authState.authEntity;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final String? networkImageUrl = user?.profileImage != null
        ? "${ApiEndpoints.baseImageUrl}${user?.profileImage}"
        : null;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        title: const Text("Edit Profile", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Profile Picture Section
            Center(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF23D19D), width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF23D19D).withValues(alpha: 0.2),
                          blurRadius: 20,
                          spreadRadius: 2,
                        )
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 70,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: _image != null
                          ? FileImage(_image!)
                          : (networkImageUrl != null
                              ? CachedNetworkImageProvider(networkImageUrl)
                              : null) as ImageProvider?,
                      child: (_image == null && networkImageUrl == null)
                          ? const Icon(Icons.person, size: 70, color: Colors.grey)
                          : null,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 4,
                    child: GestureDetector(
                      onTap: _showImagePicker,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: Color(0xFF23D19D),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_enhance, size: 24, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Form Fields
            _buildFieldLabel("Full Name", isDark),
            MyTextField(
              hint: "Enter your full name",
              controller: _nameController,
              prefixIcon: Icons.person_outline,
            ),
            const SizedBox(height: 20),

            const SizedBox(height: 20),

            _buildFieldLabel("Email Address", isDark),
            AbsorbPointer(
              child: Opacity(
                opacity: 0.6,
                child: MyTextField(
                  hint: "Email (Cannot be changed)",
                  controller: _emailController,
                  prefixIcon: Icons.email_outlined,
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Action Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF23D19D),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                ),
                onPressed: authState.status == AuthStatus.loading
                    ? null
                    : () async {
                        await ref.read(authViewModelProvider.notifier).updateProfile(
                              _nameController.text.trim(),
                              _image?.path,
                            );
                        
                        if (mounted) {
                          final currentState = ref.read(authViewModelProvider);
                          if (currentState.status == AuthStatus.authenticated) {
                            if (mounted) {
                              showMySnackBar(
                                // ignore: duplicate_ignore
                                // ignore: use_build_context_synchronously
                                context: context,
                                message: "Profile updated successfully!",
                                type: SnackBarType.success,
                              );
                              Navigator.pop(context);
                            }
                          } else {
                            if (mounted) {
                              showMySnackBar(
                                context: context,
                                message: currentState.errorMessage ?? "Update failed",
                                type: SnackBarType.error,
                              );
                            }
                          }
                        }
                      },
                child: authState.status == AuthStatus.loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Update Profile",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
      ),
    );
  }
}
