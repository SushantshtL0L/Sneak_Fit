import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sneak_fit/core/services/hive/hive_service.dart';
import 'package:sneak_fit/features/item/data/models/item_hive_model.dart';

final itemLocalDatasourceProvider = Provider<ItemLocalDatasource>((ref) {
  final hiveService = ref.read(hiveServiceProvider);
  return ItemLocalDatasource(hiveService: hiveService);
});

class ItemLocalDatasource {
  final HiveService _hiveService;

  ItemLocalDatasource({required HiveService hiveService})
      : _hiveService = hiveService;

  // Create a new item
  Future<bool> createItem(ItemHiveModel item) async {
    try {
      await _hiveService.createItem(item);
      return true;
    } catch (_) {
      return false;
    }
  }

  // Update an existing item
  Future<bool> updateItem(ItemHiveModel item) async {
    try {
      await _hiveService.updateItem(item);
      return true;
    } catch (_) {
      return false;
    }
  }

  // Delete an item
  Future<bool> deleteItem(String itemId) async {
    try {
      await _hiveService.deleteItem(itemId);
      return true;
    } catch (_) {
      return false;
    }
  }

  // Get a single item by ID
  Future<ItemHiveModel?> getItemById(String itemId) async {
    try {
      return _hiveService.getItemById(itemId);
    } catch (_) {
      return null;
    }
  }

  // Get all items
  Future<List<ItemHiveModel>> getAllItems() async {
    try {
      return await _hiveService.getAllItems();
    } catch (_) {
      return [];
    }
  }
}
