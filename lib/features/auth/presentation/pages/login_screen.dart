import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/local/auth_local_datasource.dart';
import '../widgets/my_button.dart';
import '../widgets/my_textfield.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late final TextEditingController emailController;
  late final TextEditingController passController;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passController = TextEditingController();
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    final authDatasource = ref.read(authLocalDatasourceProvider);
    final user = await authDatasource.login(email, password);

    if (user != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login successful!")),
      );
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid email or password")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
              const SizedBox(height: 30),
              MyButton(
                text: "Login",
                color: Colors.green,
                onPressed: _login,
              ),
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
