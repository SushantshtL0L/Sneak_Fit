import 'package:equatable/equatable.dart';

class CartItemEntity extends Equatable {
  final String id;
  final String name;
  final double price;
  final String image;
  final String brand;
  final int quantity;
  final String size;
  final String color;
  final String description;
  final String? condition;

  const CartItemEntity({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.brand,
    required this.quantity,
    required this.size,
    required this.color,
    required this.description,
    this.condition,
  });

  CartItemEntity copyWith({
    String? id,
    String? name,
    double? price,
    String? image,
    String? brand,
    int? quantity,
    String? size,
    String? color,
    String? description,
    String? condition,
  }) {
    return CartItemEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      image: image ?? this.image,
      brand: brand ?? this.brand,
      quantity: quantity ?? this.quantity,
      size: size ?? this.size,
      color: color ?? this.color,
      description: description ?? this.description,
      condition: condition ?? this.condition,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        price,
        image,
        brand,
        quantity,
        size,
        color,
        description,
        condition,
      ];
}
