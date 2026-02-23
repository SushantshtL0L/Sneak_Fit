import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sneak_fit/core/storage/user_session_service.dart';

import 'core/services/hive/hive_service.dart';
import 'features/auth/presentation/pages/login_screen.dart';
import 'features/auth/presentation/pages/signup_screen.dart';
import 'features/auth/presentation/pages/forgot_password_screen.dart';
import 'features/auth/presentation/pages/reset_password_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/checkout_screen.dart';
import 'screens/order_success_screen.dart';
import 'package:sneak_fit/core/theme/theme_provider.dart'; 
import 'package:sneak_fit/features/sensors/presentation/view_model/sensor_view_model.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  final hiveService = HiveService();
  await hiveService.init();

  // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        hiveServiceProvider.overrideWithValue(hiveService),
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeViewModelProvider);
    // Initialize sensors without rebuilding the entire app on every update
    ref.listen(sensorViewModelProvider, (previous, next) {});

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SneakFit',
      theme: ThemeData(
        brightness: themeState.isDarkMode ? Brightness.dark : Brightness.light,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: themeState.isDarkMode ? Colors.black : Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: themeState.isDarkMode ? Colors.black : Colors.white,
          foregroundColor: themeState.isDarkMode ? Colors.white : Colors.black,
        ),
        useMaterial3: true,
      ),
      initialRoute: '/splash',
      onGenerateRoute: (settings) {
        if (settings.name == '/reset-password') {
          final email = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => ResetPasswordScreen(email: email),
          );
        }
        return null;
      },
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/checkout': (context) => const CheckoutScreen(),
        '/order-success': (context) => const OrderSuccessScreen(),
      },
    );
  }
}
