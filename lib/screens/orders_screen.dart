import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sneak_fit/features/order/presentation/view_model/orders_view_model.dart';
import 'package:sneak_fit/features/order/domain/entities/order_entity.dart';
import 'package:sneak_fit/core/api/api_endpoints.dart';
import 'package:intl/intl.dart';
import 'package:sneak_fit/features/review/presentation/widgets/review_dialog.dart';
import 'package:sneak_fit/screens/order_detail_screen.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    // Use microtask to initiate fetch without blocking UI build
    Future.microtask(() =>
        ref.read(ordersViewModelProvider.notifier).fetchOrders());
  }

  @override
  Widget build(BuildContext context) {
    final ordersState = ref.watch(ordersViewModelProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "My Orders",
          style: TextStyle(
            color: Colors.black, 
            fontWeight: FontWeight.w800,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        color: const Color(0xFF23D19D),
        onRefresh: () => ref.read(ordersViewModelProvider.notifier).fetchOrders(),
        child: _buildBody(context, ordersState),
      ),
    );
  }

  Widget _buildBody(BuildContext context, OrdersState state) {
    if (state.isLoading && state.orders.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Color(0xFF23D19D),
              strokeWidth: 3,
            ),
            SizedBox(height: 16),
            Text(
              "Loading your orders...",
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    if (state.error != null && state.orders.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.error_outline_rounded, size: 50, color: Colors.red),
              ),
              const SizedBox(height: 20),
              const Text(
                "Unable to load orders",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                state.error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => ref.read(ordersViewModelProvider.notifier).fetchOrders(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: const Text("TRY AGAIN"),
              ),
            ],
          ),
        ),
      );
    }

    if (state.orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/Logo.png", // Or a specific empty-cart asset if available
              height: 80,
              opacity: const AlwaysStoppedAnimation(0.3),
            ),
            const SizedBox(height: 24),
            const Text(
              "No Orders Yet",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: -0.5),
            ),
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 50),
              child: Text(
                "Your stylish new sneakers are waiting! Start shopping now.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, height: 1.5),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF23D19D),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: const Text(
                "START SHOPPING",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: state.orders.length,
      separatorBuilder: (context, index) => const SizedBox(height: 20),
      itemBuilder: (context, index) {
        final order = state.orders[index];
        return _buildOrderCard(context, order);
      },
    );
  }

  Widget _buildOrderCard(BuildContext context, OrderEntity order) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Order ID: #${order.id.substring(order.id.length > 6 ? order.id.length - 6 : 0).toUpperCase()}",
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('MMM dd, yyyy • hh:mm a').format(order.createdAt),
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
                _buildStatusBadge(order.status),
              ],
            ),
          ),
          const Divider(height: 1, indent: 20, endIndent: 20),
          
          // Items
          ...order.items.map((item) => _buildOrderItem(context, item, order.status)),

          const Divider(height: 1, indent: 20, endIndent: 20),
          
          // Footer
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Total Amount", 
                      style: TextStyle(color: Colors.grey[500], fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Rs ${order.totalAmount.toStringAsFixed(0)}",
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Color(0xFF23D19D)),
                    ),
                  ],
                ),
                Row(
                  children: [
                    if (order.status.toLowerCase() == 'pending' || order.status.toLowerCase() == 'processing')
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: OutlinedButton(
                          onPressed: () => _showCancelDialog(context, order.id),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: BorderSide(color: Colors.red.withValues(alpha: 0.3)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          child: const Text("Cancel"),
                        ),
                      ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrderDetailScreen(order: order),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: const Text("Details"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(BuildContext context, OrderItemEntity item, String orderStatus) {
    final imageUrl = item.image.startsWith('http')
        ? item.image
        : '${ApiEndpoints.baseImageUrl}${item.image}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    imageUrl,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 70,
                      height: 70,
                      color: Colors.grey.shade100,
                      child: const Icon(Icons.image_not_supported, size: 24, color: Colors.grey),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _infoTag("Size ${item.size}", Colors.blue),
                        const SizedBox(width: 8),
                        _infoTag("Qty ${item.quantity}", Colors.grey),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                "Rs ${item.price.toStringAsFixed(0)}",
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
              ),
            ],
          ),
          if (orderStatus.toLowerCase() == 'delivered')
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => ReviewDialog(
                      productId: item.product,
                      productName: item.name,
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF23D19D).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star_rounded, size: 18, color: Color(0xFF23D19D)),
                      SizedBox(width: 6),
                      Text(
                        "Rate & Review product",
                        style: TextStyle(
                          color: Color(0xFF23D19D), 
                          fontSize: 12, 
                          fontWeight: FontWeight.bold
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

  Widget _infoTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    IconData icon;
    switch (status.toLowerCase()) {
      case 'processing': 
        color = Colors.orange; 
        icon = Icons.sync_rounded;
        break;
      case 'shipped': 
        color = Colors.blue; 
        icon = Icons.local_shipping_rounded;
        break;
      case 'delivered': 
        color = Colors.green; 
        icon = Icons.verified_rounded;
        break;
      case 'cancelled': 
        color = Colors.red; 
        icon = Icons.cancel_outlined;
        break;
      default: 
        color = Colors.grey;
        icon = Icons.info_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            status.toUpperCase(),
            style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 10),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context, String orderId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Cancel Order?", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("This action cannot be undone. Are you sure you want to stop this order?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("NO, BACK", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(ordersViewModelProvider.notifier).cancelOrder(orderId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("YES, CANCEL"),
          ),
        ],
      ),
    );
  }
}
