import 'package:flutter/material.dart';

class Onboarding3 extends StatelessWidget {
  final VoidCallback onNext;
  const Onboarding3({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDFFFEA), // mint background
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // LOGO
                SizedBox(
                  height: 180,
                  child: Image.asset(
                    "assets/images/Logo.png",
                    fit: BoxFit.contain,
                  ),
                ),

                const SizedBox(height: 30),

                const Text(
                  "Best New and Thrift Shoes",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // GET STARTED BUTTON
          Positioned(
            right: 20,
            bottom: 70,
            height: 50,
            width: 160,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: onNext,
              child: const Text(
                "Get Started",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          )
        ],
      ),
    );
  }
}
