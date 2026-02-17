import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../view_model/auth_view_model.dart';
import '../../domain/usecases/register_usecase.dart';
import '../state/auth_state.dart';
import '../widgets/my_button.dart';
import '../widgets/my_textfield.dart';
import '../../../../core/utils/my_snack_bar.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  late final TextEditingController nameController;
  late final TextEditingController emailController;
  late final TextEditingController passController;
  late final TextEditingController confirmPassController;
  String _role = 'user'; 

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    emailController = TextEditingController();
    passController = TextEditingController();
    confirmPassController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passController.dispose();
    confirmPassController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passController.text.trim();
    final confirmPassword = confirmPassController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      showMySnackBar(
        context: context,
        message: "Please fill all fields",
        type: SnackBarType.warning,
      );
      return;
    }

    if (password != confirmPassword) {
      showMySnackBar(
        context: context,
        message: "Passwords do not match",
        type: SnackBarType.error,
      );
      return;
    }

    await ref.read(authViewModelProvider.notifier).register(
          RegisterUsecaseParams(
            name: name,
            userName: name, 
            email: email,
            password: password,
            confirmPassword: confirmPassword,
            phoneNumber: '',
            role: _role,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);

    // Listen for state changes
    ref.listen(authViewModelProvider, (previous, next) {
      if (next.status == AuthStatus.registered) {
        showMySnackBar(
          context: context,
          message: "Signup successful!",
          type: SnackBarType.success,
        );
        Navigator.pushReplacementNamed(context, '/login');
      } else if (next.status == AuthStatus.error) {
        showMySnackBar(
          context: context,
          message: next.errorMessage ?? "Signup failed",
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
                "Create Your Account",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),

              // Role Selection
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => setState(() => _role = 'user'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _role == 'user' ? Colors.green : Colors.grey[200],
                        foregroundColor: _role == 'user' ? Colors.white : Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text("Register as Buyer"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => setState(() => _role = 'seller'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _role == 'seller' ? Colors.green : Colors.grey[200],
                        foregroundColor: _role == 'seller' ? Colors.white : Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text("Register as Seller"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              MyTextField(hint: "Full Name", controller: nameController, prefixIcon: Icons.person),
              const SizedBox(height: 16),
              MyTextField(hint: "Email", controller: emailController, prefixIcon: Icons.email),
              const SizedBox(height: 16),
              MyTextField(hint: "Password", controller: passController, isPassword: true, prefixIcon: Icons.lock),
              const SizedBox(height: 16),
              MyTextField(hint: "Confirm Password", controller: confirmPassController, isPassword: true, prefixIcon: Icons.lock_outline),
              const SizedBox(height: 30),
              MyButton(
                text: "Sign Up",
                color: Colors.green,
                isLoading: authState.isAuthenticating,
                onPressed: _signup,
              ),
              const SizedBox(height: 20),
              Row(
                children: const [
                  Expanded(child: Divider(thickness: 1)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text("or continue with"),
                  ),
                  Expanded(child: Divider(thickness: 1)),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account? "),
                  GestureDetector(
                    onTap: () => Navigator.pushReplacementNamed(context, '/login'),
                    child: const Text(
                      "Login",
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
