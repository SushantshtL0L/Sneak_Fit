import 'package:flutter/material.dart';
import '../../../../widgets/my_button.dart';
import '../../../../widgets/my_textfield.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passController = TextEditingController();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo
              SizedBox(
                height: 120,
                child: Image.asset(
                  "assets/images/Logo.png",
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 40),

              // Title
              const Text(
                "Login to Your Account",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),

              // Email Field
              MyTextField(
                hint: "Email",
                controller: emailController,
                prefixIcon: Icons.email,
              ),
              const SizedBox(height: 16),

              // Password Field
              MyTextField(
                hint: "Password",
                controller: passController,
                isPassword: true,
                prefixIcon: Icons.lock,
              ),
              const SizedBox(height: 30),

              // Login Button with validation
              MyButton(
                text: "Log In",
                onPressed: () {
                  if (emailController.text.isEmpty || passController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please enter email and password")),
                    );
                  } else {
                    Navigator.pushReplacementNamed(context, '/dashboard');
                  }
                },
                color: Colors.green,
              ),

              const SizedBox(height: 20),

              // OR separator
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

              // Sign up text
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Doesn't have an account? "),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/signup');
                    },
                    child: const Text(
                      "Sign up",
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
