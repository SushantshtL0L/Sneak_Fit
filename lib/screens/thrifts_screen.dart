import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sneak_fit/core/api/api_endpoints.dart';
import 'package:sneak_fit/features/item/domain/entities/item_entity.dart';
import 'package:sneak_fit/features/item/presentation/state/item_state.dart';
import 'package:sneak_fit/features/item/presentation/view_model/item_viewmodel.dart';
import 'package:sneak_fit/features/wishlist/presentation/view_model/wishlist_view_model.dart';
import 'package:sneak_fit/features/item/presentation/widgets/filter_bottom_sheet.dart';
import 'package:sneak_fit/core/theme/theme_provider.dart';
import 'package:sneak_fit/screens/product_detail_screen_new.dart';

class ThriftsScreen extends ConsumerWidget {
  const ThriftsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemState = ref.watch(itemViewModelProvider);
    final isDark = ref.watch(themeViewModelProvider).isDarkMode;
    
    // Filter only Thrift items from the filtered list
    final thriftItems = itemState.filteredItems.where((item) => item.condition == ItemCondition.thrift).toList();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.read(itemViewModelProvider.notifier).getAllItems(),
          child: CustomScrollView(
            slivers: [
              // Header & Promo
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Thrift Shop",
                            style: TextStyle(
                              fontSize: 32, 
                              fontWeight: FontWeight.bold, 
                              letterSpacing: -1,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.tune, color: isDark ? Colors.white : Colors.black),
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
                      ),
                      const Text(
                        "Giving kicks a second life.",
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                      const SizedBox(height: 20),
                      _thriftPromoBanner(isDark),
                      const SizedBox(height: 30),
                      Text(
                        "Top Thrift Finds",
                        style: TextStyle(
                            fontSize: 20, 
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 15),
                    ],
                  ),
                ),
              ),
              
              // Thrift Grid
              if (itemState.status == ItemStatus.loading && thriftItems.isEmpty)
                const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()))
              else if (thriftItems.isEmpty)
                _buildEmptyThriftState()
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      childAspectRatio: 0.68,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _thriftProductCard(context, thriftItems[index], ref, isDark),
                      childCount: thriftItems.length,
                    ),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)), // Space for Bottom Nav
            ],
          ),
        ),
      ),
    );
  }

  Widget _thriftPromoBanner(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark 
            ? [const Color(0xFF006B56), const Color(0xFF00B894)] 
            : [const Color(0xFF00B894), const Color(0xFF55E6C1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        border: isDark ? Border.all(color: Colors.white10) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              "ECO-CONSCIOUS CHOICE",
              style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            "Thrift & Save\nUp to 60% OFF",
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          const Text(
            "Find your favorite classics at a fraction of the price.",
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _thriftProductCard(BuildContext context, ItemEntity item, WidgetRef ref, bool isDark) {
    final String imageUrl = item.media != null 
        ? "${ApiEndpoints.baseImageUrl}${item.media}" 
        : "";
    
    final isInWishlist = ref.watch(wishlistViewModelProvider).items.any((i) => i.itemId == item.itemId);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreenNew(item: item),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A1A) : Colors.grey[50],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isDark ? Colors.white10 : Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Stack
            Expanded(
              child: Stack(
                children: [
                  Center(
                    child: Hero(
                      tag: 'item-${item.itemId}',
                      child: imageUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.contain,
                              placeholder: (context, url) => const CircularProgressIndicator(color: Colors.black),
                              errorWidget: (context, url, error) => const Icon(Icons.error),
                            )
                          : Image.asset("assets/images/shoe.png"),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: GestureDetector(
                      onTap: () => ref.read(wishlistViewModelProvider.notifier).toggleWishlist(item),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF2C2C2C) : Colors.white, 
                            shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isInWishlist ? Icons.favorite : Icons.favorite_border, 
                          size: 18, 
                          color: isInWishlist ? Colors.red : (isDark ? Colors.white : Colors.black),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Details
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                    style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        fontSize: 14,
                        color: isDark ? Colors.white : Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        "Rs. ${item.price}",
                        style: TextStyle(
                            fontWeight: FontWeight.w900, 
                            fontSize: 16,
                            color: isDark ? Colors.tealAccent : Colors.black,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      Text(
                        " 4.8", 
                        style: TextStyle(
                            fontSize: 12, 
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white70 : Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00B894).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF00B894).withValues(alpha: 0.3)),
                    ),
                    child: const Center(
                      child: Text(
                        "THRIFT",
                        style: TextStyle(color: Color(0xFF00B894), fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyThriftState() {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.eco_outlined, size: 80, color: Colors.grey[800]),
            const SizedBox(height: 20),
            const Text("No thrifts yet!", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
            const Text("Check back soon for unique finds.", style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
