import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sneak_fit/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:sneak_fit/features/auth/presentation/state/auth_state.dart';
import 'package:sneak_fit/features/auth/presentation/widgets/my_button.dart';
import 'package:sneak_fit/features/auth/presentation/widgets/my_textfield.dart';
import 'package:sneak_fit/core/utils/my_snack_bar.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  late final TextEditingController emailController;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetLink() async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      showMySnackBar(
        context: context,
        message: "Please enter your email",
        type: SnackBarType.warning,
      );
      return;
    }

    await ref.read(authViewModelProvider.notifier).forgotPassword(email);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);

    // Listen for state changes
    ref.listen(authViewModelProvider, (previous, next) {
      if (next.status == AuthStatus.forgotPasswordSent) {
        showMySnackBar(
          context: context,
          message: "Reset link sent! Please check your email.",
          type: SnackBarType.success,
        );
        // Navigate to Reset Password screen
        Navigator.pushNamed(context, '/reset-password', arguments: emailController.text.trim());
      } else if (next.status == AuthStatus.error) {
        showMySnackBar(
          context: context,
          message: next.errorMessage ?? "Failed to send reset link",
          type: SnackBarType.error,
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text("Forgot Password"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const Icon(Icons.lock_reset, size: 80, color: Colors.green),
              const SizedBox(height: 40),
              const Text(
                "Enter your email address and we'll send you a link to reset your password.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 40),
              MyTextField(
                hint: "Email",
                controller: emailController,
                prefixIcon: Icons.email,
              ),
              const SizedBox(height: 40),
              MyButton(
                text: "Send Reset Link",
                color: Colors.green,
                isLoading: authState.isAuthenticating,
                onPressed: _sendResetLink,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
