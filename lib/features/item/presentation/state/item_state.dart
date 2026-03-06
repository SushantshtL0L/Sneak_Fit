import 'package:equatable/equatable.dart';
import 'package:sneak_fit/features/item/domain/entities/item_entity.dart';

enum ItemStatus { initial, loading, loaded, error, created, updated, deleted }

class ItemState extends Equatable {
  final ItemStatus status;
  final List<ItemEntity> items;
  final List<ItemEntity> filteredItems; // Added for filtering
  final String? selectedBrand; // Added for filtering
  final String? selectedSize; // Added for filtering
  final double? minPrice; // Added for filtering
  final double? maxPrice; // Added for filtering
  final List<ItemEntity> lostItems;
  final List<ItemEntity> foundItems;
  final List<ItemEntity> myLostItems;
  final List<ItemEntity> myFoundItems;
  final ItemEntity? selectedItem;
  final String? errorMessage;
  final String? uploadedPhotoUrl;

  const ItemState({
    this.status = ItemStatus.initial,
    this.items = const [],
    this.filteredItems = const [], // Initialize filteredItems
    this.selectedBrand,
    this.selectedSize,
    this.minPrice,
    this.maxPrice,
    this.lostItems = const [],
    this.foundItems = const [],
    this.myLostItems = const [],
    this.myFoundItems = const [],
    this.selectedItem,
    this.errorMessage,
    this.uploadedPhotoUrl,
  });

  ItemState copyWith({
    ItemStatus? status,
    List<ItemEntity>? items,
    List<ItemEntity>? filteredItems,
    String? selectedBrand,
    String? selectedSize,
    double? minPrice,
    double? maxPrice,
    bool resetBrand = false,
    bool resetSize = false,
    bool resetPrice = false,
    List<ItemEntity>? lostItems,
    List<ItemEntity>? foundItems,
    List<ItemEntity>? myLostItems,
    List<ItemEntity>? myFoundItems,
    ItemEntity? selectedItem,
    bool resetSelectedItem = false,
    String? errorMessage,
    bool resetErrorMessage = false,
    String? uploadedPhotoUrl,
    bool resetUploadedPhotoUrl = false,
  }) {
    return ItemState(
      status: status ?? this.status,
      items: items ?? this.items,
      filteredItems: filteredItems ?? this.filteredItems,
      selectedBrand: resetBrand ? null : (selectedBrand ?? this.selectedBrand),
      selectedSize: resetSize ? null : (selectedSize ?? this.selectedSize),
      minPrice: resetPrice ? null : (minPrice ?? this.minPrice),
      maxPrice: resetPrice ? null : (maxPrice ?? this.maxPrice),
      lostItems: lostItems ?? this.lostItems,
      foundItems: foundItems ?? this.foundItems,
      myLostItems: myLostItems ?? this.myLostItems,
      myFoundItems: myFoundItems ?? this.myFoundItems,
      selectedItem: resetSelectedItem
          ? null
          : (selectedItem ?? this.selectedItem),
      errorMessage: resetErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      uploadedPhotoUrl: resetUploadedPhotoUrl
          ? null
          : (uploadedPhotoUrl ?? this.uploadedPhotoUrl),
    );
  }

  @override
  List<Object?> get props => [
    status,
    items,
    filteredItems,
    selectedBrand,
    selectedSize,
    minPrice,
    maxPrice,
    lostItems,
    foundItems,
    myLostItems,
    myFoundItems,
    selectedItem,
    errorMessage,
    uploadedPhotoUrl,
  ];
}
