import 'package:flutter/material.dart';

class Onboarding1 extends StatelessWidget {
  final VoidCallback onNext;
  const Onboarding1({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue[100], 
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                SizedBox(height: 20),
                Text(
                  "Welcome to SneakFit",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 20,
            bottom: 70,
            child: ElevatedButton(
              onPressed: onNext,
              child: const Text("Next"),
            ),
          ),
        ],
      ),
    );
  }
}
