import 'package:hive/hive.dart';
import 'package:sneak_fit/features/item/domain/entities/item_entity.dart';
import 'package:uuid/uuid.dart';

part 'item_hive_model.g.dart';

@HiveType(typeId: 1)
class ItemHiveModel extends HiveObject {
  @HiveField(0)
  final String itemId;

  @HiveField(1)
  final String itemName;

  @HiveField(2)
  final String condition;

  @HiveField(3)
  final double price;

  @HiveField(4)
  final String? description;

  @HiveField(5)
  final String? media;

  @HiveField(6)
  final String? mediaType;

  @HiveField(7)
  final String status;

  @HiveField(8)
  final DateTime? createdAt;

  @HiveField(9)
  final DateTime? updatedAt;

  ItemHiveModel({
    String? itemId,
    required this.itemName,
    required this.condition,
    required this.price,
    this.description,
    this.media,
    this.mediaType,
    String? status,
    this.createdAt,
    this.updatedAt,
  })  : itemId = itemId ?? const Uuid().v4(),
        status = status ?? 'available';

  factory ItemHiveModel.fromEntity(ItemEntity entity) {
    return ItemHiveModel(
      itemId: entity.itemId,
      itemName: entity.itemName,
      condition: entity.condition.name,
      price: entity.price,
      description: entity.description,
      media: entity.media,
      mediaType: entity.mediaType,
      status: entity.status,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  ItemEntity toEntity() {
    return ItemEntity(
      itemId: itemId,
      itemName: itemName,
      condition: condition.toLowerCase() == 'thrift' 
          ? ItemCondition.thrift 
          : ItemCondition.newCondition,
      price: price,
      description: description,
      media: media,
      mediaType: mediaType,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static List<ItemEntity> toEntityList(List<ItemHiveModel> models) {
    return models.map((e) => e.toEntity()).toList();
  }
}
