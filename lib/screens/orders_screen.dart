import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sneak_fit/features/order/presentation/view_model/orders_view_model.dart';
import 'package:sneak_fit/features/order/domain/entities/order_entity.dart';
import 'package:sneak_fit/core/api/api_endpoints.dart';
import 'package:intl/intl.dart';
import 'package:sneak_fit/features/review/presentation/widgets/review_dialog.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersState = ref.watch(ordersViewModelProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "My Orders",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => ref.read(ordersViewModelProvider.notifier).fetchOrders(),
            icon: const Icon(Icons.refresh, color: Color(0xFF23D19D)),
          ),
        ],
      ),
      body: _buildBody(context, ref, ordersState),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, OrdersState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF23D19D)));
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            Text(state.error!),
          ],
        ),
      );
    }

    if (state.orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                  )
                ],
              ),
              child: const Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            const Text(
              "No orders yet",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Go grab some sneakers!",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.orders.length,
      itemBuilder: (context, index) {
        final order = state.orders[index];
        return _buildOrderCard(context, ref, order);
      },
    );
  }

  Widget _buildOrderCard(BuildContext context, WidgetRef ref, OrderEntity order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        children: [
          // Header info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Order #${order.id.substring(order.id.length > 6 ? order.id.length - 6 : 0).toUpperCase()}",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('MMM dd, yyyy • hh:mm a').format(order.createdAt),
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                _buildStatusBadge(order.status),
              ],
            ),
          ),
          const Divider(height: 1),
          // Items
          ...order.items.take(2).map((item) => _buildOrderItem(context, item, order.status)),
          if (order.items.length > 2)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                "+${order.items.length - 2} more items",
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          const Divider(height: 1),
          // Footer
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Total Amount", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                      "Rs ${order.totalAmount.toStringAsFixed(0)}",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF23D19D)),
                    ),
                  ],
                ),
                Row(
                  children: [
                    if (order.status.toLowerCase() == 'pending' || order.status.toLowerCase() == 'processing')
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: OutlinedButton(
                          onPressed: () => _showCancelDialog(context, ref, order.id),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          child: const Text("Cancel"),
                        ),
                      ),
                    ElevatedButton(
                      onPressed: () {
                        // Could navigate to details
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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

  void _showCancelDialog(BuildContext context, WidgetRef ref, String orderId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cancel Order"),
        content: const Text("Are you sure you want to cancel this order?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("NO"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(ordersViewModelProvider.notifier).cancelOrder(orderId);
            },
            child: const Text("YES, CANCEL", style: TextStyle(color: Colors.red)),
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
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 50,
                    height: 50,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.image_not_supported, size: 20),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "Size: ${item.size} • Qty: ${item.quantity}",
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Text(
                "Rs ${item.price.toStringAsFixed(0)}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          if (orderStatus.toLowerCase() == 'delivered')
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => ReviewDialog(
                        productId: item.product,
                        productName: item.name,
                      ),
                    );
                  },
                  icon: const Icon(Icons.rate_review_outlined, size: 16, color: Color(0xFF23D19D)),
                  label: const Text(
                    "Write a Review",
                    style: TextStyle(color: Color(0xFF23D19D), fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'processing': color = Colors.orange; break;
      case 'shipped': color = Colors.blue; break;
      case 'delivered': color = Colors.green; break;
      case 'cancelled': color = Colors.red; break;
      default: color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10),
      ),
    );
  }
}
