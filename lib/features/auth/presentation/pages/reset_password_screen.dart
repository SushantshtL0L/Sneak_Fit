import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sneak_fit/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:sneak_fit/features/auth/presentation/state/auth_state.dart';
import 'package:sneak_fit/features/auth/presentation/widgets/my_button.dart';
import 'package:sneak_fit/features/auth/presentation/widgets/my_textfield.dart';
import 'package:sneak_fit/core/utils/my_snack_bar.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  final String email;
  const ResetPasswordScreen({super.key, required this.email});

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  late final TextEditingController tokenController;
  late final TextEditingController newPasswordController;
  late final TextEditingController confirmPasswordController;

  @override
  void initState() {
    super.initState();
    tokenController = TextEditingController();
    newPasswordController = TextEditingController();
    confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    tokenController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    final token = tokenController.text.trim();
    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (token.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      showMySnackBar(
        context: context,
        message: "Please fill all fields",
        type: SnackBarType.warning,
      );
      return;
    }

    if (newPassword != confirmPassword) {
      showMySnackBar(
        context: context,
        message: "Passwords do not match",
        type: SnackBarType.error,
      );
      return;
    }

    await ref.read(authViewModelProvider.notifier).resetPassword(token, newPassword);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);

    // Listen for state changes
    ref.listen(authViewModelProvider, (previous, next) {
      if (next.status == AuthStatus.passwordReset) {
        showMySnackBar(
          context: context,
          message: "Password reset successful! You can now login.",
          type: SnackBarType.success,
        );
        Navigator.popUntil(context, ModalRoute.withName('/login'));
      } else if (next.status == AuthStatus.error) {
        showMySnackBar(
          context: context,
          message: next.errorMessage ?? "Failed to reset password",
          type: SnackBarType.error,
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text("Reset Password"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Text(
                "Enter the 6-digit verification code sent to ${widget.email} and set your new password.",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 40),
              MyTextField(
                hint: "6-Digit Verification Code",
                controller: tokenController,
                prefixIcon: Icons.pin,
              ),
              const SizedBox(height: 16),
              MyTextField(
                hint: "New Password",
                controller: newPasswordController,
                isPassword: true,
                prefixIcon: Icons.lock,
              ),
              const SizedBox(height: 16),
              MyTextField(
                hint: "Confirm New Password",
                controller: confirmPasswordController,
                isPassword: true,
                prefixIcon: Icons.lock_outline,
              ),
              const SizedBox(height: 40),
              MyButton(
                text: "Reset Password",
                color: Colors.green,
                isLoading: authState.isAuthenticating,
                onPressed: _resetPassword,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
