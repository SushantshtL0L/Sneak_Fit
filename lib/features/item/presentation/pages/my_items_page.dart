import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sneak_fit/core/api/api_endpoints.dart';
import 'package:sneak_fit/core/utils/my_snack_bar.dart';
import 'package:sneak_fit/features/item/presentation/state/item_state.dart';
import 'package:sneak_fit/features/item/presentation/view_model/item_viewmodel.dart';

class MyItemsPage extends ConsumerStatefulWidget {
  const MyItemsPage({super.key});

  @override
  ConsumerState<MyItemsPage> createState() => _MyItemsPageState();
}

class _MyItemsPageState extends ConsumerState<MyItemsPage> {
  @override
  void initState() {
    super.initState();
    // Use Future.microtask to avoid calling provider during build
    Future.microtask(() => ref.read(itemViewModelProvider.notifier).getAllItems());
  }

  void _confirmDelete(String id, String name) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Delete Product?"),
        content: Text("Are you sure you want to delete '$name'? This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await ref.read(itemViewModelProvider.notifier).deleteProduct(id);
              
              if (!mounted) return;

              final state = ref.read(itemViewModelProvider);
              if (state.status == ItemStatus.error) {
                showMySnackBar(
                  context: context,
                  message: state.errorMessage ?? "Failed to delete product",
                  type: SnackBarType.error,
                );
              } else {
                showMySnackBar(
                  context: context,
                  message: "Product deleted successfully!",
                  type: SnackBarType.success,
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final itemState = ref.watch(itemViewModelProvider);
    final items = itemState.items;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("My Products", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: itemState.status == ItemStatus.loading && items.isEmpty
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : items.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: () async => ref.read(itemViewModelProvider.notifier).getAllItems(),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: items.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 15),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Row(
                          children: [
                            // Product Image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Container(
                                width: 80,
                                height: 80,
                                color: Colors.grey[200],
                                child: item.media != null
                                    ? Image.network(
                                        "${ApiEndpoints.baseImageUrl}${item.media}",
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) =>
                                            const Icon(Icons.shopping_bag_outlined, color: Colors.grey),
                                      )
                                    : const Icon(Icons.shopping_bag_outlined, color: Colors.grey),
                              ),
                            ),
                            const SizedBox(width: 15),
                            // Product Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.itemName,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Rs. ${item.price}",
                                    style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      item.condition.toString().split('.').last.toUpperCase(),
                                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Delete Button
                            IconButton(
                              onPressed: () => _confirmDelete(item.itemId, item.itemName),
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 20),
          const Text("No products found", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text("Items you add for sale will appear here.", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
