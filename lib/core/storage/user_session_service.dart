import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

//shared preds provider
final SharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPrefrence must be overridden in main.dart');
});
//provider
final UserSessionServiceProvider = Provider<UserSessionService>((ref) {
  final prefs = ref.read(SharedPreferencesProvider);
  return UserSessionService(prefs: prefs);
});

class UserSessionService {
  final SharedPreferences _prefs;

  //keys forr storing user data
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUserId = 'user_id';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUsername = 'user_username';
  static const String _keyProfilePicture = 'user_profile_picture';

  UserSessionService({required SharedPreferences prefs}) : _prefs = prefs;

  //Storre user Sssion data

  Future<void> saveUserSession({
    required String userId,
    required String email,
    required String username,
    String? profilePicture,
  }) async {
    await _prefs.setBool(_keyIsLoggedIn, true);
    await _prefs.setString(_keyUserId, userId);
    await _prefs.setString(_keyUserEmail, email);
    await _prefs.setString(_keyUsername, username);

    if (profilePicture != null) {
      await _prefs.setString(_keyProfilePicture, profilePicture);
    }
  }

  //clear user session data
  Future<void> clearUserSession() async {
    await _prefs.remove(_keyIsLoggedIn);
    await _prefs.remove(_keyUserId);
    await _prefs.remove(_keyUserEmail);
    await _prefs.remove(_keyUsername);
    // await _prefs.remove(_keyUserRole);
    await _prefs.remove(_keyProfilePicture);
  }

  bool isLoggedIn() {
    return _prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  String? getUserId() {
    return _prefs.getString(_keyUserId);
  }

  String? getUserEmail() {
    return _prefs.getString(_keyUserEmail);
  }

  String? getUsername() {
    return _prefs.getString(_keyUsername);
  }
}