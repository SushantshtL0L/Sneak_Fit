import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

final biometricServiceProvider = Provider<BiometricService>((ref) {
  return BiometricService();
});

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();
  static const String _biometricEnabledKey = 'biometric_enabled';

  /// Check if the device supports biometrics (fingerprint, face, etc.)
  Future<bool> isAvailable() async {
    try {
      final bool canCheckBiometrics = await _auth.canCheckBiometrics;
      final bool isDeviceSupported = await _auth.isDeviceSupported();
      return canCheckBiometrics && isDeviceSupported;
    } catch (_) {
      return false;
    }
  }

  /// Get list of enrolled biometrics on the device
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (_) {
      return [];
    }
  }

  /// Prompt biometric authentication dialog
  /// Returns true if the user successfully authenticates
  Future<bool> authenticate({String reason = 'Authenticate to access Sneak Fit'}) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: false, // false = also allows PIN/pattern as fallback
          stickyAuth: true,     // keep dialog alive if app goes to background
          useErrorDialogs: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }

  /// Check if the user has enabled biometric login in preferences
  Future<bool> isBiometricLoginEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_biometricEnabledKey) ?? false;
  }

  /// Save user preference to enable or disable biometric login
  Future<void> setBiometricLoginEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricEnabledKey, enabled);
  }
}
