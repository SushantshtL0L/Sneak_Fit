import 'package:flutter/material.dart';

class Onboarding2 extends StatelessWidget {
  final VoidCallback onNext;
  const Onboarding2({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDFFFEA), // Mint background color
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

                const SizedBox(height: 50),

                Text(
                  "Find your best style with SneakFit",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'OpenSans',     
                    fontWeight: FontWeight.bold, 
                    fontSize: 35,
                    color: Colors.black,
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
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: onNext,
              child: const Text(
                "Next",
                style: TextStyle(
                  fontFamily: 'OpenSans',       
                  fontWeight: FontWeight.w400, 
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
