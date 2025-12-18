import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.person_outline, size: 60, color: Colors.grey),
            SizedBox(height: 16),
            Text("Your profile info", style: TextStyle(fontSize: 20)),
          ],
        ),
      ),
    );
  }
}
