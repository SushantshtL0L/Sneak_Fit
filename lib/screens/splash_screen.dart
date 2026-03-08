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
      backgroundColor: Colors.black, 
      body: Stack(
        children: [
          // Background subtle gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.0,
                  colors: [
                    Color(0xFF1A1A1A),
                    Colors.black,
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 1500),
              curve: Curves.elasticOut,
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Opacity(
                    opacity: value.clamp(0.0, 1.0),
                    child: child,
                  ),
                );
              },
        child: Padding(
                padding: EdgeInsets.all(40.r),
                child: Hero(
                  tag: 'logo',
          child: Image.asset(
            "assets/images/splash2.png",
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
          // Loading indicator at bottom
          Positioned(
            bottom: 50.h,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 40.w,
                child: const LinearProgressIndicator(
                  backgroundColor: Colors.transparent,
                  color: Colors.greenAccent,
                  minHeight: 2,
          ),
        ),
            ),
          ),
        ],
      ),
    );

  }
}
