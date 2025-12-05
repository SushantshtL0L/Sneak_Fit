import 'package:flutter/material.dart';
import '../../widgets/my_button.dart';
import '../../widgets/my_textfield.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passController = TextEditingController();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo (same as login)
              SizedBox(
                height: 120,
                child: Image.asset(
                  "assets/images/Logo.png",
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 40),

              // Title (same style as login)
              const Text(
                "Create Your Account",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),

              // Full Name
              MyTextField(
                hint: "Full Name",
                controller: nameController,
                prefixIcon: Icons.person,
              ),
              const SizedBox(height: 16),

              MyTextField(
                hint: "Phone Number",
                controller: nameController,
                prefixIcon: Icons.phone,
              ),
              const SizedBox(height: 16),

              // Email
              MyTextField(
                hint: "Email",
                controller: emailController,
                prefixIcon: Icons.email,
              ),
              const SizedBox(height: 16),

              // Password
              MyTextField(
                hint: "Password",
                controller: passController,
                isPassword: true,
                prefixIcon: Icons.lock,
              ),
              const SizedBox(height: 30),

              // Sign Up Button
              MyButton(
                text: "Sign Up",
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/home');
                },
                color: Colors.green,
              ),

              const SizedBox(height: 20),

              // OR separator (same as login screen)
              Row(
                children: const [
                  Expanded(child: Divider(thickness: 1)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text("or continue with"),
                  ),
                  Expanded(child: Divider(thickness: 1)),
                ],
              ),

              const SizedBox(height: 20),

              // Already have an account? -> Login
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account? "),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: const Text(
                      "Login",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
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
