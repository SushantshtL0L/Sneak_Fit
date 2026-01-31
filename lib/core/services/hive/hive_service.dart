import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../features/auth/data/models/auth_hive_model.dart';
import '../../../features/item/data/models/item_hive_model.dart';

final hiveServiceProvider = Provider<HiveService>((ref) {
  throw UnimplementedError('HiveService must be overridden in main.dart');
});

class HiveService {
  static const String _authBoxName = 'auth_box';
  static const String _itemBoxName = 'item_box';
  
  late Box<AuthHiveModel> _authBox;
  late Box<ItemHiveModel> _itemBox;

  // Initialize Hive
  Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    if (!Hive.isAdapterRegistered(AuthHiveModelAdapter().typeId)) {
      Hive.registerAdapter(AuthHiveModelAdapter());
    }
    if (!Hive.isAdapterRegistered(ItemHiveModelAdapter().typeId)) {
      Hive.registerAdapter(ItemHiveModelAdapter());
    }

    _authBox = await Hive.openBox<AuthHiveModel>(_authBoxName);
    _itemBox = await Hive.openBox<ItemHiveModel>(_itemBoxName);
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

  // ================= Item Box Methods =================

  Future<void> createItem(ItemHiveModel model) async {
    await _itemBox.put(model.itemId, model);
  }

  Future<void> updateItem(ItemHiveModel model) async {
    await _itemBox.put(model.itemId, model);
  }

  Future<void> deleteItem(String itemId) async {
    await _itemBox.delete(itemId);
  }

  Future<ItemHiveModel?> getItemById(String itemId) async {
    return _itemBox.get(itemId);
  }

  Future<List<ItemHiveModel>> getAllItems() async {
    return _itemBox.values.toList();
  }
}
