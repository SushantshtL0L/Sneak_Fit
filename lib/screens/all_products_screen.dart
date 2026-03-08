import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sneak_fit/core/api/api_endpoints.dart';
import 'package:sneak_fit/core/theme/theme_provider.dart';
import 'package:sneak_fit/features/item/domain/entities/item_entity.dart';
import 'package:sneak_fit/features/item/presentation/state/item_state.dart';
import 'package:sneak_fit/features/item/presentation/view_model/item_viewmodel.dart';
import 'package:sneak_fit/features/item/presentation/widgets/filter_bottom_sheet.dart';
import 'package:sneak_fit/screens/product_detail_screen_new.dart';

class AllProductsScreen extends ConsumerWidget {
  const AllProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemState = ref.watch(itemViewModelProvider);
    final itemsToDisplay = itemState.filteredItems;
    final isDark = ref.watch(themeViewModelProvider).isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text("All Products"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); 
          },
        ),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.filter_list),
                if (itemState.selectedBrand != null && itemState.selectedBrand != 'All' || 
                    itemState.selectedSize != null && itemState.selectedSize != 'All')
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(minWidth: 8, minHeight: 8),
                    ),
                  ),
              ],
            ),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const FilterBottomSheet(),
              );
            },
          ),
        ],
        backgroundColor: isDark ? Colors.black : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
        elevation: 1,
      ),
      body: itemState.status == ItemStatus.loading && itemState.items.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : itemsToDisplay.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.search_off, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text("No products match your filters"),
                      TextButton(
                        onPressed: () => ref.read(itemViewModelProvider.notifier).resetFilters(),
                        child: const Text("Clear Filters"),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(12),
                  child: GridView.builder(
                    itemCount: itemsToDisplay.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: MediaQuery.of(context).size.width > 600 ? 0.75 : 0.65,
                    ),
                    itemBuilder: (context, index) {
                      final item = itemsToDisplay[index];
                      return productCard(
                        context: context,
                        item: item,
                        rating: "4.5",
                        sold: "4300 SOLD",
                        isDark: isDark,
                      );
                    },
                  ),
                ),
    );
  }

  Widget productCard({
    required BuildContext context,
    required ItemEntity item,
    required String rating,
    required String sold,
    required bool isDark,
  }) {
    final String imageUrl = item.media != null
        ? "${ApiEndpoints.baseImageUrl}${item.media}"
        : "";

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreenNew(
              item: item,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Center(
                child: imageUrl.startsWith('http')
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.contain,
                        placeholder: (context, url) => const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        errorWidget: (context, url, error) =>
                            Image.asset("assets/images/shoe.png"),
                      )
                    : Image.asset(
                        "assets/images/shoe.png",
                        fit: BoxFit.contain,
                      ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.brand?.toUpperCase() ?? "SNEAKFIT",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.tealAccent : Colors.grey,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item.itemName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'OpenSans',
                fontSize: 14,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item.description ?? "No description available",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.star, size: 14, color: Colors.orange),
                const SizedBox(width: 4),
                Text(rating, style: const TextStyle(fontSize: 12)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: item.condition == ItemCondition.newCondition
                        ? (isDark ? Colors.blueAccent.withValues(alpha: 0.15) : Colors.blue[50])
                        : (isDark ? const Color(0xFF00B894).withValues(alpha: 0.15) : const Color(0xFFE0F7F2)),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: item.condition == ItemCondition.newCondition
                          ? (isDark ? Colors.blueAccent.withValues(alpha: 0.3) : Colors.blue[200]!)
                          : (isDark ? const Color(0xFF00B894).withValues(alpha: 0.3) : const Color(0xFFB9EFE5)),
                    ),
                  ),
                  child: Text(
                    item.condition == ItemCondition.newCondition ? "NEW" : "THRIFT",
                    style: TextStyle(
                      fontSize: 9, 
                      fontWeight: FontWeight.bold,
                      color: item.condition == ItemCondition.newCondition
                          ? (isDark ? Colors.blueAccent : Colors.blue[700])
                          : const Color(0xFF00B894),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
