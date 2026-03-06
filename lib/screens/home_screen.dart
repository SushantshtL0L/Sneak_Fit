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
import 'package:sneak_fit/screens/all_products_screen.dart';
import 'package:sneak_fit/screens/product_detail_screen_new.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemState = ref.watch(itemViewModelProvider);
    final isDark = ref.watch(themeViewModelProvider).isDarkMode;

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
                  searchBar(context, isDark, ref),
                  const SizedBox(height: 24),
                  promoBanner(isDark),
                  const SizedBox(height: 24),
                  _buildBrandsSection(isDark),
                  const SizedBox(height: 24),
                  sectionHeader(context, isDark),
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
                sliver: productGrid(context, itemState.filteredItems, ref, isDark),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
    );
  }

  Widget searchBar(BuildContext context, bool isDark, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(30),
        border: Border(
          bottom: BorderSide(color: Colors.tealAccent.shade400, width: 3),
        ),
      ),
      child: TextField(
        onChanged: (value) => ref.read(itemViewModelProvider.notifier).searchProducts(value),
        style: TextStyle(color: isDark ? Colors.white : Colors.black),
        decoration: InputDecoration(
          icon: Icon(Icons.search, color: isDark ? Colors.tealAccent : Colors.black54),
          suffixIcon: IconButton(
            icon: Icon(Icons.tune, color: isDark ? Colors.tealAccent : Colors.black),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const FilterBottomSheet(),
              );
            },
          ),
          hintText: "Search your kicks...",
          hintStyle: TextStyle(color: isDark ? Colors.grey : Colors.grey.shade600),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget promoBanner(bool isDark) {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark 
            ? [const Color(0xFF23D19D), const Color(0xFF168A68)]
            : [const Color(0xFF000000), const Color(0xFF2C2C2C)],
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? const Color(0xFF23D19D) : Colors.black).withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Stack(
        children: [
          // Background pattern or abstract shapes can go here
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              Icons.bolt,
              size: 200,
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "NEW RELEASE",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "25% Off Today",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Exclusive GoldStar collection\navailable for limited time.",
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("Shop Now", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Transform.rotate(
                    angle: -0.2,
                    child: Hero(
                      tag: 'banner_shoe',
                      child: Image.asset(
                        "assets/images/shoe.png",
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandsSection(bool isDark) {
    final brands = [
      {'name': 'Nike', 'initial': 'N', 'color': Colors.black},
      {'name': 'Adidas', 'initial': 'A', 'color': const Color(0xFF0073B1)},
      {'name': 'Jordan', 'initial': 'J', 'color': const Color(0xFFE01E37)},
      {'name': 'Puma', 'initial': 'P', 'color': const Color(0xFF000000)},
      {'name': 'Reebok', 'initial': 'R', 'color': const Color(0xFF061922)},
      {'name': 'NB', 'initial': 'NB', 'color': const Color(0xFFADADAD)},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Popular Brands",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const Text(
              "See All",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 90,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: brands.length,
            separatorBuilder: (context, index) => const SizedBox(width: 20),
            itemBuilder: (context, index) {
              final brand = brands[index];
              return Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[100],
                      shape: BoxShape.circle,
                      border: Border.all(color: isDark ? Colors.white10 : Colors.grey[200]!),
                    ),
                    child: Center(
                      child: Text(
                        brand['initial'] as String,
                        style: TextStyle(
                          color: isDark ? Colors.white : (brand['color'] as Color),
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    brand['name'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget sectionHeader(BuildContext context, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Most Popular",
          style: TextStyle(
            fontSize: 18, 
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
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

  Widget productGrid(BuildContext context, List<ItemEntity> items, WidgetRef ref, bool isDark) {
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
            isDark: isDark,
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
    required bool isDark,
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
          color: isDark ? const Color(0xFF1A1A1A) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: isDark ? Border.all(color: Colors.white10) : null,
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
            const SizedBox(height: 6),
            Text(
              price,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: isDark ? Colors.tealAccent : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
