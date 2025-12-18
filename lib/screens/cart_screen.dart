import 'package:flutter/material.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cart")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.shopping_cart, size: 60, color: Colors.grey),
            SizedBox(height: 16),
            Text("Your cart is empty", style: TextStyle(fontSize: 20)),
          ],
        ),
      ),
    );
  }
}
