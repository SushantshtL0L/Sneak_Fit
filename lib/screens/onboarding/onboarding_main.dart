import 'package:flutter/material.dart';
import 'package:sneak_fit/screens/auth/login_screen.dart';
import 'onboarding1.dart';
import 'onboarding2.dart';
import 'onboarding3.dart';

class OnboardingMain extends StatefulWidget {
  const OnboardingMain({super.key});

  @override
  State<OnboardingMain> createState() => _OnboardingMainState();
}

class _OnboardingMainState extends State<OnboardingMain> {
  final controller = PageController();

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: controller,
      children: [
        Onboarding1(onNext: () => controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn)),
        Onboarding2(onNext: () => controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn)),
        Onboarding3(onNext: () => controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn)),
        const LoginScreen(),
      ],
    );
  }
}
