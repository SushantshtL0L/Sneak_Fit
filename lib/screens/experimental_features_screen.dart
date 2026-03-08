import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sneak_fit/core/theme/theme_provider.dart';
import 'package:sneak_fit/core/services/biometric_service.dart';
import 'package:sneak_fit/features/sensors/presentation/view_model/sensor_view_model.dart';
import 'package:sneak_fit/features/auth/presentation/pages/change_password_screen.dart';

class ExperimentalFeaturesScreen extends ConsumerStatefulWidget {
  const ExperimentalFeaturesScreen({super.key});

  @override
  ConsumerState<ExperimentalFeaturesScreen> createState() => _ExperimentalFeaturesScreenState();
}

class _ExperimentalFeaturesScreenState extends ConsumerState<ExperimentalFeaturesScreen> {
  bool _biometricEnabled = false;
  bool _isBiometricSupported = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final biometricService = ref.read(biometricServiceProvider);
    _isBiometricSupported = await biometricService.isAvailable();
    _biometricEnabled = await biometricService.isBiometricLoginEnabled();
    if (mounted) setState(() {});
  }

  Future<void> _toggleBiometric(bool value) async {
    final service = ref.read(biometricServiceProvider);
    
    if (value) {
      final authenticated = await service.authenticate(
        reason: 'Verify your identity to enable biometric login',
      );
      if (!authenticated) return;
    }

    await service.setBiometricLoginEnabled(value);
    setState(() => _biometricEnabled = value);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(value ? "Biometric login enabled" : "Biometric login disabled"),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeViewModelProvider);
    final sensorState = ref.watch(sensorViewModelProvider);
    final isDark = themeState.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[50],
      appBar: AppBar(
        title: const Text("Security & Features"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader("Display Settings"),
            _featureCard(
              title: "Auto-Theme (Light Sensor)",
              description: "Detects ambient light to automatically switch between light and dark mode.",
              icon: Icons.brightness_auto,
              accentColor: Colors.amber,
              value: themeState.isAutoThemeEnabled,
              onChanged: (val) => ref.read(themeViewModelProvider.notifier).toggleAutoTheme(),
              details: themeState.isAutoThemeEnabled 
                ? "Current Light: ${sensorState.lux.toStringAsFixed(0)} Lux" 
                : null,
            ),
            
            const SizedBox(height: 20),
            _sectionHeader("Security & Privacy"),
            _featureCard(
              title: "Fingerprint Login",
              description: "Use your device's biometric sensors to secure your account and login faster.",
              icon: Icons.fingerprint,
              accentColor: Colors.blue,
              value: _biometricEnabled,
              enabled: _isBiometricSupported,
              onChanged: _toggleBiometric,
              details: !_isBiometricSupported ? "Device does not support biometrics" : null,
            ),
            const SizedBox(height: 12),
            _simpleMenuCard(
              title: "Change Password",
              icon: Icons.lock_outline_rounded,
              accentColor: Colors.redAccent,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
                );
              },
            ),
            const SizedBox(height: 12),
            _simpleMenuCard(
              title: "Delete Account",
              icon: Icons.delete_outline_rounded,
              accentColor: Colors.red,
              onTap: () {
                _showDeleteAccountDialog();
              },
            ),

            const SizedBox(height: 20),
            _sectionHeader("Hardware Testing"),
            _featureCard(
              title: "Shake Response",
              description: "Detects high intensity movement (shaking) to provide feedback.",
              icon: Icons.vibration,
              accentColor: Colors.green,
              value: sensorState.isShakeDetected,
              onChanged: null, // Read only for demo
              details: sensorState.isShakeDetected ? "⚡ SHAKE DETECTED!" : "Shake your phone to test",
            ),

            const SizedBox(height: 40),
            Center(
              child: Text(
                "Version 1.0.4 - Security & Features",
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _featureCard({
    required String title,
    required String description,
    required IconData icon,
    required Color accentColor,
    required bool value,
    bool enabled = true,
    Function(bool)? onChanged,
    String? details,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: isDark ? Border.all(color: Colors.white10) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accentColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (onChanged != null)
                Switch.adaptive(
                  value: value,
                  onChanged: enabled ? onChanged : null,
                  activeThumbColor: accentColor,
                  activeTrackColor: accentColor.withValues(alpha: 0.3),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              height: 1.4,
            ),
          ),
          if (details != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? Colors.black26 : Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                details,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _simpleMenuCard({
    required String title,
    required IconData icon,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: accentColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14, color: isDark ? Colors.grey[600] : Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Account"),
        content: const Text("This action is permanent and cannot be undone. Are you sure you want to request account deletion?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Request to delete account sent. Please contact support.")),
              );
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
