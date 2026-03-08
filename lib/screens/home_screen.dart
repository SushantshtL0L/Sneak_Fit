import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
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
                  const PromoBannerCarousel(),
                  const SizedBox(height: 24),
                  _buildBrandsSection(isDark),
                  const SizedBox(height: 24),
                  sectionHeader(context, isDark),
                  const SizedBox(height: 12),
                ]),
              ),
            ),
            if (itemState.status == ItemStatus.loading && itemState.items.isEmpty)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildShimmerCard(isDark),
                    childCount: 6,
                  ),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: MediaQuery.of(context).size.width > 600 ? 0.7 : 0.65,
                  ),
                ),
              )
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

  Widget _buildShimmerCard(bool isDark) {
    final baseColor = isDark ? const Color(0xFF2A2A2A) : Colors.grey[300]!;
    final highlightColor = isDark ? const Color(0xFF3A3A3A) : Colors.grey[100]!;
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: baseColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 12, width: 100, color: baseColor, margin: const EdgeInsets.only(bottom: 6)),
                  Container(height: 10, width: 60, color: baseColor),
                ],
              ),
            ),
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

  Widget _buildBrandsSection(bool isDark) {
    final brands = [
      {'name': 'Nike', 'image': 'assets/images/nike.png'},
      {'name': 'Adidas', 'image': 'assets/images/adidas.png'},
      {'name': 'Jordan', 'image': 'assets/images/jordan.png'},
      {'name': 'Puma', 'image': 'assets/images/puma.png'},
      {'name': 'Reebok', 'initial': 'Rbk', 'bgColor': const Color(0xFF1A1A2E), 'textColor': Colors.white},
      {'name': 'NB', 'initial': 'NB', 'bgColor': const Color(0xFFE8E8E8), 'textColor': const Color(0xFF333333)},
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
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? Colors.white24 : Colors.grey[200]!,
                        width: 1.5,
                      ),
                      boxShadow: isDark
                          ? [BoxShadow(color: Colors.white.withValues(alpha: 0.05), blurRadius: 8)]
                          : [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2))],
                    ),
                    child: Center(
                      child: brand.containsKey('image')
                        ? Padding(
                            padding: const EdgeInsets.all(12),
                            child: Image.asset(
                              brand['image'] as String,
                              fit: BoxFit.contain,
                            ),
                          )
                        : Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: brand['bgColor'] as Color,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                brand['initial'] as String,
                                style: TextStyle(
                                  color: brand['textColor'] as Color,
                                  fontWeight: FontWeight.w900,
                                  fontSize: brand['initial'] == 'NB' ? 18 : 14,
                                  letterSpacing: -0.5,
                                ),
                              ),
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
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: MediaQuery.of(context).size.width > 600 ? 0.75 : 0.65,
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

class PromoBannerCarousel extends ConsumerStatefulWidget {
  const PromoBannerCarousel({super.key});

  @override
  ConsumerState<PromoBannerCarousel> createState() => _PromoBannerCarouselState();
}

class _PromoBannerCarouselState extends ConsumerState<PromoBannerCarousel> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  final List<BannerData> banners = [
    BannerData(
      title: "NEW RELEASE",
      mainTitle: "25% Off Today",
      description: "Exclusive GoldStar collection\navailable for limited time.",
      image: "assets/images/banner.png",
      colors: [const Color(0xFF000000), const Color(0xFF2C2C2C)],
      darkColors: [const Color(0xFF23D19D), const Color(0xFF168A68)],
    ),
    BannerData(
      title: "SUMMER SALE",
      mainTitle: "Up to 50% Off",
      description: "Get the best kicks for the\nsummer season now.",
      image: "assets/images/banner.png", 
      colors: [const Color(0xFF1A237E), const Color(0xFF3949AB)],
      darkColors: [const Color(0xFF3F51B5), const Color(0xFF303F9F)],
    ),
    BannerData(
      title: "LIMITED EDITION",
      mainTitle: "SneakFit Pro",
      description: "Join the elite with our\nlatest professional series.",
      image: "assets/images/banner.png", 
      colors: [const Color(0xFFD32F2F), const Color(0xFFB71C1C)],
      darkColors: [const Color(0xFFFF5252), const Color(0xFFFF1744)],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _startAutoSlider();
  }

  void _startAutoSlider() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        _currentPage = (_currentPage + 1) % banners.length;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeViewModelProvider).isDarkMode;

    return Column(
      children: [
        SizedBox(
          height: 220,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: banners.length,
            itemBuilder: (context, index) {
              return _buildBannerItem(banners[index], isDark);
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            banners.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 6,
              width: _currentPage == index ? 24 : 6,
              decoration: BoxDecoration(
                color: _currentPage == index 
                    ? (isDark ? const Color(0xFF23D19D) : Colors.black)
                    : Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBannerItem(BannerData data, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark ? data.darkColors : data.colors,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? data.darkColors[0] : data.colors[0]).withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Stack(
        children: [
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
                        child: Text(
                          data.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        data.mainTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        data.description,
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
                    child: Image.asset(
                      data.image,
                      fit: BoxFit.contain,
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
}

class BannerData {
  final String title;
  final String mainTitle;
  final String description;
  final String image;
  final List<Color> colors;
  final List<Color> darkColors;

  BannerData({
    required this.title,
    required this.mainTitle,
    required this.description,
    required this.image,
    required this.colors,
    required this.darkColors,
  });
}
