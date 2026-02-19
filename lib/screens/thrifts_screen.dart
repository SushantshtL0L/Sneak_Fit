import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sneak_fit/core/api/api_endpoints.dart';
import 'package:sneak_fit/features/item/domain/entities/item_entity.dart';
import 'package:sneak_fit/features/item/presentation/state/item_state.dart';
import 'package:sneak_fit/features/item/presentation/view_model/item_viewmodel.dart';
import 'package:sneak_fit/features/wishlist/presentation/view_model/wishlist_view_model.dart';
import 'package:sneak_fit/screens/product_detail_screen_new.dart';

class ThriftsScreen extends ConsumerWidget {
  const ThriftsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemState = ref.watch(itemViewModelProvider);
    
    // Filter only Thrift items
    final thriftItems = itemState.items.where((item) => item.condition == ItemCondition.thrift).toList();

    return Scaffold(
      backgroundColor: Colors.white,
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
                      const Text(
                        "Thrift Shop",
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -1),
                      ),
                      const Text(
                        "Giving kicks a second life.",
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                      const SizedBox(height: 20),
                      _thriftPromoBanner(),
                      const SizedBox(height: 30),
                      const Text(
                        "Top Thrift Finds",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                      (context, index) => _thriftProductCard(context, thriftItems[index], ref),
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

  Widget _thriftPromoBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00B894), Color(0xFF55E6C1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00B894).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
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

  Widget _thriftProductCard(BuildContext context, ItemEntity item, WidgetRef ref) {
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
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[200]!),
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
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: Icon(
                          isInWishlist ? Icons.favorite : Icons.favorite_border, 
                          size: 18, 
                          color: isInWishlist ? Colors.red : Colors.black,
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
                    item.itemName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        "Rs. ${item.price}",
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                      ),
                      const Spacer(),
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      const Text(" 4.8", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00B894).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        "CERTIFIED THRIFT",
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
            Icon(Icons.eco_outlined, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 20),
            const Text("No thrifts yet!", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Text("Check back soon for unique finds.", style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
