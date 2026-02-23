import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sneak_fit/core/api/api_endpoints.dart';
import 'package:sneak_fit/features/item/domain/entities/item_entity.dart';
import 'package:sneak_fit/features/item/presentation/state/item_state.dart';
import 'package:sneak_fit/features/item/presentation/view_model/item_viewmodel.dart';
import 'package:sneak_fit/features/wishlist/presentation/view_model/wishlist_view_model.dart';
import 'package:sneak_fit/screens/all_products_screen.dart';
import 'package:sneak_fit/screens/product_detail_screen_new.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemState = ref.watch(itemViewModelProvider);

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () => ref.read(itemViewModelProvider.notifier).getAllItems(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  searchBar(),
                  const SizedBox(height: 20),
                  promoBanner(),
                  const SizedBox(height: 24),
                  sectionHeader(context),
                  const SizedBox(height: 12),
                ]),
              ),
            ),
            if (itemState.status == ItemStatus.loading && itemState.items.isEmpty)
              const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
            else if (itemState.status == ItemStatus.error)
              SliverFillRemaining(child: Center(child: Text("Error: ${itemState.errorMessage}")))
            else if (itemState.items.isEmpty)
              const SliverFillRemaining(child: Center(child: Text("No products found")))
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: productGrid(context, itemState.items, ref),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
    );
  }

  Widget searchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(30),
        border: Border(
          bottom: BorderSide(color: Colors.tealAccent.shade400, width: 3),
        ),
      ),
      child: const TextField(
        decoration: InputDecoration(
          icon: Icon(Icons.search),
          hintText: "Search",
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget promoBanner() {
    return Container(
      height: 165,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  "GoldStar Nepal",
                  style: TextStyle(
                    fontFamily: 'OpenSans',
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "25%\nToday Special",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "Get discount for every order\nOnly valid today",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Image.asset(
            "assets/images/shoe.png",
            width: 120,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }

  Widget sectionHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Most Popular",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AllProductsScreen(),
              ),
            );
          },
          child: const Text(
            "SEE ALL",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
      ],
    );
  }

  Widget productGrid(BuildContext context, List<ItemEntity> items, WidgetRef ref) {
    return SliverGrid(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final item = items[index];
          return productCard(
            context: context,
            brand: item.itemName,
            rating: "4.5",
            price: "Rs ${item.price.toInt()}",
            item: item,
            ref: ref,
          );
        },
        childCount: items.length,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.65,
      ),
    );
  }

  Widget productCard({
    required BuildContext context,
    required String brand,
    required String rating,
    required String price,
    required ItemEntity item,
    required WidgetRef ref,
  }) {
    // Resolve image URL
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
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Center(
                    child: imageUrl.startsWith('http')
                        ? CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.contain,
                            placeholder: (context, url) => const CircularProgressIndicator(),
                            errorWidget: (context, url, error) => Image.asset("assets/images/shoe.png"),
                          )
                        : Image.asset("assets/images/shoe.png"),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Consumer(
                      builder: (context, ref, child) {
                        final isInWishlist = ref.watch(wishlistViewModelProvider).items.any((i) => i.itemId == item.itemId);
                        return GestureDetector(
                          onTap: () => ref.read(wishlistViewModelProvider.notifier).toggleWishlist(item),
                          child: Icon(
                            isInWishlist ? Icons.favorite : Icons.favorite_border,
                            color: isInWishlist ? Colors.red : Colors.grey,
                            size: 22,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              brand,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item.condition.name.toUpperCase(),
                    style: const TextStyle(fontSize: 10, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              price,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
