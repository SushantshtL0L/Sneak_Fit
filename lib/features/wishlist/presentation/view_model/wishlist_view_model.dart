import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sneak_fit/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:sneak_fit/features/item/domain/entities/item_entity.dart';
import 'package:sneak_fit/features/item/data/models/item_api_model.dart';

class WishlistState {
  final List<ItemEntity> items;
  const WishlistState({this.items = const []});

  WishlistState copyWith({List<ItemEntity>? items}) {
    return WishlistState(items: items ?? this.items);
  }
}

final wishlistViewModelProvider =
    StateNotifierProvider<WishlistViewModel, WishlistState>((ref) {
  // Watch auth state - this ensures the provider rebuilds when user changes
  ref.watch(authViewModelProvider);
  return WishlistViewModel(ref);
});

class WishlistViewModel extends StateNotifier<WishlistState> {
  final Ref _ref;
  WishlistViewModel(this._ref) : super(const WishlistState()) {
    _loadWishlist();
  }

  String _getWishlistKey(String? userId) {
    if (userId == null) return 'wishlist_items_guest';
    return 'wishlist_items_$userId';
  }

  Future<void> _loadWishlist() async {
    try {
      final authState = _ref.read(authViewModelProvider);
      final userId = authState.authEntity?.userId;
      
      final prefs = await SharedPreferences.getInstance();
      final wishlistJson = prefs.getString(_getWishlistKey(userId));
      
      if (wishlistJson != null) {
        final List<dynamic> decoded = jsonDecode(wishlistJson);
        final items = decoded.map((json) => ItemApiModel.fromJson(json).toEntity()).toList();
        state = state.copyWith(items: items);
      } else {
        state = state.copyWith(items: []);
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _saveWishlist() async {
    try {
      final authState = _ref.read(authViewModelProvider);
      final userId = authState.authEntity?.userId;

      final prefs = await SharedPreferences.getInstance();
      final wishlistJson = jsonEncode(
        state.items.map((item) => _itemToMap(item)).toList(),
      );
      await prefs.setString(_getWishlistKey(userId), wishlistJson);
    } catch (e) {
      // Handle error
    }
  }

  void toggleWishlist(ItemEntity item) {
    final isExist = state.items.any((i) => i.itemId == item.itemId);
    List<ItemEntity> updatedItems;
    
    if (isExist) {
      updatedItems = state.items.where((i) => i.itemId != item.itemId).toList();
    } else {
      updatedItems = [...state.items, item];
    }
    
    state = state.copyWith(items: updatedItems);
    _saveWishlist();
  }

  bool isInWishlist(String itemId) {
    return state.items.any((i) => i.itemId == itemId);
  }

  // Helper for serialization
  Map<String, dynamic> _itemToMap(ItemEntity item) {
    return {
      '_id': item.itemId,
      'name': item.itemName,
      'condition': item.condition == ItemCondition.thrift ? 'thrift' : 'new',
      'price': item.price,
      'description': item.description,
      'image': item.media,
      'brand': item.brand,
      'size': item.size,
      'color': item.color,
      'status': item.status,
    };
  }
}
