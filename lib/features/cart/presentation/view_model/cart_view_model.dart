import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sneak_fit/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:sneak_fit/features/cart/domain/entities/cart_item_entity.dart';
import 'package:sneak_fit/features/cart/presentation/state/cart_state.dart';

final cartViewModelProvider =
    StateNotifierProvider<CartViewModel, CartState>((ref) {
  // Watch auth state - this ensures the provider rebuilds when user changes
  ref.watch(authViewModelProvider);
  return CartViewModel(ref);
});

class CartViewModel extends StateNotifier<CartState> {
  final Ref _ref;
  CartViewModel(this._ref) : super(const CartState()) {
    _loadCart();
  }

  void reloadCart() {
    _loadCart();
  }

  // Get current user ID to create a unique storage key
  String _getCartKey(String? userId) {
    if (userId == null) return 'cart_items_guest';
    return 'cart_items_$userId';
  }

  Future<void> _loadCart() async {
    try {
      final authState = _ref.read(authViewModelProvider);
      final userId = authState.authEntity?.userId;
      
      final prefs = await SharedPreferences.getInstance();
      final cartJson = prefs.getString(_getCartKey(userId));
      
      if (cartJson != null) {
        final List<dynamic> decoded = jsonDecode(cartJson);
        final items = decoded.map((item) => _cartItemFromJson(item)).toList();
        state = state.copyWith(cartItems: items);
      } else {
        // If no saved cart for this user, ensure state is empty
        state = state.copyWith(cartItems: []);
      }
    } catch (e) {
      // Silently handle error - cart will remain empty
    }
  }

  Future<void> _saveCart() async {
    try {
      final authState = _ref.read(authViewModelProvider);
      final userId = authState.authEntity?.userId;

      final prefs = await SharedPreferences.getInstance();
      final cartJson = jsonEncode(
        state.cartItems.map((item) => _cartItemToJson(item)).toList(),
      );
      await prefs.setString(_getCartKey(userId), cartJson);
    } catch (e) {
      // Silently handle error - cart state remains in memory
    }
  }

  void addToCart(CartItemEntity item) {
    final existingIndex = state.cartItems.indexWhere(
      (i) => i.id == item.id && i.size == item.size,
    );

    List<CartItemEntity> updatedCart;
    if (existingIndex != -1) {
      // Item with same id and size exists, update quantity
      updatedCart = List.from(state.cartItems);
      updatedCart[existingIndex] = updatedCart[existingIndex].copyWith(
        quantity: updatedCart[existingIndex].quantity + item.quantity,
      );
    } else {
      // Add new item
      updatedCart = [...state.cartItems, item];
    }

    state = state.copyWith(cartItems: updatedCart);
    _saveCart();
  }

  void removeFromCart(String id, String size) {
    final updatedCart = state.cartItems
        .where((item) => !(item.id == id && item.size == size))
        .toList();
    state = state.copyWith(cartItems: updatedCart);
    _saveCart();
  }

  void updateQuantity(String id, String size, int quantity) {
    if (quantity < 1) return;

    final updatedCart = state.cartItems.map((item) {
      if (item.id == id && item.size == size) {
        return item.copyWith(quantity: quantity);
      }
      return item;
    }).toList();

    state = state.copyWith(cartItems: updatedCart);
    _saveCart();
  }

  void updateSize(String id, String oldSize, String newSize) {
    // Check if an item with the new size already exists
    final existingItemIndex = state.cartItems.indexWhere(
      (item) => item.id == id && item.size == newSize,
    );

    List<CartItemEntity> updatedCart = List.from(state.cartItems);

    if (existingItemIndex != -1) {
      // If it exists, find the old item, add its quantity to the new item, and remove old item
      final oldItemIndex = updatedCart.indexWhere(
        (item) => item.id == id && item.size == oldSize,
      );

      if (oldItemIndex != -1) {
        final oldItem = updatedCart[oldItemIndex];
        updatedCart[existingItemIndex] = updatedCart[existingItemIndex].copyWith(
          quantity: updatedCart[existingItemIndex].quantity + oldItem.quantity,
        );
        updatedCart.removeAt(oldItemIndex);
      }
    } else {
      // Otherwise just update the size
      updatedCart = updatedCart.map((item) {
        if (item.id == id && item.size == oldSize) {
          return item.copyWith(size: newSize);
        }
        return item;
      }).toList();
    }

    state = state.copyWith(cartItems: updatedCart);
    _saveCart();
  }

  void clearCart() {
    state = const CartState();
    _saveCart();
  }

  // Helper methods for JSON serialization
  Map<String, dynamic> _cartItemToJson(CartItemEntity item) {
    return {
      'id': item.id,
      'name': item.name,
      'price': item.price,
      'image': item.image,
      'brand': item.brand,
      'quantity': item.quantity,
      'size': item.size,
      'color': item.color,
      'description': item.description,
      'condition': item.condition,
    };
  }

  CartItemEntity _cartItemFromJson(Map<String, dynamic> json) {
    return CartItemEntity(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      image: json['image'] as String,
      brand: json['brand'] as String,
      quantity: json['quantity'] as int,
      size: json['size'] as String,
      color: json['color'] as String,
      description: json['description'] as String,
      condition: json['condition'] as String?,
    );
  }
}
