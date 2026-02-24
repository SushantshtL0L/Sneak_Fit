import 'package:equatable/equatable.dart';

class OrderEntity extends Equatable {
  final String id;
  final List<OrderItemEntity> items;
  final double totalAmount;
  final String paymentMethod;
  final String status;
  final DateTime createdAt;
  final String? userName;
  final ShippingAddressEntity? shippingAddress;

  const OrderEntity({
    required this.id,
    required this.items,
    required this.totalAmount,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
    this.userName,
    this.shippingAddress,
  });

  @override
  List<Object?> get props => [id, items, totalAmount, paymentMethod, status, createdAt, userName, shippingAddress];
}

class OrderItemEntity extends Equatable {
  final String product;
  final String name;
  final double price;
  final int quantity;
  final String size;
  final String image;

  const OrderItemEntity({
    required this.product,
    required this.name,
    required this.price,
    required this.quantity,
    required this.size,
    required this.image,
  });

  @override
  List<Object?> get props => [product, name, price, quantity, size, image];
}

class ShippingAddressEntity extends Equatable {
  final String fullName;
  final String phone;
  final String address;
  final String city;

  const ShippingAddressEntity({
    required this.fullName,
    required this.phone,
    required this.address,
    required this.city,
  });

  @override
  List<Object?> get props => [fullName, phone, address, city];
}
