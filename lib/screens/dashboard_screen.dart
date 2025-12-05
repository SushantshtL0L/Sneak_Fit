import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SneakFit Dashboard"),
        backgroundColor: Colors.green,
        centerTitle: true, // optional: center the title
      ),
      body: const Center(
        child: Text(
          "Welcome to SneakFit Home!",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
