import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sneak_fit/features/item/data/repositories/item_repository.dart';
import 'package:sneak_fit/features/item/domain/repositories/i_item_repository.dart';
import 'package:sneak_fit/features/item/domain/entities/item_entity.dart';
import 'package:sneak_fit/features/item/presentation/state/item_state.dart';

final itemViewModelProvider = StateNotifierProvider<ItemViewModel, ItemState>((ref) {
  return ItemViewModel(ref.read(itemRepositoryProvider));
});

class ItemViewModel extends StateNotifier<ItemState> {
  final IItemRepository _repository;

  ItemViewModel(this._repository) : super(const ItemState()) {
    _initializeData();
  }

  Future<void> _initializeData() async {
    // 1. Load local data immediately for instant UI feedback
    final localResult = await _repository.getLocalItems();
    localResult.fold(
      (error) => null, 
      (items) {
        if (items.isNotEmpty) {
          state = state.copyWith(
            status: ItemStatus.loaded,
            items: items,
            filteredItems: items,
          );
        }
      },
    );
    
    // 2. Refresh from network (background)
    await getAllItems();
  }

  Future<void> getAllItems() async {
    // Only set loading if we don't already have items to show
    if (state.items.isEmpty) {
      state = state.copyWith(status: ItemStatus.loading);
    }
    
    final result = await _repository.getAllItems();
    
    result.fold(
      (error) {
        if (state.items.isEmpty) {
          state = state.copyWith(
            status: ItemStatus.error,
            errorMessage: error.toString(),
          );
        } else {
          state = state.copyWith(status: ItemStatus.loaded);
        }
      },
      (items) => state = state.copyWith(
        status: ItemStatus.loaded,
        items: items,
        filteredItems: items,
      ),
    );
  }

  void searchProducts(String query) {
    if (query.isEmpty) {
      state = state.copyWith(filteredItems: state.items);
      return;
    }

    final lowercaseQuery = query.toLowerCase();
    final filtered = state.items.where((item) {
      final name = item.itemName.toLowerCase();
      final brand = (item.brand ?? '').toLowerCase();
      final description = (item.description ?? '').toLowerCase();
      
      return name.contains(lowercaseQuery) || 
             brand.contains(lowercaseQuery) || 
             description.contains(lowercaseQuery);
    }).toList();

    state = state.copyWith(filteredItems: filtered);
  }

  void filterItems({
    String? brand,
    String? size,
    double? minPrice,
    double? maxPrice,
  }) {
    List<ItemEntity> filtered = state.items;

    if (brand != null && brand != 'All') {
      filtered = filtered.where((item) => item.brand == brand).toList();
    }

    if (size != null && size != 'All') {
      filtered = filtered.where((item) => item.size == size).toList();
    }

    if (minPrice != null && maxPrice != null) {
      filtered = filtered.where((item) => item.price >= minPrice && item.price <= maxPrice).toList();
    }

    state = state.copyWith(
      filteredItems: filtered,
      selectedBrand: brand,
      selectedSize: size,
      minPrice: minPrice,
      maxPrice: maxPrice,
    );
  }

  void resetFilters() {
    state = state.copyWith(
      filteredItems: state.items,
      resetBrand: true,
      resetSize: true,
      resetPrice: true,
    );
  }

  Future<void> createProduct(
    String name,
    String description,
    String condition,
    String imagePath,
    double price,
    String brand,
    String? size,
    String? color,
  ) async {
    state = state.copyWith(status: ItemStatus.loading);
    
    final result = await _repository.createProduct(
      name,
      description,
      condition,
      imagePath,
      price,
      brand,
      size,
      color,
    );
    
    result.fold(
      (error) => state = state.copyWith(
        status: ItemStatus.error,
        errorMessage: error.toString(),
      ),
      (success) {
        state = state.copyWith(status: ItemStatus.created);
        getAllItems(); // Refresh the list after creation
      },
    );
  }

  Future<void> updateProduct(
    String id,
    String name,
    String description,
    String condition,
    String? imagePath,
    double price,
    String brand,
    String? size,
    String? color,
  ) async {
    state = state.copyWith(status: ItemStatus.loading);
    
    final result = await _repository.updateProduct(
      id,
      name,
      description,
      condition,
      imagePath,
      price,
      brand,
      size,
      color,
    );
    
    result.fold(
      (error) => state = state.copyWith(
        status: ItemStatus.error,
        errorMessage: error.toString(),
      ),
      (success) {
        state = state.copyWith(status: ItemStatus.updated); 
        getAllItems(); // Refresh the list
      },
    );
  }

  Future<void> deleteProduct(String id) async {
    state = state.copyWith(status: ItemStatus.loading);
    
    final result = await _repository.deleteProduct(id);
    
    result.fold(
      (error) => state = state.copyWith(
        status: ItemStatus.error,
        errorMessage: error.toString(),
      ),
      (success) {
        
        getAllItems();
      },
    );
  }
}
