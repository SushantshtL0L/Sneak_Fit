import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sneak_fit/features/item/data/repositories/item_repository.dart';
import 'package:sneak_fit/features/item/domain/repositories/i_item_repository.dart';
import 'package:sneak_fit/features/item/presentation/state/item_state.dart';

final itemViewModelProvider = StateNotifierProvider<ItemViewModel, ItemState>((ref) {
  return ItemViewModel(ref.read(itemRepositoryProvider));
});

class ItemViewModel extends StateNotifier<ItemState> {
  final IItemRepository _repository;

  ItemViewModel(this._repository) : super(const ItemState()) {
    getAllItems();
  }

  Future<void> getAllItems() async {
    state = state.copyWith(status: ItemStatus.loading);
    
    final result = await _repository.getAllItems();
    
    result.fold(
      (error) => state = state.copyWith(
        status: ItemStatus.error,
        errorMessage: error.toString(),
      ),
      (items) => state = state.copyWith(
        status: ItemStatus.loaded,
        items: items,
      ),
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
