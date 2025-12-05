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
              style: TextStyle(fontSize: 30),
            ),
          ),

          Positioned(
            right: 20,
            bottom: 70,
            child: ElevatedButton(
              onPressed: onNext,
              child: const Text("Next", selectionColor: Colors.greenAccent,),
            ),
          )
        ],
      ),
    );
  }
}
