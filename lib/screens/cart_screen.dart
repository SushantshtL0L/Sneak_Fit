import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sneak_fit/core/api/api_endpoints.dart';
import 'package:sneak_fit/features/cart/presentation/view_model/cart_view_model.dart';
import 'package:sneak_fit/core/theme/theme_provider.dart';
import 'package:sneak_fit/features/sensors/presentation/view_model/sensor_view_model.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartViewModelProvider);
    final cartItems = cartState.cartItems;
    final totalPrice = cartState.totalPrice;
    final isDark = ref.watch(themeViewModelProvider).isDarkMode;

    // SHAKE TO CHECKOUT LOGIC
    ref.listen(sensorViewModelProvider.select((s) => s.isShakeDetected), (previous, next) {
      if (next && cartItems.isNotEmpty) {
        // Provide haptic feedback if possible or just navigate
        Navigator.pushNamed(context, '/checkout');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(" Shake detected! Fast-tracking to checkout..."),
            duration: Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          "My Bag",
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.w900,
            fontSize: 24,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        actions: [
          if (cartItems.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                  color: const Color(0xFF23D19D).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "${cartItems.length} items",
                    style: const TextStyle(
                      color: Color(0xFF23D19D),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: cartItems.isEmpty
          ? _buildEmptyCart(isDark)
          : Stack(
              children: [
                // Cart Items List
                ListView.builder(
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 10,
                    bottom: 140, // More space for the enhanced footer
                  ),
                  itemCount: cartItems.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      // Shake Pro-tip Chip with enhanced UI
                      return Container(
                        margin: const EdgeInsets.only(bottom: 24),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF23D19D).withValues(alpha: 0.15),
                              const Color(0xFF23D19D).withValues(alpha: 0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF23D19D).withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Color(0xFF23D19D),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.vibration, color: Colors.white, size: 16),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Shake to Checkout",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : Colors.black,
                                    ),
                                  ),
                                  Text(
                                    "Instantly fast-track your stylish order!",
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDark ? Colors.white60 : Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    
                    final item = cartItems[index - 1];
                    final imageUrl = item.image.startsWith('http')
                        ? item.image
                        : '${ApiEndpoints.baseImageUrl}${item.image}';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                        border: isDark ? Border.all(color: Colors.white10) : null,
                      ),
                      child: Row(
                        children: [
                          // Product Image with Frame
                          Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF0F0F0),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: CachedNetworkImage(
                                imageUrl: imageUrl,
                                fit: BoxFit.contain,
                                // padding: const EdgeInsets.all(8), // This is not a property of CachedNetworkImage
                                placeholder: (context, url) => Container(
                                  color: isDark ? Colors.white10 : Colors.grey[100],
                                ),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.image_not_supported,
                                        size: 40, color: Colors.grey),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Product Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.brand,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFF23D19D),
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            item.name,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: isDark ? Colors.white : Colors.black,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        ref
                                            .read(cartViewModelProvider.notifier)
                                            .removeFromCart(item.id, item.size);
                                      },
                                      icon: Icon(Icons.delete_sweep_outlined, 
                                        color: Colors.red.withValues(alpha: 0.7),
                                        size: 22,
                                      ),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    _cartInfoChip("Size ${item.size}", isDark),
                                    const SizedBox(width: 8),
                                    _cartInfoChip(item.color, isDark, colorMarker: _getColorFromName(item.color)),
                                    const Spacer(),
                                    // Premium Quantity Controls
                                    Container(
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF0F0F0),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          _qtyBtn(Icons.remove, () {
                                            if (item.quantity > 1) {
                                              ref.read(cartViewModelProvider.notifier)
                                                .updateQuantity(item.id, item.size, item.quantity - 1);
                                            }
                                          }, isDark),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 10),
                                            child: Text(
                                              '${item.quantity}',
                                              style: TextStyle(
                                                color: isDark ? Colors.white : Colors.black,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                          _qtyBtn(Icons.add, () {
                                            ref.read(cartViewModelProvider.notifier)
                                              .updateQuantity(item.id, item.size, item.quantity + 1);
                                          }, isDark),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                // Premium Checkout Footer
                if (cartItems.isNotEmpty)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 34),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(36),
                          topRight: Radius.circular(36),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 25,
                            offset: const Offset(0, -10),
                          ),
                        ],
                        border: isDark ? const Border(top: BorderSide(color: Colors.white10)) : null,
                      ),
                      child: SafeArea(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Subtotal',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  'Rs ${totalPrice.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              height: 60,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/checkout');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF23D19D),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  elevation: 5,
                                  shadowColor: const Color(0xFF23D19D).withValues(alpha: 0.4),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'GO TO CHECKOUT',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Icon(Icons.arrow_forward_rounded, size: 20),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _cartInfoChip(String text, bool isDark, {Color? colorMarker}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (colorMarker != null) ...[
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: colorMarker,
                shape: BoxShape.circle,
                border: colorMarker == Colors.white ? Border.all(color: Colors.grey, width: 0.5) : null,
              ),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap, bool isDark) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, size: 14, color: isDark ? Colors.white70 : Colors.black87),
      ),
    );
  }

  Widget _buildEmptyCart(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: const Color(0xFF23D19D).withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shopping_bag_outlined,
              size: 100,
              color: Color(0xFF23D19D),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Your Bag is Empty',
            style: TextStyle(
              fontSize: 24,
              color: isDark ? Colors.white : Colors.black,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Looks like you haven\'t added any kicks yet.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorFromName(String name) {
    switch (name.toLowerCase()) {
      case 'black':
        return Colors.black;
      case 'white':
        return Colors.white;
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'grey':
      case 'gray':
        return Colors.grey;
      case 'green':
        return Colors.green;
      case 'orange':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
