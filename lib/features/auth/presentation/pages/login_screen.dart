import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../view_model/auth_view_model.dart';
import '../state/auth_state.dart';
import '../widgets/my_button.dart';
import '../widgets/my_textfield.dart';
import '../../../../core/utils/my_snack_bar.dart';
import '../../../../core/services/biometric_service.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late final TextEditingController emailController;
  late final TextEditingController passController;
  bool _biometricAvailable = false;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passController = TextEditingController();
    _checkBiometric();
  }

  Future<void> _checkBiometric() async {
    final service = ref.read(biometricServiceProvider);
    final isEnabled = await service.isBiometricLoginEnabled();
    final isAvailable = await service.isAvailable();
    if (mounted) {
      setState(() => _biometricAvailable = isEnabled && isAvailable);
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = emailController.text.trim();
    final password = passController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showMySnackBar(
        context: context,
        message: "Please fill all fields",
        type: SnackBarType.warning,
      );
      return;
    }

    await ref.read(authViewModelProvider.notifier).login(email, password);
  }

  Future<void> _loginWithBiometric() async {
    final service = ref.read(biometricServiceProvider);
    final authenticated = await service.authenticate(
      reason: 'Scan your fingerprint to login to Sneak Fit',
    );

    if (!authenticated) {
      if (!mounted) return;
      showMySnackBar(
        context: context,
        message: "Biometric authentication failed",
        type: SnackBarType.error,
      );
      return;
    }

    // Biometric passed — trigger getUserProfile which reads the stored token
    if (!mounted) return;
    await ref.read(authViewModelProvider.notifier).getUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);

    // Listen for state changes to handle navigation and snackbars
    ref.listen(authViewModelProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated) {
        showMySnackBar(
          context: context,
          message: "Login successful!",
          type: SnackBarType.success,
        );
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else if (next.status == AuthStatus.error) {
        showMySnackBar(
          context: context,
          message: next.errorMessage ?? "Invalid email or password",
          type: SnackBarType.error,
        );
      }
    });

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 120,
                child: Image.asset("assets/images/Logo.png", fit: BoxFit.contain),
              ),
              const SizedBox(height: 40),
              const Text(
                "Login to Your Account",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              MyTextField(hint: "Email", controller: emailController, prefixIcon: Icons.email),
              const SizedBox(height: 16),
              MyTextField(hint: "Password", controller: passController, isPassword: true, prefixIcon: Icons.lock),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/forgot-password'),
                  child: const Text(
                    "Forgot Password?",
                    style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              MyButton(
                text: "Login",
                color: Colors.green,
                isLoading: authState.isAuthenticating,
                onPressed: _login,
              ),

              // Fingerprint Login Button — only shows if user has enabled it
              if (_biometricAvailable) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text("or", style: TextStyle(color: Colors.grey[500])),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: _loginWithBiometric,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.green.withValues(alpha: 0.4)),
                      borderRadius: BorderRadius.circular(14),
                      color: Colors.green.withValues(alpha: 0.05),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.fingerprint, color: Colors.green, size: 28),
                        const SizedBox(width: 12),
                        const Text(
                          "Login with Fingerprint",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? "),
                  GestureDetector(
                    onTap: () => Navigator.pushReplacementNamed(context, '/signup'),
                    child: const Text(
                      "Sign Up",
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
