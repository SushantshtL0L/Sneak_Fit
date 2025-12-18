import 'package:flutter/material.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Orders")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.receipt_long, size: 60, color: Colors.grey),
            SizedBox(height: 16),
            Text("You have no orders yet", style: TextStyle(

              fontSize: 20)),
          ],
        ),
      ),
    );
  }
}
