import 'package:equatable/equatable.dart';
import 'package:sneak_fit/features/cart/domain/entities/cart_item_entity.dart';

class CartState extends Equatable {
  final List<CartItemEntity> cartItems;
  final bool isLoading;
  final String? errorMessage;

  const CartState({
    this.cartItems = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  double get totalPrice {
    return cartItems.fold(
      0.0,
      (total, item) => total + (item.price * item.quantity),
    );
  }

  int get totalItems {
    return cartItems.fold(
      0,
      (total, item) => total + item.quantity,
    );
  }

  CartState copyWith({
    List<CartItemEntity>? cartItems,
    bool? isLoading,
    String? errorMessage,
  }) {
    return CartState(
      cartItems: cartItems ?? this.cartItems,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [cartItems, isLoading, errorMessage];
}
