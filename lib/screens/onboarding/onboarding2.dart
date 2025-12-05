import 'package:flutter/material.dart';

class Onboarding2 extends StatelessWidget {
  final VoidCallback onNext;
  const Onboarding2({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Center(
            child: Text(
              "Find your best style with SneakFit",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 30),
            ),
          ),

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
              child: const Text("Next", selectionColor: Colors.greenAccent,),
            ),
          )
        ],
      ),
    );
  }
}
