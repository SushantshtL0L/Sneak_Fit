import 'package:flutter/material.dart';

class Onboarding1 extends StatelessWidget {
  final VoidCallback onNext;
  const Onboarding1({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white, // change background if you want
      child: Stack(
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
                  "WELCOME TO SNEAKFIT",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    color: Colors.black
                  ),
                ),
              ],
            ),
          ),

          // NEXT BUTTON
          Positioned(
            right: 20,
            bottom: 70,
            height: 50,
            width: 150,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // CHANGE BUTTON COLOR HERE
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: onNext,
              child: const Text(
                "Next",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
