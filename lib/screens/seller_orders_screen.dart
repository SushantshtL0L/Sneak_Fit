import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sneak_fit/features/order/presentation/view_model/orders_view_model.dart';
import 'package:sneak_fit/features/order/domain/entities/order_entity.dart';
import 'package:sneak_fit/core/api/api_endpoints.dart';
import 'package:intl/intl.dart';

class SellerOrdersScreen extends ConsumerStatefulWidget {
  const SellerOrdersScreen({super.key});

  @override
  ConsumerState<SellerOrdersScreen> createState() => _SellerOrdersScreenState();
}

class _SellerOrdersScreenState extends ConsumerState<SellerOrdersScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(ordersViewModelProvider.notifier).fetchAllOrders());
  }

  @override
  Widget build(BuildContext context) {
    final ordersState = ref.watch(ordersViewModelProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Sales Management",
          style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(ordersViewModelProvider.notifier).fetchAllOrders(),
        child: _buildBody(context, ordersState),
      ),
    );
  }

  Widget _buildBody(BuildContext context, OrdersState state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (state.isLoading && state.orders.isEmpty) {
      return Center(child: CircularProgressIndicator(color: isDark ? Colors.tealAccent : Colors.black));
    }

    if (state.error != null && state.orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            Text(state.error!, style: TextStyle(color: isDark ? Colors.white70 : Colors.black87)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(ordersViewModelProvider.notifier).fetchAllOrders(),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? Colors.tealAccent : Colors.black,
              ),
              child: Text("Retry", style: TextStyle(color: isDark ? Colors.black : Colors.white)),
            )
          ],
        ),
      );
    }

    if (state.orders.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: state.orders.length,
      itemBuilder: (context, index) {
        final order = state.orders[index];
        return _buildOrderCard(context, order);
      },
    );
  }

  Widget _buildEmptyState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 80, color: isDark ? Colors.grey[800] : Colors.grey[300]),
          const SizedBox(height: 20),
          Text("No sales yet", 
            style: TextStyle(
              fontSize: 18, 
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black
            )
          ),
          const SizedBox(height: 10),
          const Text("Orders for your items will appear here.", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, OrderEntity order) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.05 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
        border: Border.all(color: isDark ? Colors.white10 : Colors.transparent),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "ORDER #${order.id.substring(order.id.length - 6).toUpperCase()}",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : Colors.black),
                    ),
                    Text(
                      DateFormat('MMM dd, yyyy').format(order.createdAt),
                      style: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[500], fontSize: 12),
                    ),
                  ],
                ),
                _buildStatusChip(order.status),
              ],
            ),
          ),
          const Divider(height: 1),
          // Customer / Shipping
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: isDark ? Colors.black26 : const Color(0xFFF0F0F0),
                  child: Icon(Icons.person_outline, size: 18, color: isDark ? Colors.grey[400] : Colors.blueGrey),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Customer Info:", style: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey, fontSize: 11)),
                      Text(
                        order.userName ?? order.shippingAddress?.fullName ?? "No Name",
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: isDark ? Colors.white : Colors.black),
                      ),
                      if (order.shippingAddress != null)
                        Text(
                          "${order.shippingAddress!.address}, ${order.shippingAddress!.city} (${order.shippingAddress!.phone})",
                          style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[600], fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                Text(
                  "Rs. ${order.totalAmount.toStringAsFixed(0)}",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : Colors.black),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Items
          ...order.items.map((item) => _buildOrderItem(item)),
          
          // Actions
          if (order.status.toLowerCase() != 'delivered' && order.status.toLowerCase() != 'cancelled')
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildActionButton(order),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(OrderItemEntity item) {
    final imageUrl = item.image.startsWith('http')
        ? item.image
        : '${ApiEndpoints.baseImageUrl}${item.image}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              imageUrl,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(width: 50, height: 50, color: Theme.of(context).brightness == Brightness.dark ? Colors.black26 : Colors.grey[200]),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)),
                Text("Size: ${item.size} • Qty: ${item.quantity}", style: TextStyle(color: Colors.grey[600], fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'pending': color = Colors.blueGrey; break;
      case 'processing': color = Colors.orange; break;
      case 'shipped': color = Colors.blue; break;
      case 'delivered': color = Colors.green; break;
      case 'cancelled': color = Colors.red; break;
      default: color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10),
      ),
    );
  }

  Widget _buildActionButton(OrderEntity order) {
    String label = "";
    String nextStatus = "";
    Color color = Colors.black;

    switch (order.status.toLowerCase()) {
      case 'pending':
        label = "Start Processing";
        nextStatus = "processing";
        color = Colors.orange;
        break;
      case 'processing':
        label = "Mark as Shipped";
        nextStatus = "shipped";
        color = Colors.blue;
        break;
      case 'shipped':
        label = "Mark as Delivered";
        nextStatus = "delivered";
        color = Colors.green;
        break;
      default:
        return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ElevatedButton(
      onPressed: () => _updateStatus(order.id, nextStatus),
      style: ElevatedButton.styleFrom(
        backgroundColor: color == Colors.black && isDark ? Colors.white : color,
        foregroundColor: color == Colors.black && isDark ? Colors.black : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14),
        elevation: 0,
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  void _updateStatus(String orderId, String status) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        title: Text("Update Status", style: TextStyle(color: isDark ? Colors.white : Colors.black)),
        content: Text("Are you sure you want to mark this order as ${status.toUpperCase()}?", style: TextStyle(color: isDark ? Colors.white70 : Colors.black87)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("CANCEL", style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(ordersViewModelProvider.notifier).updateOrderStatus(orderId, status);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? Colors.tealAccent : Colors.black,
            ),
            child: Text("CONFIRM", style: TextStyle(color: isDark ? Colors.black : Colors.white)),
          ),
        ],
      ),
    );
  }
}
