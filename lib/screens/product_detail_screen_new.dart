import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sneak_fit/core/api/api_endpoints.dart';
import 'package:sneak_fit/features/cart/domain/entities/cart_item_entity.dart';
import 'package:sneak_fit/features/cart/presentation/view_model/cart_view_model.dart';
import 'package:sneak_fit/features/item/domain/entities/item_entity.dart';
import 'package:sneak_fit/core/utils/my_snack_bar.dart';
import 'package:sneak_fit/features/review/presentation/view_model/review_view_model.dart';
import 'package:sneak_fit/features/review/domain/entities/review_entity.dart';
import 'package:timeago/timeago.dart' as timeago;

class ProductDetailScreenNew extends ConsumerStatefulWidget {
  final ItemEntity item;

  const ProductDetailScreenNew({
    super.key,
    required this.item,
  });

  @override
  ConsumerState<ProductDetailScreenNew> createState() =>
      _ProductDetailScreenNewState();
}

class _ProductDetailScreenNewState
    extends ConsumerState<ProductDetailScreenNew> {
  String? selectedSize;
  String? selectedColor;
  
  final List<String> availableSizes = [
    '38', '39', '40', '41', '42', '43', '44', '45'
  ];

  final Map<String, Color> availableColors = {
    'Black': Colors.black,
    'White': Colors.white,
    'Red': Colors.red,
    'Blue': Colors.blue,
    'Grey': Colors.grey,
  };

  @override
  void initState() {
    super.initState();
    // If item has a fixed size (thrift), use it
    if (widget.item.condition == ItemCondition.thrift) {
      // For thrift, we automatically use whatever size/color the seller provided
      selectedSize = widget.item.size;
      selectedColor = widget.item.color ?? 'Original';
    } else {
      // For new items, set default color if current item has one
      if (widget.item.color != null && availableColors.containsKey(widget.item.color)) {
        selectedColor = widget.item.color;
      }
    }
    
    // Fetch product reviews
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(reviewViewModelProvider.notifier).fetchProductReviews(widget.item.itemId);
    });
  }

  void _addToCart() {
    if (selectedSize == null) {
      showMySnackBar(
        context: context,
        message: 'Please select a size',
        type: SnackBarType.warning,
      );
      return;
    }

    if (selectedColor == null) {
      showMySnackBar(
        context: context,
        message: 'Please select a color',
        type: SnackBarType.warning,
      );
      return;
    }

    final imageUrl = widget.item.media != null
        ? (widget.item.media!.startsWith('http')
            ? widget.item.media!
            : '${ApiEndpoints.baseImageUrl}${widget.item.media}')
        : '';

    final cartItem = CartItemEntity(
      id: widget.item.itemId,
      name: widget.item.itemName,
      price: widget.item.price,
      image: imageUrl,
      brand: widget.item.brand ?? 'Unknown Brand',
      quantity: 1,
      size: selectedSize!,
      color: selectedColor!,
      description: widget.item.description ?? '',
      condition: widget.item.condition == ItemCondition.thrift ? 'thrift' : null,
    );

    ref.read(cartViewModelProvider.notifier).addToCart(cartItem);

    showMySnackBar(
      context: context,
      message: 'Added to cart successfully!',
      type: SnackBarType.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = widget.item.media != null
        ? (widget.item.media!.startsWith('http')
            ? widget.item.media!
            : '${ApiEndpoints.baseImageUrl}${widget.item.media}')
        : '';

    final isThrift = widget.item.condition == ItemCondition.thrift;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.item.brand ?? 'Product Details',
          style: const TextStyle(color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Center(
              child: Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.image_not_supported,
                                  size: 80, color: Colors.grey),
                        )
                      : const Icon(Icons.image_not_supported,
                          size: 80, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Brand & Condition Badge
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.item.brand ?? 'Unknown Brand',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (isThrift)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orange[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'THRIFT',
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 8),

            // Product Name
            Text(
              widget.item.itemName,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 16),

            // Price
            Text(
              'Rs ${widget.item.price.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF23D19D),
              ),
            ),

            const SizedBox(height: 20),

            // Description
            if (widget.item.description != null &&
                widget.item.description!.isNotEmpty) ...[
              const Text(
                'Description',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.item.description!,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
            ],

            if (isThrift)
              // Fixed size display for thrift items (Web-like spec)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Item Specification',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.straighten, size: 20, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          'Size: ${widget.item.size ?? "N/A"}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            else ...[
              // Selectable sizes for new items
              const Text(
                'Size',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: availableSizes.map((size) {
                  final isSelected = selectedSize == size;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedSize = size;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF23D19D)
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF23D19D)
                              : Colors.grey[300]!,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        size,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 24),

            // Color Selection - ONLY for non-thrift items
            if (!isThrift) ...[
              const Text(
                'Color',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 16,
                children: availableColors.entries.map((entry) {
                  final colorName = entry.key;
                  final colorValue = entry.value;
                  final isSelected = selectedColor == colorName;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedColor = colorName;
                      });
                    },
                    child: Column(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: colorValue,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF23D19D)
                                  : Colors.grey[300]!,
                              width: 3,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFF23D19D)
                                          // ignore: deprecated_member_use
                                          .withOpacity(0.4),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    )
                                  ]
                                : null,
                          ),
                          child: isSelected
                              ? Icon(Icons.check,
                                  color: colorValue == Colors.white
                                      ? Colors.black
                                      : Colors.white,
                                  size: 20)
                              : null,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          colorName,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected ? Colors.black : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 40),

            // Add to Cart Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF23D19D),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                ),
                onPressed: _addToCart,
                child: const Text(
                  'Add to Cart',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            _buildReviewSection(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewSection() {
    final state = ref.watch(reviewViewModelProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Product Reviews',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (state.reviews.isNotEmpty)
              Text(
                '${state.reviews.length} reviews',
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (state.isLoading)
          const Center(child: CircularProgressIndicator(color: Color(0xFF23D19D)))
        else if (state.reviews.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              children: [
                Icon(Icons.rate_review_outlined, size: 40, color: Colors.grey),
                SizedBox(height: 12),
                Text(
                  'No reviews yet for this product.',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.reviews.length,
            separatorBuilder: (context, index) => const Divider(height: 32),
            itemBuilder: (context, index) {
              final review = state.reviews[index];
              return _buildReviewTile(review);
            },
          ),
      ],
    );
  }

  Widget _buildReviewTile(ReviewEntity review) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.grey[200],
              backgroundImage: review.userImage != null && review.userImage!.isNotEmpty
                  ? NetworkImage('${ApiEndpoints.baseImageUrl}${review.userImage}')
                  : null,
              child: review.userImage == null || review.userImage!.isEmpty
                  ? const Icon(Icons.person, size: 20, color: Colors.grey)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    review.userName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Row(
                        children: List.generate(5, (starIndex) {
                          return Icon(
                            starIndex < review.rating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 14,
                          );
                        }),
                      ),
                      const SizedBox(width: 8),
                      if (review.createdAt != null)
                        Text(
                          timeago.format(review.createdAt!),
                          style: TextStyle(color: Colors.grey[500], fontSize: 11),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          review.comment,
          style: const TextStyle(fontSize: 14, height: 1.4, color: Colors.black87),
        ),
      ],
    );
  }
}
