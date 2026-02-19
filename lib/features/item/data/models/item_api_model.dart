import 'package:equatable/equatable.dart';
import 'package:sneak_fit/features/item/domain/entities/item_entity.dart';

class ItemApiModel extends Equatable {
  final String? id;
  final String? name; // Matches backend 'name'
  final String? condition; // 'new' or 'thrift'
  final double? price;
  final String? description;
  final String? image; // Matches backend 'image'
  final String? brand;
  final String? size;
  final String? color;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ItemApiModel({
    this.id,
    this.name,
    this.condition,
    this.price,
    this.description,
    this.image,
    this.brand,
    this.size,
    this.color,
    this.status = 'available',
    this.createdAt,
    this.updatedAt,
  });

  // Convert from API JSON response
  factory ItemApiModel.fromJson(Map<String, dynamic> json) {
    return ItemApiModel(
      id: json['_id'] as String?,
      name: json['name'] as String?,
      condition: json['condition'] as String? ?? 'new',
      price: json['price'] != null ? (json['price'] as num).toDouble() : 0.0,
      description: json['description'] as String?,
      image: json['image'] as String?,
      brand: json['brand'] as String?,
      size: json['size'] as String?,
      color: json['color'] as String?,
      status: json['status'] as String? ?? 'available',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  // Convert to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'condition': condition,
      'price': price,
      'description': description,
      'image': image,
      'brand': brand,
      'size': size,
      'color': color,
      'status': status,
    };
  }

  // Convert API model to Entity
  ItemEntity toEntity() {
    return ItemEntity(
      itemId: id ?? '',
      itemName: name ?? 'Untitled',
      condition: condition?.toLowerCase() == 'thrift' ? ItemCondition.thrift : ItemCondition.newCondition,
      price: price ?? 0.0,
      description: description,
      media: image,
      mediaType: 'image',
      status: status,
      brand: brand,
      size: size,
      color: color,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        condition,
        price,
        description,
        image,
        brand,
        size,
        color,
        status,
        createdAt,
        updatedAt,
      ];
}
