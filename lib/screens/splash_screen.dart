import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sneak_fit/core/storage/user_session_service.dart';
import 'package:sneak_fit/screens/onboarding/onboarding_main.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _timer = Timer(const Duration(seconds: 2), () {
        if (!mounted) return;

        final sessionService = ref.read(userSessionServiceProvider);
        
        if (sessionService.isLoggedIn()) {
          Navigator.pushReplacementNamed(context, '/dashboard');
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const OnboardingMain(),
            ),
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Matching the background of your splash2 image
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(40.r), // Responsive padding
          child: Image.asset(
            "assets/images/splash2.png",
            fit: BoxFit.contain, // Ensures logo is never cropped on any device
          ),
        ),
      ),
    );

  }
}
