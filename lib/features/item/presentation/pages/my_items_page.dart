import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sneak_fit/core/api/api_endpoints.dart';
import 'package:sneak_fit/core/utils/my_snack_bar.dart';
import 'package:sneak_fit/features/item/domain/entities/item_entity.dart';
import 'package:sneak_fit/features/item/presentation/pages/add_item_screen.dart';
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

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[50],
      appBar: AppBar(
        title: Text("My Products", 
          style: TextStyle(
            fontWeight: FontWeight.bold, 
            color: isDark ? Colors.white : Colors.black
          )
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
      ),
      body: itemState.status == ItemStatus.loading && items.isEmpty
          ? Center(child: CircularProgressIndicator(color: isDark ? Colors.white : Colors.black))
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
                          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: isDark ? Colors.white10 : Colors.grey[200]!),
                          boxShadow: [
                            if (!isDark)
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Product Image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Container(
                                width: 80,
                                height: 80,
                                color: isDark ? Colors.black26 : Colors.grey[200],
                                child: item.media != null
                                    ? CachedNetworkImage(
                                        imageUrl: "${ApiEndpoints.baseImageUrl}${item.media}",
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => Container(color: isDark ? Colors.black26 : Colors.grey[200]),
                                        errorWidget: (context, url, error) =>
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
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold, 
                                      fontSize: 16,
                                      color: isDark ? Colors.white : Colors.black,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Rs. ${item.price}",
                                    style: TextStyle(
                                      color: isDark ? Colors.white70 : Colors.black87, 
                                      fontWeight: FontWeight.w600
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: item.condition == ItemCondition.newCondition
                                          ? (isDark ? Colors.blueAccent.withValues(alpha: 0.2) : Colors.blue[100])
                                          : (isDark ? const Color(0xFF00B894).withValues(alpha: 0.2) : const Color(0xFFE0F7F2)),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: item.condition == ItemCondition.newCondition
                                            ? Colors.blue.withValues(alpha: 0.5)
                                            : const Color(0xFF00B894).withValues(alpha: 0.5),
                                      ),
                                    ),
                                    child: Text(
                                      item.condition == ItemCondition.newCondition ? "NEW" : "THRIFT",
                                      style: TextStyle(
                                        color: item.condition == ItemCondition.newCondition
                                            ? (isDark ? Colors.blueAccent : Colors.blue[700])
                                            : const Color(0xFF00B894),
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Action Buttons
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => AddItemScreen(item: item),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.edit_outlined, color: Colors.blueAccent),
                                ),
                                IconButton(
                                  onPressed: () => _confirmDelete(item.itemId, item.itemName),
                                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                ),
                              ],
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
          Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 20),
          Text("No products found", 
            style: TextStyle(
              fontSize: 18, 
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87
            )
          ),
          const SizedBox(height: 10),
          const Text("Items you add for sale will appear here.", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
