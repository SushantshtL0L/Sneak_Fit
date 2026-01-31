import 'package:equatable/equatable.dart';

enum ItemCondition { newCondition, thrift }

class ItemEntity extends Equatable {
  final String itemId;
  final String itemName;
  final ItemCondition condition;
  final double price;
  final String? description;
  final String? media; // path to image
  final String? mediaType; // e.g., 'image'
  final String status; // available, sold, etc.
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ItemEntity({
    required this.itemId,
    required this.itemName,
    required this.condition,
    required this.price,
    this.description,
    this.media,
    this.mediaType,
    this.status = 'available',
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        itemId,
        itemName,
        condition,
        price,
        description,
        media,
        mediaType,
        status,
      ];
}
