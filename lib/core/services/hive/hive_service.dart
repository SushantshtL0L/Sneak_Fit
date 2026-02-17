import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import '../../../features/auth/data/models/auth_hive_model.dart';

class HiveService {
  static const String _authBoxName = 'auth_box';
  late Box<AuthHiveModel> _authBox;

  // Initialize Hive
  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);

    // Register adapter only once
    if (!Hive.isAdapterRegistered(AuthHiveModelAdapter().typeId)) {
      Hive.registerAdapter(AuthHiveModelAdapter());
    }

    _authBox = await Hive.openBox<AuthHiveModel>(_authBoxName);
  }

  // Register user
  Future<bool> registerUser(AuthHiveModel model) async {
    final exists = await isEmailExists(model.email);
    if (exists) return false;

    await _authBox.put(model.userId, model);
    return true;
  }

  // Check if email exists
  Future<bool> isEmailExists(String email) async {
    return _authBox.values.any(
      (user) => user.email.toLowerCase().trim() == email.toLowerCase().trim(),
    );
  }

  // Login user
  Future<AuthHiveModel?> loginUser(String email, String password) async {
    try {
      final user = _authBox.values.firstWhere(
        (user) =>
            user.email.toLowerCase().trim() == email.toLowerCase().trim() &&
            user.password == password,
        
      );
      return user;
    } catch (_) {
      return null;
    }
  }

  // Logout (dummy)
  Future<void> logoutUser() async {}

  // Get current user
  Future<AuthHiveModel?> getCurrentUser() async {
    if (_authBox.isEmpty) return null;
    return _authBox.values.first;
  }
}
