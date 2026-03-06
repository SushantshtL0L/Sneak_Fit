import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sneak_fit/core/utils/my_snack_bar.dart';
import 'package:sneak_fit/features/auth/presentation/state/auth_state.dart';
import 'package:sneak_fit/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:sneak_fit/features/auth/presentation/widgets/my_textfield.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handlePasswordChange() async {
    final oldPass = _oldPasswordController.text;
    final newPass = _newPasswordController.text;
    final confirmPass = _confirmPasswordController.text;

    if (oldPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
      showMySnackBar(
        context: context,
        message: "All fields are required",
        type: SnackBarType.error,
      );
      return;
    }

    if (newPass != confirmPass) {
      showMySnackBar(
        context: context,
        message: "New passwords do not match",
        type: SnackBarType.error,
      );
      return;
    }

    if (newPass.length < 6) {
      showMySnackBar(
        context: context,
        message: "Password must be at least 6 characters",
        type: SnackBarType.error,
      );
      return;
    }

    final success = await ref.read(authViewModelProvider.notifier).changePassword(
      oldPass,
      newPass,
    );

    if (mounted) {
      if (success) {
        showMySnackBar(
          context: context,
          message: "Password changed successfully!",
          type: SnackBarType.success,
        );
        Navigator.pop(context);
      } else {
        final error = ref.read(authViewModelProvider).errorMessage;
        showMySnackBar(
          context: context,
          message: error ?? "Failed to change password",
          type: SnackBarType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = ref.watch(authViewModelProvider);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        title: const Text("Change Password", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE01E37).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_reset_rounded,
                    size: 80,
                    color: Color(0xFFE01E37),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              
              _buildFieldLabel("Current Password", isDark),
              MyTextField(
                hint: "Enter current password",
                controller: _oldPasswordController,
                isPassword: true,
                prefixIcon: Icons.lock_outline,
              ),
              const SizedBox(height: 24),

              _buildFieldLabel("New Password", isDark),
              MyTextField(
                hint: "Enter new password",
                controller: _newPasswordController,
                isPassword: true,
                prefixIcon: Icons.vpn_key_outlined,
              ),
              const SizedBox(height: 24),

              _buildFieldLabel("Confirm New Password", isDark),
              MyTextField(
                hint: "Confirm your new password",
                controller: _confirmPasswordController,
                isPassword: true,
                prefixIcon: Icons.check_circle_outline,
              ),
              
              const SizedBox(height: 48),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE01E37),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                  ),
                  onPressed: authState.status == AuthStatus.loading ? null : _handlePasswordChange,
                  child: authState.status == AuthStatus.loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Update Password",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  "We'll log you out of other sessions for security.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white70 : Colors.black54,
        ),
      ),
    );
  }
}
